% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
% RUNENCOUNTERWITHDEGASTESTS This test ensures that the output of the
% encounter generation tool (events and trajectories) can be simulated in
% DEGAS. This test requires the DEGAS repository.
%% Check for DEGAS
if isempty(getenv('DEGAS_HOME'))
    error('startup:degas_home', 'runEncounterWithDEGASTests requires the DEGAS repository. System environment variable, DEGAS_HOME, not found and assuming DEGAS is not installed\n Please ensure this repository is on your Matlab path before running this test. You can add it to your path by running startup.m in the DEGAS code directory.');
end

%%
curDur = pwd;

% Input encounter number to simulate
encNum = 1;

% File containing the encounters
encFile = [getenv('AEM_DIR_DAAENC'), '/Tests/Generated_Encounters/No_Quant/scriptedEncounters.mat'];

% Instantiate the simulation object
s = NominalEncounterClass;

% Setup the file to read the encounters from
% (uncorrelated vs. uncorrelated)
s.encounterFile = encFile;

% Switch to the directory that conains the simulation
simDir = which('NominalEncounter.slx');
[simDir, ~, ~] = fileparts(simDir);
cd(simDir);

% Setup the encounter. The encounter number is usually used as the input to
% the function to set the random seed used in the simulation
s.setupEncounter(encNum);

% Run the simulation
s.runSimulink(encNum);

%% Analyze results
% Plot the encounter geometry
s.plot;

%% If no errors, the test was a success
disp('runEncounterWithDEGASTests executed successfully');

%% Switch back to the encounter model tool directory
cd(curDur);
