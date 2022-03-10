% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
% RUNPNMACGASMODELTESTS This script verifies that P(NMAC|successively larger
% volumes) matches the encounter model (gas) assumptions. This script
% assumes that you have already run runInputParameterDistributionTests.m

% Setup the directory path
cd(getenv('AEM_DIR_DAAENC'));

plotFigures = false; % True to display plots with results, False to save plots
saveFolder = [getenv('AEM_DIR_DAAENC'), '/Tests' filesep 'Test_Outputs' filesep 'PNMAC_GasModel']; % Where to save plots

%% Read in set of 10,000 test encounters generated using Uncorrelated Encounter Model
encounterFile = [getenv('AEM_DIR_DAAENC') filesep 'Tests' filesep 'Generated_Encounters' filesep 'No_Quant' filesep 'scriptedEncounters.mat'];
x = load(encounterFile);
numEncounters = numel(x.samples);

% Get encounter weights
metadataFile = [getenv('AEM_DIR_DAAENC') filesep 'Tests' filesep 'Generated_Encounters' filesep 'No_Quant' filesep 'metaData.mat'];
metadata = load(metadataFile);
weights = [metadata.enc_metadata.w];

constants = load_constants;

nmacs = zeros(1, numEncounters);

% Cylinder sizes
radii = [0.5, 1, 2, 3]; % NM. Minimum initial separation is only 1.5 NM
height = 1000;

isInCyl = zeros(numEncounters, numel(radii)); % Whether the intruder penetrates a cylinder with a given volume centered on the ownship

for encNum = 1:numEncounters
    % Simulate the dynamics
    results = simulateDynamics(x.samples(encNum));

    % Determine if there is an NMAC
    [~, ~, ~, nmacs(encNum)] = getCPAMetrics(results(1), results(2));

    % Determine if the encounter penetrates the cylinder volume
    isInCyl(encNum, :) = getCylinderPenetration(results(1), results(2), radii * constants.nm2ft, height);
end

% Compute P(NMAC|successively larger volumes)
numInCyl = sum(isInCyl);
pNMAC = zeros(1, numel(radii));
nBootCISamples = 1000;
confidence_interval = zeros(numel(radii), 2);
for r = 1:numel(radii)
    pNMAC(r) = sum(weights .* nmacs) ./ sum(weights' .* isInCyl(:, r)); % apply encounter weights

    % Compute confidence interval for the pNMAC estimate
    confidence_interval(r, :) = bootci(nBootCISamples, {@(x, y)sum(x) / sum(y), weights .* nmacs, weights' .* isInCyl(:, r)}, 'type', 'cper');
end

% Round to the nearest 3 decimal places
confidence_interval = round(confidence_interval, 3);

%% Compute P(NMAC|successively larger volumes) for encounter model (gas) assumptions
% P(NMAC | enc) = h_nmac*v_nmac/h_enc/v_enc
h_nmac_ft = 500;
v_nmac_ft = 100;
h_enc_ft = radii * constants.nm2ft;
v_enc_ft = 1000;

pNMAC_gas = h_nmac_ft * v_nmac_ft ./ h_enc_ft / v_enc_ft;
pNMAC_gas = round(pNMAC_gas, 3);

%% Compare pNMAC from encounter model and gas model
% Plot results and save in folder to view later
h_pNMAC = figure('visible', 'off');
errorbar(radii, pNMAC, pNMAC' - confidence_interval(:, 1), confidence_interval(:, 2) - pNMAC', 'o-');
hold on;
plot(radii, pNMAC_gas, 'o-');
legend('Encounter Model Tool', 'Gas Model Assumptions');
xlim([0, 3.5]);
ylabel('p(NMAC)');
xlabel('Radius (NM)');

if plotFigures
    % Plot figures
    h_pNMAC.Visible = true; %#ok (Unreachable statement when plotFigures is false)
else
    % Save figures if they are not plotted
    set(h_pNMAC, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');

    if ~exist(saveFolder, 'dir')
        mkdir(saveFolder);
    end

    saveas(h_pNMAC, [saveFolder, filesep 'pNMAC.fig']);
end

% Test passes if P(NMAC) from the gas model lies within the confidence
% interval for P(NMAC) computed from generated encounters or if difference
% between encounter model and gas model P(NMAC) is < .01.
withinConfidenceInterval = all(confidence_interval(:, 2) >= pNMAC_gas' & pNMAC_gas' >= confidence_interval(:, 1));
lessThan0_1 = all(abs(pNMAC - pNMAC_gas) < .01);

% Display results of test
if withinConfidenceInterval || lessThan0_1
    disp('PASSED: Encounter set passes Gas Model test:');
    if withinConfidenceInterval
        disp('Gas model P(NMAC) is within confidence intervals for encounter model P(NMAC).');
    end
    if lessThan0_1
        disp('Difference between encounter model and gas model P(NMAC) is < .01.');
    end

else
    disp('FAILED: Encounter set fails Gas Model test Gas model:');
    disp('Difference between encounter model and gas model P(NMAC) is > .01, and gas model P(NMAC) is outside of confidence intervals for encounter model P(NMAC).');
end
