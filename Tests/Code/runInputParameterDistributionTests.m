% RUNINPUTPARAMETERDISTRIUTIONTESTS These tests will produce plots of the
% resulting distributions of ownship/intruder speed/altitudes at TCA given
% different input parameters as well as the corresponding VMD/HMD
% distributions.

% Setup the directory path
cd(getenv('AEM_DIR_DAAENC'));

%% Set unit test settings
% Encounter model distributions will typically not follow a known
% distribution (e.g., Gaussian) and thus, the unit tests will consist of a
% visual inspection of resulting distributions to ensure satisfactory
% alignment with expectations. The figures may be displayed when the tests
% are run or saved for later analysis.

plotFigures = false; % True to display distributions, False to save distributions
weighted = false; % True to apply encounter weights when plotting the distributions
numExamples = 2; % Number of example encounters to plot

%% With and without 500 ft quantization
% 1 uncorrelated encounter model aircraft vs. 1 uncorrelated encounter
% model aircraft

% Start test
disp('***Running Input Verification: 500ft Quantization***');

% With 500 ft quantization
parameterFile = ['Tests' filesep 'Test_Inputs' filesep 'UncorVsUncor_500ft.ini']; 

% Generate 10,000 encounters
evalc('generateDAAEncounterSet(parameterFile)');

% Plot distributions
iniSettings = ini2struct(parameterFile);
outputDirectory = iniSettings.saveDirectory; % Where the generated encounters are
testDirectory = iniSettings.testDirectory; % Where to save the test plots
plotDistributions(outputDirectory, plotFigures, testDirectory, numExamples, weighted); 

% Test weighted plots
weightedTemp = ~weighted;
plotDistributions(outputDirectory, plotFigures, testDirectory, numExamples, weightedTemp); 

% Start test
disp('***Running Input Verification: No Quantization***');

% Without 500 ft quantization
parameterFile = ['Tests' filesep 'Test_Inputs' filesep 'UncorVsUncor_noQuant.ini']; 

% Generate 10,000 encounters
evalc('generateDAAEncounterSet(parameterFile)');

% Plot distributions
iniSettings = ini2struct(parameterFile);
outputDirectory = iniSettings.saveDirectory; % Where the generated encounters are
testDirectory = iniSettings.testDirectory; % Where to save the test plots
plotDistributions(outputDirectory, plotFigures, testDirectory, numExamples, weighted); 

%% Different speed/altitude distributions
% Start test
disp('***Running Input Verification: HALE vs. MALE***');

% 1 HALE aircraft vs. 1 MALE aircraft
parameterFile = ['Tests' filesep 'Test_Inputs' filesep 'HaleVsMale.ini']; 

% Generate 10,000 encounters
evalc('generateDAAEncounterSet(parameterFile)');

%Plot distributions
iniSettings = ini2struct(parameterFile);
outputDirectory = iniSettings.saveDirectory; % Where the generated encounters are
testDirectory = iniSettings.testDirectory; % Where to save the test plots
plotDistributions(outputDirectory, plotFigures, testDirectory, numExamples, weighted); 

%% Test min/max altitudes and min/max speeds
% Start test
disp('***Running Input Verification: Max/Min Limits at CPA***');

% Limits checked at CPA
parameterFile = ['Tests' filesep 'Test_Inputs' filesep 'UncorVsUncor_MinMaxLimitsAtCPA.ini']; 

% Generate 10,000 encounters
evalc('generateDAAEncounterSet(parameterFile)');

%Plot distributions
iniSettings = ini2struct(parameterFile);
outputDirectory = iniSettings.saveDirectory; % Where the generated encounters are
testDirectory = iniSettings.testDirectory; % Where to save the test plots
plotDistributions(outputDirectory, plotFigures, testDirectory, numExamples, weighted); 

% Start test
disp('***Running Input Verification: Max/Min Limits Over Entire Encounter***');

% Limits checked over entire encounter
parameterFile = ['Tests' filesep 'Test_Inputs' filesep 'UncorVsUncor_MinMaxLimits.ini']; 

% Generate 10,000 encounters
generateDAAEncounterSet(parameterFile);

% Plot distributions
iniSettings = ini2struct(parameterFile);
outputDirectory = iniSettings.saveDirectory; % Where the generated encounters are
testDirectory = iniSettings.testDirectory; % Where to save the test plots

% Check 5 or so encounters by plotting altitude/speed over the entire
% encounter with bands indicating the altitude/speed limits
numExamples = 5;
plotEncounterWithLimits(outputDirectory, plotFigures, testDirectory, numExamples, iniSettings);

numExamples = 10000;
plotEncounterWithLimits_Distribution(outputDirectory, plotFigures, testDirectory, numExamples, iniSettings);

%% Test ability to generate encounters from trajectories
% This test generates a small number of encounters generated from 100
% trajectories sampled from the Uncorrelated Encounter Model

% Start test
disp('***Running Input Verification: Encounters from Trajectories***');

% Phase 1 UAS vs. Phase 1 UAS
parameterFile = ['Tests' filesep 'Test_Inputs' filesep 'TrajVsTraj.ini'];  

% Generate 5 encounters
evalc('generateDAAEncounterSet(parameterFile)');

%Plot example encounters
iniSettings = ini2struct(parameterFile);
scriptedEncounters = load([iniSettings.saveDirectory, '/scriptedEncounters.mat']);
for i = 1:5
    figNameExtension = 'TrajVsTraj';
    sample = scriptedEncounters.samples(i);    
    results = simulateDynamics(sample); % Simulate dynamics
    plotExampleEncounter(results, i, plotFigures, iniSettings.testDirectory, figNameExtension) 
end

disp('Input parameter tests are complete!');