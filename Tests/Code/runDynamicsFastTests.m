% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
% RUNDYNAMICSFASTTESTS This test involves inputting basic encounter events
% into runDynamicsFast to ensure proper responses. This includes testing
% different turn/climb rates.

% Load example encounter events
s = load([getenv('AEM_DIR_DAAENC'), '/Tests' filesep 'Test_Inputs' filesep 'dynamicsTestInputs.mat']);
s = s.s;
encId = 1;
plotFigures = false;
saveDirectory = [getenv('AEM_DIR_DAAENC'), '/Tests' filesep 'Test_Outputs' filesep 'DynamicsTests'];

%% Level flight
results = simulateDynamics(s.Level);
figNameExtension = 'Level';
plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension);

%% Horizontal turn
results = simulateDynamics(s.HorizontalTurn);
figNameExtension = 'HorizontalTurn';
plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension);

%% Climb
results = simulateDynamics(s.Climb);
figNameExtension = 'Climb';
plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension);

%% Descend
results = simulateDynamics(s.Descend);
figNameExtension = 'Descend';
plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension);

%% Encounter with turns and vertical rates (simultaneously?)
results = simulateDynamics(s.TurnAndVerticalRate);
figNameExtension = 'TurnAndVerticalRate';
plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension);

%% Acceleration
% Ownship decelerates to 0 and intruder increases speed -- plot speed plot
results = simulateDynamics(s.Accel);
figNameExtension = 'Accel';
plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension);

%% Test turn rate/vertical rate limits in runDynamicsFast
% Load test data
s = load([getenv('AEM_DIR_DAAENC'), '/Tests' filesep 'Test_Inputs' filesep 'dynamicsTestInputsLimits.mat']);
s = s.s_limits;
saveDirectory = [getenv('AEM_DIR_DAAENC'), '/Tests' filesep 'Test_Outputs' filesep 'DynamicsTestsLimits'];

% Test turn rate limit set to 3 degrees and commanded turn rate set to 1.5,
% 3, and 6 degrees -- plots for 3 degrees and 6 degrees should match
% 1.5 degrees
results = simulateDynamicsLimits(s.turn1_5);
figNameExtension = 'Turn1_5';
plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension);

% 3 degrees
results = simulateDynamicsLimits(s.turn3);
figNameExtension = 'Turn3';
plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension);

% 6 degrees
results = simulateDynamicsLimits(s.turn6);
figNameExtension = 'Turn6';
plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension);

% Test vertical rate limit set to 25 ft/s and commanded vertical rate set
% to 15, 25, and 50 ft/s. Ownship will climb and intruder will descend.
% Plots for 25 ft/s and 50 ft/s should match
% 15 ft/s
results = simulateDynamicsLimits(s.VertRate15);
figNameExtension = 'VertRate15';
plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension);

% 25 ft/s
results = simulateDynamicsLimits(s.VertRate25);
figNameExtension = 'VertRate25';
plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension);

% 50 ft/s
results = simulateDynamicsLimits(s.VertRate50);
figNameExtension = 'VertRate50';
plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension);
