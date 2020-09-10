% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function plotDistributions(outputFolder, plotFigures, saveDirectory, numExamples, weighted)
% The purpose of this function is to plot the altitude/speed distributions
% of encounters for validation.
%
% Inputs:
% outputFolder - folder containing the encounters
% plotFigures - if 1, figures are plotted. If 0, figures are saved in
%   saveDirectory
% saveDirectory - where plots should be saved
% numExamples - how may example encounters should be plotted
% weighted - whether to use encounter weights when plotting the
%   distributions

%% Set up directories
if ~exist('saveDirectory','var')
    saveDirectory = pwd;
end

if ~exist('numExamples','var')
    numExamples = 2; % number of example encounters to plot 
end

if ~exist(saveDirectory,'dir')
    mkdir(saveDirectory);
end

%Load data
metaData = load([outputFolder, '/metaData.mat']);
scriptedEncounters = load([outputFolder, '/scriptedEncounters.mat']);

if ~weighted %unweighted plots
    %% Ownship altitude/speed at TCA
    hOwnAlt = figure('visible','off');
    histogram([metaData.enc_metadata.ownHeightAtTCA_ft]);
    title('Own Altitude at TCA');
    xlabel('Altitude (ft)'); ylabel('Frequency');

    hOwnSpeed = figure('visible','off');
    histogram([metaData.enc_metadata.ownSpeedAtTCA_kt]);
    title('Own Speed at TCA');
    xlabel('Speed (kts)'); ylabel('Frequency');

    %% Intruder altitude/speed at TCA
    hIntAlt = figure('visible','off');
    histogram([metaData.enc_metadata.intHeightAtTCA_ft]);
    title('Intruder Altitude at TCA');
    xlabel('Altitude (ft)'); ylabel('Frequency');

    hIntSpeed = figure('visible','off');
    histogram([metaData.enc_metadata.intSpeedAtTCA_kt]);
    title('Intruder Speed at TCA');
    xlabel('Speed (kts)'); ylabel('Frequency');

    %% VMD/HMD
    hHMD = figure('visible','off');
    histogram([metaData.enc_metadata.hmd]);
    title('HMD');
    xlabel('ft'); ylabel('Frequency');

    hVMD = figure('visible','off');
    histogram([metaData.enc_metadata.vmd]);
    title('VMD');
    xlabel('ft'); ylabel('Frequency');
else %weighted plots
    %% Ownship altitude/speed at TCA
    hOwnAlt = figure('visible','off');
    hist_w1d([metaData.enc_metadata.ownHeightAtTCA_ft]','w',[metaData.enc_metadata.w]','plotResults',true);
    title('Own Altitude at TCA (Weighted)');
    xlabel('Altitude (ft)'); ylabel('Frequency');

    hOwnSpeed = figure('visible','off');
    hist_w1d([metaData.enc_metadata.ownSpeedAtTCA_kt]','w',[metaData.enc_metadata.w]','plotResults',true);
    title('Own Speed at TCA (Weighted)');
    xlabel('Speed (kts)'); ylabel('Frequency');

    %% Intruder altitude/speed at TCA
    hIntAlt = figure('visible','off');
    hist_w1d([metaData.enc_metadata.intHeightAtTCA_ft]','w',[metaData.enc_metadata.w]','plotResults',true);
    title('Intruder Altitude at TCA (Weighted)');
    xlabel('Altitude (ft)'); ylabel('Frequency');

    hIntSpeed = figure('visible','off');
    hist_w1d([metaData.enc_metadata.intSpeedAtTCA_kt]','w',[metaData.enc_metadata.w]','plotResults',true);
    title('Intruder Speed at TCA (Weighted)');
    xlabel('Speed (kts)'); ylabel('Frequency');

    %% VMD/HMD
    hHMD = figure('visible','off');
    hist_w1d([metaData.enc_metadata.hmd]','w',[metaData.enc_metadata.w]','plotResults',true);
    title('HMD (Weighted)');
    xlabel('ft'); ylabel('Frequency');

    hVMD = figure('visible','off');
    hist_w1d([metaData.enc_metadata.vmd]','w',[metaData.enc_metadata.w]','plotResults',true);
    title('VMD (Weighted)');
    xlabel('ft'); ylabel('Frequency');
end
%% Plot sample encounters
for i = 1:numExamples
    sample = scriptedEncounters.samples(i);
    results = simulateDynamics(sample);
    plotExampleEncounter(results, i, plotFigures, saveDirectory);
    
end

%% Save or plot figures
if plotFigures
%Plot figures
hOwnAlt.Visible = true;
hOwnSpeed.Visible = true;
hIntAlt.Visible = true;
hIntSpeed.Visible = true;
hVMD.Visible = true;
hHMD.Visible = true;

else
%Save figures if they are not plotted
set(hOwnAlt, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
set(hOwnSpeed, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
set(hIntAlt, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
set(hIntSpeed, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
set(hVMD, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
set(hHMD, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');

saveas(hOwnAlt, [saveDirectory, '/OwnAltAtTCA.fig']);
saveas(hOwnSpeed, [saveDirectory, '/OwnSpeedAtTCA.fig']);
saveas(hIntAlt, [saveDirectory, '/IntAltAtTCA.fig']);
saveas(hIntSpeed, [saveDirectory, '/IntSpeedAtTCA.fig']);
saveas(hVMD, [saveDirectory, '/VMD.fig']);
saveas(hHMD, [saveDirectory, '/HMD.fig']);

end
