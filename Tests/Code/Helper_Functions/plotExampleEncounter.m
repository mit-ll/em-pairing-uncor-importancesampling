% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function plotExampleEncounter(results, encId, plotFigures, saveDirectory, figNameExtension)
% The purpose of this function is to plot the altitude and plan view of
% generated encounters for validation.
%
% Inputs:
% results - a struct containing the ownship/intruder trajectories
% encId - ID of the encounter being plotted
% plotFigures - if 1, figures are plotted. If 0, figures are saved in
%   saveDirectory
% saveDirectory - where plots should be saved
% figNameExtension - an optional string that is added to the filename of
%   figures when saved (to distinguish among different test cases)

%% Set up directories
if ~exist(saveDirectory,'dir')
    mkdir(saveDirectory);
end

if ~exist('figNameExtension','var')
    figNameExtension = '';
end

if ~exist(saveDirectory,'dir')
    mkdir(saveDirectory);
end

%% Plot sample encounters
% Altitude plot
hExampleAltitude = figure('visible','off');
plot(results(1).time,results(1).up_ft,'k')
hold on; plot(results(2).time,results(2).up_ft,'b')
legend('Ownship','Intruder');
xlabel('Time (sec)'); ylabel('Altitude (ft)')

% Plan View
hExamplePlanView = figure('visible','off');
plot(results(1).east_ft,results(1).north_ft,'k')
hold on;
plot(results(2).east_ft,results(2).north_ft,'b')
plot(results(1).east_ft(1),results(1).north_ft(1),'kx')
plot(results(2).east_ft(1),results(2).north_ft(1),'bx')
legend('Ownship','Intruder');
xlabel('x (ft)'); ylabel('y (ft)')
axis equal

%Save or plot figures
if plotFigures
    hExampleAltitude.Visible = true;
    hExamplePlanView.Visible = true;
else
    set(hExamplePlanView, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
    set(hExampleAltitude, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
    saveas(hExamplePlanView, [saveDirectory, '/Example' num2str(encId) '_PlanView' figNameExtension '.fig']);
    saveas(hExampleAltitude, [saveDirectory, '/Example' num2str(encId) '_Altitude' figNameExtension '.fig']);
end

%Plot of intruder speed to verify acceleration
if strcmp(figNameExtension, 'Accel')
    hExampleSpeed = figure('visible','off');
    plot(results(1).time,results(1).speed_ftps,'k');
    hold on; plot(results(2).time,results(2).speed_ftps,'b');
    legend('Ownship','Intruder');
    xlabel('Time (sec)'); ylabel('Speed (ftps)');
    
    %Save or plot figures
    if plotFigures
        hExampleSpeed.Visible = true;
    else
        set(hExampleSpeed, 'CreateFcn', 'set(gcbo,''Visible'',''on'')');
        saveas(hExampleSpeed, [saveDirectory, '/Example' num2str(encId) '_Speed' figNameExtension '.fig']);
    end
end

end