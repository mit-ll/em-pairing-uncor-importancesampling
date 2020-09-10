% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
% RUNTRAJECTORYEVENTSVERIFICATIONTESTS The purpose of this test is to
% ensure that the tools used to convert waypoints to events and vice versa
% function properly. These tools are pivotal to being able to generate
% encounters from both encounter model events and user-defined
% trajectories/waypoints.

% The plots from the following two tests should be identical.
%% Test events to waypoints (runDynamicsFast)
% Events --> runDynamicsFast --> Waypoints --> Plot (read from waypoints
% file)
plotFigures = false;

% Load example encounter events
s = load([getenv('AEM_DIR_DAAENC') filesep 'Tests' filesep 'Test_Inputs' filesep 'dynamicsTestInputs.mat']);
s = s.s;
results = simulateDynamics(s.TurnAndVerticalRate); %Change desired test encounter here. Trajectory was previously verified in runDynamicsFastTests.m
encId = 1;
saveDirectory = [getenv('AEM_DIR_DAAENC'), '/Tests' filesep 'Test_Outputs' filesep 'TrajectoryEventTests'];

%Generate waypoints file
writeTrajectoryToFile(results(1), results(2), encId, saveDirectory);

%Read waypoints file and plot
ownshipIdentifier = 'OWNSHIP'; 
intruderIdentifier = 'INTRUDER';
waypointResults = readTrajFiles(encId, saveDirectory,ownshipIdentifier,intruderIdentifier);
figNameExtension = '_events2waypoints';
plotExampleEncounter(waypointResults, encId, plotFigures, saveDirectory, figNameExtension);    

%% Test waypoints to events (wpt2script)
% Waypoints File --> wpt2script --> scripted encounter --> runDynamicsFast
% --> Plot

%Read encounter file generated in previous section and get waypoints
encId = 1; 
encFolder = saveDirectory;
ownshipIdentifier = 'OWNSHIP'; 
intruderIdentifier = 'INTRUDER';
results = readTrajFiles(encId, encFolder, ownshipIdentifier, intruderIdentifier);
wp1 = results(1);
wp2 = results(2);

altLayers = [500, 1200; 1200, 3000; 3000, 5000; 5000, 18000]; %ft
scriptedEncounter = wpt2script(wp1, wp2, encId, altLayers);

%Simulate scripted encounter and plot
scriptedResults = simulateDynamics(scriptedEncounter);
saveDirectory = [getenv('AEM_DIR_DAAENC'), '/Tests/Test_Outputs/TrajectoryEventTests'];
figNameExtension = '_waypoints2events';
plotExampleEncounter(scriptedResults, encId, plotFigures, saveDirectory, figNameExtension);

%% Pass/fail for the unit test
%Pass if e/n/u match for the waypoint and scripted versions of the
%encounter. Deviations may occur because heading and altitude commands are
%not executed instantaneously and thus, cannot be captured with 100%
%accuracy from the waypoints.
if all(abs(waypointResults(1).north_ft-scriptedResults(1).north_ft)<1000)
    disp('PASS: Ownship North matches');
else
    disp('FAIL: Ownship North does not match');
end

if all(abs(waypointResults(1).east_ft-scriptedResults(1).east_ft)<1000)
    disp('PASS: Ownship East matches');
else
    disp('FAIL: Ownship East does not match');
end

if all(abs(waypointResults(1).up_ft-scriptedResults(1).up_ft)<1000)
    disp('PASS: Ownship Altitude matches');
else
    disp('FAIL: Ownship Altitude does not match');
end

if all(abs(waypointResults(2).north_ft-scriptedResults(2).north_ft)<1000)
    disp('PASS: Intruder North matches');
else
    disp('FAIL: Intruder North does not match');
end

if all(abs(waypointResults(2).east_ft-scriptedResults(2).east_ft)<1000)
    disp('PASS: Intruder East matches');
else
    disp('FAIL: Intruder East does not match');
end

if all(abs(waypointResults(2).up_ft-scriptedResults(2).up_ft)<1000)
    disp('PASS: Intruder Altitude matches');
else
    disp('FAIL: Intruder Altitude does not match');
end