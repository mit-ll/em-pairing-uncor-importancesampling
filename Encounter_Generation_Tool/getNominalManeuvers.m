% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function [ownHorzManeuverBeforeTCA, ownVertManeuverBeforeTCA, intHorzManeuverBeforeTCA, intVertManeuverBeforeTCA, ...
    anyOwnHorzManeuverBeforeTCA, anyOwnVertManeuverBeforeTCA, anyIntHorzManeuverBeforeTCA, anyIntVertManeuverBeforeTCA, metrics] = getNominalManeuvers(trajectory1, trajectory2, tca)
    % Determine whether there are any maneuvers in the nominal trajectories
    %
    % The outputs ownTurnBeforeTCA, ownClimbBeforeTCA, intTurnBeforeTCA,
    % intClimbBeforeTCA indicate whether there was a new ownship/intruder
    % maneuver before TCA. These are actual maneuvers (e.g., change from level
    % to climb, straight to turning).
    %
    % The outputs anyOwnTurnBeforeTCA, anyOwnClimbBeforeTCA,
    % anyIntTurnBeforeTCA, anyIntClimbBeforeTCA indicate whether the
    % ownship/intruder was climbing/decending or turning at any point before
    % TCA. These include encounters where the ownship or intruder is
    % climbing/descending/turning the entire time.
    %
    % Various other maneuver-related variables are collected in the metrics
    % struct.

    % Initialize metrics struct
    metrics.ownHorzTime = NaN; % time of last ownship horizontal maneuver during encounter
    metrics.ownVertTime = NaN; % time of last ownship vertical maneuver during encounter
    metrics.intHorzTime = NaN; % time of last intruder horizontal maneuver during encounter
    metrics.intVertTime = NaN; % time of last intruder vertical maneuver during encounter
    metrics.ownHorzTimeBeforeTCA = NaN; % time of last ownship horizontal maneuver before TCA
    metrics.ownVertTimeBeforeTCA = NaN; % time of last ownship vertical maneuver before TCA
    metrics.intHorzTimeBeforeTCA = NaN; % time of last intruder horizontal maneuver before TCA
    metrics.intVertTimeBeforeTCA = NaN; % time of last intruder vertical maneuver before TCA
    metrics.relHeading = NaN; % relative heading between ownship and intruder
    metrics.relAltitude = NaN; % relative altitude between ownship and intruder
    metrics.range = NaN; % range between ownship and intruder
    metrics.relSpeed = NaN; % relative speed between ownship and intruder
    metrics.ownNumManeuversHorzBeforeTCA = NaN; % number of ownship horizontal maneuvers before TCA
    metrics.intNumManeuversHorzBeforeTCA = NaN; % number of intruder horizontal maneuvers before TCA
    metrics.ownNumManeuversVertBeforeTCA = NaN; % number of ownship vertical maneuvers before TCA
    metrics.intNumManeuversVertBeforeTCA = NaN; % number of intruder vertical maneuvers before TCA
    metrics.ownNumManeuversHorz = NaN; % number of ownship horizontal maneuvers during encounter
    metrics.intNumManeuversHorz = NaN; % number of intruder horizontal maneuvers during encounter
    metrics.ownNumManeuversVert = NaN; % number of ownship vertical maneuvers during encounter
    metrics.intNumManeuversVert = NaN; % number of intruder vertical maneuvers during encounter
    metrics.isTurningAtTCA = 0; % whether intruder is turning at TCA
    metrics.hasVerticalRateAtTCA = 0; % whether intruder has vertical rate at TCA
    metrics.hasAccelerationAtTCA = 0; % whether intruder has acceleration at TCA

    % Initialize necessary variables
    own_trk_rad = trajectory1.psi_rad;
    int_trk_rad = trajectory2.psi_rad;
    own_alt_ft = trajectory1.up_ft;
    int_alt_ft = trajectory2.up_ft;
    own_x_ft = trajectory1.east_ft;
    own_y_ft = trajectory2.north_ft;
    int_x_ft = trajectory1.east_ft;
    int_y_ft = trajectory2.north_ft;
    own_gs_ftps = trajectory1.speed_ftps;
    int_gs_ftps = trajectory2.speed_ftps;

    % Compute relative geometry from ownship to intruder
    metrics.relHeading = rad2deg(own_trk_rad(1) - int_trk_rad(1));
    metrics.relAltitude = own_alt_ft(1) - int_alt_ft(1);
    metrics.range = hypot(own_x_ft(1) - int_x_ft(1), own_y_ft(1) - int_y_ft(1));
    metrics.relSpeed = own_gs_ftps(1) - int_gs_ftps(1);

    % ownHorzTime; find times when there is a change in ownship heading
    temp = abs(diff(own_trk_rad)) > 0.01;
    ownHorzTimes = find(diff(temp));
    anyOwnHorzManeuverBeforeTCA = any(temp);
    lastOwnHorzTimeIndex = find(ownHorzTimes <= numel(own_trk_rad), 1, 'last');
    lastOwnHorzTimeIndexTCA = find(ownHorzTimes <= tca, 1, 'last');
    if ~isempty(lastOwnHorzTimeIndex)
        metrics.ownHorzTime = ownHorzTimes(lastOwnHorzTimeIndex);
    end
    if ~isempty(lastOwnHorzTimeIndexTCA)
        metrics.ownHorzTimeBeforeTCA = ownHorzTimes(lastOwnHorzTimeIndexTCA);
    end

    % ownVertTime; find times when there is a change in ownship altitude
    temp = diff(own_alt_ft) ~= 0;
    ownVertTimes = find(diff(temp));
    anyOwnVertManeuverBeforeTCA = any(temp);
    lastOwnVertTimeIndex = find(ownVertTimes <= numel(own_alt_ft), 1, 'last');
    lastOwnVertTimeIndexTCA = find(ownVertTimes <= tca, 1, 'last');
    if ~isempty(lastOwnVertTimeIndex)
        metrics.ownVertTime = ownVertTimes(lastOwnVertTimeIndex);
    end
    if ~isempty(lastOwnVertTimeIndexTCA)
        metrics.ownVertTimeBeforeTCA = ownVertTimes(lastOwnVertTimeIndexTCA);
    end

    % intHorzTime; find times when there is a change in intruder heading
    temp = abs(diff(int_trk_rad)) ~= 0;
    intHorzTimes = find(diff(temp));
    anyIntHorzManeuverBeforeTCA = any(temp);
    lastIntHorzTimeIndex = find(intHorzTimes <= numel(int_trk_rad), 1, 'last');
    lastIntHorzTimeIndexTCA = find(intHorzTimes <= tca, 1, 'last');
    if ~isempty(lastIntHorzTimeIndex)
        metrics.intHorzTime = intHorzTimes(lastIntHorzTimeIndex);
    end
    if ~isempty(lastIntHorzTimeIndexTCA)
        metrics.intHorzTimeBeforeTCA = intHorzTimes(lastIntHorzTimeIndexTCA);
    end
    if ~isempty(lastIntHorzTimeIndex) && tca - intHorzTimes(lastIntHorzTimeIndex) < 5 % isTurningAtTCA
        metrics.isTurningAtTCA = 1;
    end

    % intVertTime; find times when there is a change in intruder altitude
    temp = diff(int_alt_ft) ~= 0;
    intVertTimes = find(diff(temp));
    anyIntVertManeuverBeforeTCA = any(temp);
    lastIntVertTimeIndex = find(intVertTimes <= numel(int_alt_ft), 1, 'last');
    lastIntVertTimeIndexTCA = find(intVertTimes <= tca, 1, 'last');
    if ~isempty(lastIntVertTimeIndex)
        metrics.intVertTime = intVertTimes(lastIntVertTimeIndex);
    end
    if ~isempty(lastIntVertTimeIndexTCA)
        metrics.intVertTimeBeforeTCA = intVertTimes(lastIntVertTimeIndexTCA);
    end
    if ~isempty(lastIntVertTimeIndex) && tca - intVertTimes(lastIntVertTimeIndex) < 5 % hasVerticalRateAtTCA
        metrics.hasVerticalRateAtTCA = 1;
    end

    % numNominalManeuvers; compute the number of horizontal/vertical maneuvers
    metrics.ownNumManeuversHorz = numel(ownHorzTimes);
    metrics.intNumManeuversHorz = numel(intHorzTimes);
    metrics.ownNumManeuversVert = numel(ownVertTimes);
    metrics.intNumManeuversVert = numel(intVertTimes);

    % compute the number of horizontal/vertical maneuvers before TCA
    metrics.ownNumManeuversHorzBeforeTCA = sum(ownHorzTimes < tca);
    metrics.intNumManeuversHorzBeforeTCA = sum(intHorzTimes < tca);
    metrics.ownNumManeuversVertBeforeTCA = sum(ownVertTimes < tca);
    metrics.intNumManeuversVertBeforeTCA = sum(intVertTimes < tca);

    % determine if the intruder has acceleration at TCA
    temp = abs(diff(int_gs_ftps)) ~= 0;
    intAccTimes = find(diff(temp));
    lastIntAccTimeIndex = find(intAccTimes < tca, 1, 'last');
    if ~isempty(lastIntAccTimeIndex) && tca - intAccTimes(lastIntAccTimeIndex) < 5 % hasAccelerationAtTCA
        metrics.hasAccelerationAtTCA = 1;
    end

    % compute the outputs
    ownHorzManeuverBeforeTCA = metrics.ownNumManeuversHorzBeforeTCA > 0;
    ownVertManeuverBeforeTCA = metrics.ownNumManeuversVertBeforeTCA > 0;
    intHorzManeuverBeforeTCA = metrics.intNumManeuversHorzBeforeTCA > 0;
    intVertManeuverBeforeTCA = metrics.intNumManeuversVertBeforeTCA > 0;
