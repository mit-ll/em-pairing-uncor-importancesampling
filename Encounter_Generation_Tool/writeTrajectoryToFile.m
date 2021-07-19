function writeTrajectoryToFile (traj1, traj2, encId, encounterDir)
% Copyright 2018 - 2021, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
% Write input trajectories to a .txt file
%
% Inputs:
%   traj1, traj2            Ownship and intruder trajectories
%   encId                   Encounter ID
%   encounterDir            Output directory for encounter results;
%
% Outputs:
% encId.txt that contains:
%       [SHIP]_east_ft      East (feet)
%       [SHIP]_north_ft     North (feet)
%       [SHIP]_alt_ft       Altitude (feet)
%       [SHIP]_trk_rad      Track heading (rad)
%       [SHIP]_speed_ftps   Airspeed (feet per second)
%       [SHIP]_dh_ftps      Vertical speed (feet per second)
%       [SHIP]_time_s       Time (seconds)

% Create directory
if ~exist(encounterDir,'dir')
    mkdir(encounterDir);
end

% Open file and set up header
filename = [encounterDir filesep num2str(encId) '.txt'];
fid = fopen (filename, 'w' ,'native', 'UTF-8');
fprintf (fid, 'NAME,          east,   north,   alt,   hdg,    speed,    dh,    time\n');
fprintf (fid, 'unitless,      [ft],   [ft],   [ft],  [rad],  [ftps],  [ftps], [s]\n');

% Write ownship trajectory to file
for ii = 1:numel(traj1.time) - 1
    fprintf (fid, 'OWNSHIP, %.3f, %.3f, %.3f, %.2f, %.2f, %.2f, %.1f\n', ...
        traj1.east_ft(ii), traj1.north_ft(ii), ...
        traj1.up_ft(ii), traj1.psi_rad(ii), ...
        traj1.speed_ftps(ii), traj1.speed_ftps(ii).*sin(traj1.theta_rad(ii)), ...
        traj1.time(ii));
end

% Write intruder trajectory to file
for ii = 1:numel(traj2.time) - 1
    fprintf (fid, 'INTRUDER, %.3f, %.3f, %.3f, %.2f, %.2f, %.2f, %.1f\n', ...
        traj2.east_ft(ii), traj2.north_ft(ii), ...
        traj2.up_ft(ii), traj2.psi_rad(ii), ...
        traj2.speed_ftps(ii), traj2.speed_ftps(ii).*sin(traj2.theta_rad(ii)), ...
        traj2.time(ii));
end

% Close file
fclose (fid);
