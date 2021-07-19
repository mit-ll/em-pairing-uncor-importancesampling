function scriptedEncounter = wpt2script(wp1, wp2, id, altLayers)
% Pass in the waypoint trajectories (wp1, wp2)
% Copyright 2018 - 2021, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11

% Get generic encounter information
scriptedEncounter = ScriptedEncounter;
scriptedEncounter.id = id;
scriptedEncounter.numberOfAircraft = 2;
scriptedEncounter.runTime_s = max(wp1.time);
scriptedEncounter.altLayer = find(wp1.up_ft(1)<altLayers(:,2),1);

% Get information specific to each aircraft
scriptedEncounter = getscript(wp1, 1, scriptedEncounter);
scriptedEncounter = getscript(wp2, 2, scriptedEncounter);
end

%% HELPER FUNCTION
function scriptedEncounterOut = getscript(wp, index, scriptedEncounterIn)
scriptedEncounterOut = scriptedEncounterIn;
%Using 1:10:end indexing to get updates at 1hz instead of 10hz
t_s = wp.time(1:10:end); % time (sec)
n_ft = wp.north_ft(1:10:end); % north (ft)
e_ft = wp.east_ft(1:10:end); % east (ft)
h_ft = wp.up_ft(1:10:end); % altitude (ft)
s_ft_s = wp.speed_ftps(1:10:end); % speed (ft/s)
heading_rad = wp.psi_rad(1:10:end); % heading (rad)

% vertical rate
dh_ft_s = computeVerticalRate(h_ft,t_s,'mode','gradient');

% airspeed acceleration
a_ft_s2 = computeAcceleration(s_ft_s,t_s,'mode','gradient'); %ft/s2

% turn rate
[dpsi_rad_s,~,~] = computeHeadingRate(heading_rad, t_s); % rad per second

% Get initial conditions: Airspeed (ft/s), E/N/U position (ft), Heading
% (rad), Pitch (rad), Bank (rad), Acceleration (ft/s2)
scriptedEncounterOut.v_ftps(index) = s_ft_s(1);
scriptedEncounterOut.n_ft(index) = n_ft(1);
scriptedEncounterOut.e_ft(index) = e_ft(1);
scriptedEncounterOut.h_ft(index) = h_ft(1);
scriptedEncounterOut.heading_rad(index) = wp.psi_rad(1);
scriptedEncounterOut.pitch_rad(index) = wp.theta_rad(1);
scriptedEncounterOut.bank_rad(index) = wp.phi_rad(1);
scriptedEncounterOut.a_ftpss(index) = a_ft_s2(1);

% Get updates: Time (sec), Vertical Rate (ft/s), Turn Rate (rad/s),
% Acceleration (ft/s2)
event = [t_s dh_ft_s dpsi_rad_s a_ft_s2];

% Weed out any updates where dh, dpsi, and a are all < 0.005
zeroUpdateIndices = [0; abs(diff(dh_ft_s))<.005 & abs(diff(dpsi_rad_s))<deg2rad(.005) & abs(diff(a_ft_s2))<.005];

% update
scriptedEncounterOut.updates(index).event = event(~zeroUpdateIndices,:);
end
