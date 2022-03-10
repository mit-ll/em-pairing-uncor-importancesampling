% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function plotEncounterWithLimits(outputFolder, plotFigures, saveDirectory, numExamples, iniSettings)
    % The purpose of this function is to plot the altitude and speed of
    % generated encounters to check that they are within the desired min/max
    % altitude/speed limits.
    %
    % Inputs:
    % outputFolder - folder containing the encounters
    % plotFigures - if 1, figures are plotted. If 0, figures are saved in
    %   saveDirectory
    % saveDirectory - where plots should be saved
    % numExamples - how may example encounters should be plotted
    % iniSettings - contains the altitude/speed limits

    %% Set up directories
    if ~exist('saveDirectory', 'var')
        saveDirectory = pwd;
    end

    if ~exist(saveDirectory, 'dir')
        mkdir(saveDirectory);
    end

    % Get constants
    constants = load_constants;

    % Load data
    scriptedEncounters = load([outputFolder, '/scriptedEncounters.mat']);

    % Get altitude and speed limits
    maxOwnAlt_ft = iniSettings.maxOwnAlt_ft;
    minOwnAlt_ft = iniSettings.minOwnAlt_ft;
    maxIntAlt_ft = iniSettings.maxIntAlt_ft;
    minIntAlt_ft = iniSettings.minIntAlt_ft;

    maxOwnSpeed_kts = iniSettings.maxOwnSpeed_kts;
    minOwnSpeed_kts = iniSettings.minOwnSpeed_kts;
    maxIntSpeed_kts = iniSettings.maxIntSpeed_kts;
    minIntSpeed_kts = iniSettings.minIntSpeed_kts;

    minOwnSpeeds = zeros(1, numExamples);
    maxOwnSpeeds = zeros(1, numExamples);
    maxIntSpeeds = zeros(1, numExamples);
    minIntSpeeds = zeros(1, numExamples);

    minOwnAlts = zeros(1, numExamples);
    maxOwnAlts = zeros(1, numExamples);
    maxIntAlts = zeros(1, numExamples);
    minIntAlts = zeros(1, numExamples);

    %% Plot sample encounters
    for i = 1:numExamples
        % Get encounter
        sample = scriptedEncounters.samples(i);

        % Simulate dynamics
        results = simulateDynamics(sample);

        minOwnSpeeds(i) = min(results(1).speed_ftps / constants.kt2ftps);
        maxOwnSpeeds(i) = max(results(1).speed_ftps / constants.kt2ftps);
        minIntSpeeds(i) = min(results(2).speed_ftps / constants.kt2ftps);
        maxIntSpeeds(i) = max(results(2).speed_ftps / constants.kt2ftps);

        minOwnAlts(i) = min(results(1).up_ft);
        maxOwnAlts(i) = max(results(1).up_ft);
        minIntAlts(i) = min(results(2).up_ft);
        maxIntAlts(i) = max(results(2).up_ft);

        fprintf('Finished Encounter %i\n\n', i);
    end

    % Max Own Altitude plot
    hMaxOwnAltitude = figure('visible', 'off');
    histogram(maxOwnAlts);
    title('Max Ownship Altitude Over Encounter');
    xlabel('Altitude (ft)');
    ylabel('Frequency');

    % Min Own Altitude plot
    hMinOwnAltitude = figure('visible', 'off');
    histogram(minOwnAlts);
    title('Min Ownship Altitude Over Encounter');
    xlabel('Altitude (ft)');
    ylabel('Frequency');

    % Max Own Speed plot
    hMaxOwnSpeed = figure('visible', 'off');
    histogram(maxOwnSpeeds);
    title('Max Ownship Speed Over Encounter');
    xlabel('Speed (kts)');
    ylabel('Frequency');

    % Min Own Speed plot
    hMinOwnSpeed = figure('visible', 'off');
    histogram(minOwnSpeeds);
    title('Min Ownship Speed Over Encounter');
    xlabel('Speed (kts)');
    ylabel('Frequency');
    % -----------------
    % Max Int Altitude plot
    hMaxIntAltitude = figure('visible', 'off');
    histogram(maxIntAlts);
    title('Max Intruder Altitude Over Encounter');
    xlabel('Altitude (ft)');
    ylabel('Frequency');

    % Min Int Altitude plot
    hMinIntAltitude = figure('visible', 'off');
    histogram(minIntAlts);
    title('Min Intruder Altitude Over Encounter');
    xlabel('Altitude (ft)');
    ylabel('Frequency');

    % Max Int Speed plot
    hMaxIntSpeed = figure('visible', 'off');
    histogram(maxIntSpeeds);
    title('Max Intruder Speed Over Encounter');
    xlabel('Speed (kts)');
    ylabel('Frequency');

    % Min Int Speed plot
    hMinIntSpeed = figure('visible', 'off');
    histogram(minIntSpeeds);
    title('Min Intruder Speed Over Encounter');
    xlabel('Speed (kts)');
    ylabel('Frequency');

    % Save or display figures
    if plotFigures
        hMaxOwnAltitude.Visible = true;
        hMinOwnAltitude.Visible = true;
        hMaxIntAltitude.Visible = true;
        hMinIntAltitude.Visible = true;
        hMaxOwnSpeed.Visible = true;
        hMinOwnSpeed.Visible = true;
        hMaxIntSpeed.Visible = true;
        hMinIntSpeed.Visible = true;
    else
        set(hMaxOwnAltitude, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
        set(hMinOwnAltitude, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
        set(hMaxIntAltitude, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
        set(hMinIntAltitude, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
        set(hMaxOwnSpeed, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
        set(hMinOwnSpeed, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
        set(hMaxIntSpeed, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
        set(hMinIntSpeed, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');

        saveas(hMaxOwnAltitude, [saveDirectory, '/EncounterWithLimits' num2str(i) '_MaxOwnAlt.fig']);
        saveas(hMinOwnAltitude, [saveDirectory, '/EncounterWithLimits' num2str(i) '_MinOwnAlt.fig']);
        saveas(hMaxIntAltitude, [saveDirectory, '/EncounterWithLimits' num2str(i) '_MaxIntAlt.fig']);
        saveas(hMinIntAltitude, [saveDirectory, '/EncounterWithLimits' num2str(i) '_MinIntAlt.fig']);
        saveas(hMaxOwnSpeed, [saveDirectory, '/EncounterWithLimits' num2str(i) '_MaxOwnSpeed.fig']);
        saveas(hMinOwnSpeed, [saveDirectory, '/EncounterWithLimits' num2str(i) '_MinOwnSpeed.fig']);
        saveas(hMaxIntSpeed, [saveDirectory, '/EncounterWithLimits' num2str(i) '_MaxIntSpeed.fig']);
        saveas(hMinIntSpeed, [saveDirectory, '/EncounterWithLimits' num2str(i) '_MinIntSpeed.fig']);
    end

end
