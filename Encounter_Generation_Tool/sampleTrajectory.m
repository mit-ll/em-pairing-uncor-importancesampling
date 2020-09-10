% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function [waypoints, elevations] = sampleTrajectory(metadata,trajectoryDirectory,nSamps,duration,applyFilter,...
                                   minOwnAlt,maxOwnAlt,minOwnSpeed, maxOwnSpeed, minOwnAltType, maxOwnAltType, sampleByDuration)
% This function returns trajectory samples in the format expected by the
% Lincoln encounter model. nSamps samples with the specified duration will
% be drawn from trajectories contained in trajectoryDirectory. 
%
% If desired (appliedFilter = true), the user may elect to only sample
% encounters that meet altitude and speed constraints. 
%
% The user may also sample trajectories with longer durations more
% frequently (sampleByDuration = true). Otherwise, all trajectories will be
% sampled with equal probability.

    if nargin < 6
        %Unless otherwise specified, the default will be to sample from all
        %encounters
        applyFilter = 0;
        minOwnAlt = 0; % ft
        maxOwnAlt = Inf; % ft
        minOwnSpeed = 0; % kts
        maxOwnSpeed = Inf; % kts
        minOwnAltType = 'AGL';
        maxOwnAltType = 'AGL';
        sampleByDuration = 1; %weighted sample by trajectory duration 
    end
    
    constants = load_constants;
    elevations = zeros(1, nSamps);
    waypoints = cell(1,nSamps);

    %File with Track metadata (ids, max/min speed/altitude, track duration)
    filenames = metadata.filename;
    trackDuration = metadata.Track_length;
    minAlt_MSL = metadata.Min_Alt_msl;
    maxAlt_MSL = metadata.Max_Alt_msl;
    minSpeed = metadata.Min_Speed;
    maxSpeed = metadata.Max_Speed;
    minAlt_AGL = metadata.Min_Alt_agl;
    maxAlt_AGL = metadata.Max_Alt_agl;
    
    %Get track ids
    uniqueTrackId = metadata.trackId;
    numTracks = length(uniqueTrackId);
    pseudoTrackIds = 1:numTracks;
    
    if applyFilter
        %Use only tracks that pass the altitude/speed filters
        if strcmpi(minOwnAltType,'MSL')
            minAltIdx = minAlt_MSL>minOwnAlt;
        else
            minAltIdx = minAlt_AGL>minOwnAlt;
        end
        
        if strcmpi(maxOwnAltType,'MSL')
            maxAltIdx = maxAlt_MSL<maxOwnAlt;
        else
            maxAltIdx = maxAlt_AGL<maxOwnAlt;
        end
        
        selectedTypesIdx = minAltIdx & maxAltIdx & (minSpeed>minOwnSpeed) & (maxSpeed<maxOwnSpeed);
        if sum(selectedTypesIdx) == 0
            error('No trajectories with the specified filtering criteria are available');
        end
    else
        %Use all tracks, but ensure all tracks have altitudes and speeds >= 0
        selectedTypesIdx = minAlt_MSL>0 & minAlt_AGL>0 & minSpeed>0;
        if numel(selectedTypesIdx) == 0
            error('No trajectories are available');
        end
    end
    

    simTimes = trackDuration(selectedTypesIdx);
    selectedTracksTotalDuration = sum(trackDuration(selectedTypesIdx));

    if ~any(simTimes>=duration)
        error('Specified duration is longer than all trajectory samples for the specified aircraft types');
    end

    for j = 1:nSamps
        done = false;
        while ~done
            %Sample a random trajectory based on track duration from the
            %pool of aircraft we're interested in
            if sampleByDuration
                temp = randsample(pseudoTrackIds(selectedTypesIdx),1,true,trackDuration(selectedTypesIdx)./selectedTracksTotalDuration);
            else
                temp = randsample(pseudoTrackIds(selectedTypesIdx),1,true, ones(1,sum(selectedTypesIdx))); %Sample all tracks uniformly
            end

            %Load the Selected Trajectory
            y = importdata(fullfile(trajectoryDirectory, filesep, filenames{temp})); 
            
            %*Edit this section to match the format of your trajectories*
            simulationTime = y.data(:,2);
            latitude = y.data(:,3);
            longitude = y.data(:,4);
            altitude_AGL = y.data(:,5); 
            tas = y.data(:,6) * constants.kt2ftps; %Convert to feet/sec
            trueheading = deg2rad(y.data(:,7)); %Convert degrees to radians
            verticalspeed = y.data(:,8);

            sampleTime = max(simulationTime) - min(simulationTime);
            indices = 1:numel(simulationTime);

            if sampleTime < duration %trajectory is too short
                done = false;
                fprintf('Rejected sample; ');
                sprintf('Minimum duration is %i, sampled track has a duration of %i\n',duration,sampleTime)
                continue;
            else %Sample segment with desired duration from the trajectory
                done = true;
                startTimes = (sampleTime - duration);
                startTimeSample = randi(startTimes);
                trajSampIndices = indices(startTimeSample):indices(startTimeSample)+duration-1;
            end
        
        end

        %Format the sampled trajectory to be in the format required for
        %DEGAS encounters
        t = (0:duration-1)'; 
          
        lat = latitude(trajSampIndices);
        lon = longitude(trajSampIndices);

        %Convert latitude/longitude to x/y -- omit this step if your
        %trajectories are already in x/y
        x_pos = zeros(numel(trajSampIndices),1);
        y_pos = zeros(numel(trajSampIndices),1);
        numSamp = numel(trajSampIndices);
        for ns = 1:numSamp
            gref.lat_deg = lat(ns);
            gref.long_deg = lon(ns);
            % Use ground as ref point
            gref.altitude_m = 0;
            vecef = geod_to_ecef (gref);
            if ns == 1
                refpt = gref;
            end
            venu = ecef_to_enu(vecef, refpt);
            x_pos(ns) = venu.x / constants.ft2m; %x is in ft
            y_pos(ns) = venu.y / constants.ft2m; %y is in ft
        end          
        
        %Format into results struct used by DEGAS
        results.time = t;
        results.north_ft = y_pos;
        results.east_ft = x_pos;
        results.up_ft = altitude_AGL(trajSampIndices);
        results.speed_ftps = tas(trajSampIndices);
        results.psi_rad = trueheading(trajSampIndices); %heading
        results.theta_rad = asin((verticalspeed(trajSampIndices)/60)./results.speed_ftps); %pitch. convert vertical speed to feet per second
        dpsi = computeHeadingRate(results.psi_rad,t(1 : end)); %turn rate (rad/sec)
        results.phi_rad = atan(results.speed_ftps.*dpsi/constants.g); %yaw
          
        waypoints{j} = results;
        elevations(j) = maxAlt_MSL(temp)-maxAlt_AGL(temp);
    end
end
