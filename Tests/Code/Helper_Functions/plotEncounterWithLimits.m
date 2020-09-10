% Copyright 2018 - 2020, MIT Lincoln Laboratory
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
if ~exist('saveDirectory','var')
    saveDirectory = pwd;
end

if ~exist(saveDirectory,'dir')
    mkdir(saveDirectory);
end

%Get constants
constants = load_constants;

%Load data
scriptedEncounters = load([outputFolder, '/scriptedEncounters.mat']);

%Get altitude and speed limits
maxOwnAlt_ft = iniSettings.maxOwnAlt_ft;
minOwnAlt_ft = iniSettings.minOwnAlt_ft;
maxIntAlt_ft = iniSettings.maxIntAlt_ft;
minIntAlt_ft = iniSettings.minIntAlt_ft;

maxOwnSpeed_kts = iniSettings.maxOwnSpeed_kts;
minOwnSpeed_kts = iniSettings.minOwnSpeed_kts;
maxIntSpeed_kts = iniSettings.maxIntSpeed_kts;
minIntSpeed_kts = iniSettings.minIntSpeed_kts;

%% Plot sample encounters
for i = 1:numExamples
    % Get encounter
    sample = scriptedEncounters.samples(i);

    % Simulate dynamics
    results = simulateDynamics(sample);

    % Altitude plot
    hExampleAltitude = figure('visible','off');
    subplot(2,1,1)
    plot(results(1).time,results(1).up_ft); % plot ownship altitude
    hold on;
    plot(results(1).time,ones(size(results(1).time))*maxOwnAlt_ft, 'k--') % plot ownship limits
    plot(results(1).time,ones(size(results(1).time))*minOwnAlt_ft, 'k--')
    legend('Ownship Altitude','Altitude Limits');
    xlabel('Time (sec)'); ylabel('Altitude (ft)')
    
    subplot(2,1,2)
    plot(results(2).time,results(2).up_ft); % plot intruder altitude
    hold on;
    plot(results(2).time,ones(size(results(2).time))*maxIntAlt_ft, 'k--') % plot intruder limits
    plot(results(2).time,ones(size(results(2).time))*minIntAlt_ft, 'k--')
    legend('Intruder Altitude','Altitude Limits');
    xlabel('Time (sec)'); ylabel('Altitude (ft)')
    
    % Speed Plot
    hExampleSpeed = figure('visible','off');
    subplot(2,1,1)
    plot(results(1).time,results(1).speed_ftps/constants.kt2ftps); % plot ownship speed
    hold on;
    plot(results(1).time,ones(size(results(1).time))*maxOwnSpeed_kts, 'k--') % plot ownship limits
    plot(results(1).time,ones(size(results(1).time))*minOwnSpeed_kts, 'k--')
    legend('Ownship Speed','Speed Limits');
    xlabel('Time (sec)'); ylabel('Speed (kts)')
    
    subplot(2,1,2)
    plot(results(2).time,results(2).speed_ftps/constants.kt2ftps); % plot intruder speed
    hold on;
    plot(results(2).time,ones(size(results(2).time))*maxIntSpeed_kts, 'k--') % plot intruder limits
    plot(results(2).time,ones(size(results(2).time))*minIntSpeed_kts, 'k--')
    legend('Intruder Speed','Speed Limits');
    xlabel('Time (sec)'); ylabel('Speed (kts)')
    
    % Save or display figures
    if plotFigures
        hExampleAltitude.Visible = true;
        hExampleSpeed.Visible = true;
    else
        set(hExampleAltitude, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
        set(hExampleSpeed, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');

        saveas(hExampleAltitude, [saveDirectory, '/EncounterWithLimits' num2str(i) '_AltitudeLimits.fig']);
        saveas(hExampleSpeed, [saveDirectory, '/EncounterWithLimits' num2str(i) '_SpeedLimits.fig']);    
    end
    
end

end