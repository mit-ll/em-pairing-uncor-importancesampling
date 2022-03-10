% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
% RUNDYNAMICSFASTTESTS This test involves inputting basic encounter events
% into runDynamicsFast to ensure proper responses. This includes testing
% different turn/climb rates. The baseline results were generated using
% based on public commit e87e94a of https://github.com/Airspace-Encounter-Models/em-pairing-uncor-importancesampling

%% General inputs
encId = 1;
plotFigures = false;
saveDirectory = [getenv('AEM_DIR_DAAENC'), '/Tests' filesep 'Test_Outputs' filesep 'DynamicsTests'];

% Tolerance for radians
tol_rad = 1e-12;

%% level, horizontal turn, climb, descend, turns and vertical rates, acceleration
% Load example encounter events
data = load([getenv('AEM_DIR_DAAENC'), '/Tests' filesep 'Test_Inputs' filesep 'dynamicsTestInputs.mat'], 's', 'resultsBaseline');
s = data.s;
resultsBaseline = data.resultsBaseline;

% Determine number of fields and preallocate
fields = fieldnames(s);
n = numel(fields);
results = cell(size(n, 1));

% Simulate
for ii = 1:1:n
    results{ii} = simulateDynamics(s.(fields{ii}));

    if plotFigures
        plotExampleEncounter(results{ii}, encId, plotFigures, saveDirectory, figNameExtension);
    end
end

% Compare
for ii = 1:1:n
    for jj = 1:1:numel(resultsBaseline{ii})
        baseline = resultsBaseline{ii}(jj);
        new = results{ii}(jj);

        assert(all(baseline.time == new.time));
        assert(all(baseline.north_ft == new.north_ft));
        assert(all(baseline.east_ft == new.east_ft));
        assert(all(baseline.up_ft == new.up_ft));
        assert(all(baseline.speed_ftps == new.speed_ftps));
        assert(all(abs(baseline.phi_rad - new.phi_rad) <= tol_rad));
        assert(all(abs(baseline.theta_rad - new.theta_rad) <= tol_rad));
        assert(all(abs(baseline.psi_rad - new.psi_rad) <= tol_rad));
    end
end

%% Test turn rate/vertical rate limits in runDynamicsFast
% Turn rate span, 6 degrees, vertical rate span,
% vertical rate 15 ft/s, vertical rate 25 ft/s, vertical rate 50 ft/s
% Load test data
data = load([getenv('AEM_DIR_DAAENC'), '/Tests' filesep 'Test_Inputs' filesep 'dynamicsTestInputsLimits.mat'], 's_limits', 'resultsBaseline');
s = data.s_limits;
resultsBaseline = data.resultsBaseline;
saveDirectory = [getenv('AEM_DIR_DAAENC'), '/Tests' filesep 'Test_Outputs' filesep 'DynamicsTestsLimits'];

% Determine number of fields and preallocate
fields = fieldnames(s);
n = numel(fields);
results = cell(size(n, 1));

% Simulate
for ii = 1:1:n
    results{ii} = simulateDynamicsLimits(s.(fields{ii}));

    if plotFigures
        figNameExtension = fields{ii};
        plotExampleEncounter(results{ii}, encId, plotFigures, saveDirectory, figNameExtension);
    end
end

% Compare
for ii = 1:1:n
    for jj = 1:1:numel(resultsBaseline{ii})
        baseline = resultsBaseline{ii}(jj);
        new = results{ii}(jj);

        assert(all(baseline.time == new.time));
        assert(all(baseline.north_ft == new.north_ft));
        assert(all(baseline.east_ft == new.east_ft));
        assert(all(baseline.up_ft == new.up_ft));
        assert(all(baseline.speed_ftps == new.speed_ftps));
        assert(all(abs(baseline.phi_rad - new.phi_rad) <= tol_rad));
        assert(all(abs(baseline.theta_rad - new.theta_rad) <= tol_rad));
        assert(all(abs(baseline.psi_rad - new.psi_rad) <= tol_rad));
    end
end
