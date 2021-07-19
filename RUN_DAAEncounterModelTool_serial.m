% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%% Inputs
% Using trajectories sampled from an Uncorrelated encounter model

% Setup input parameter (.ini) file
parameterFile = [getenv('AEM_DIR_DAAENC') filesep 'Example_Inputs' filesep 'UncorVsUncor.ini'];

% If true, plot
isPlot = false;

%% Generate Uncorrelated Encounters
generateDAAEncounterSet(parameterFile);

%% Get ready to plot encouters
% Read in encounter set parameters
iniSettings = ini2struct(parameterFile);

% Grab encounter ids
encIds = iniSettings.encIds;

% Read in saved encounters
s = load([getenv('AEM_DIR_DAAENC') filesep  iniSettings.saveDirectory filesep 'scriptedEncounters.mat']);

% Read in performance benchmarks
benchmark = load([getenv('AEM_DIR_DAAENC') filesep  iniSettings.saveDirectory filesep 'benchmark.mat']);

%% Simulate encounters
% Iterate
for i = encIds
    % Get encounter
    sample = s.samples(i);
    
    % Encounter initial conditions
    ic1 = [0,sample.v_ftps(1),sample.n_ft(1),sample.e_ft(1),sample.h_ft(1),sample.heading_rad(1),sample.pitch_rad(1),sample.bank_rad(1),sample.a_ftpss(1)];
    ic2 = [0,sample.v_ftps(2),sample.n_ft(2),sample.e_ft(2),sample.h_ft(2),sample.heading_rad(2),sample.pitch_rad(2),sample.bank_rad(2),sample.a_ftpss(2)];
    
    % Events (dynamic controls)
    event1 = sample.updates(1).event;
    event2 = sample.updates(2).event;
    
    % Simulate dynamics
    results = run_dynamics_fast(ic1,event1,ic2,event2,sample.runTime_s);
    
    if isPlot
        % Initialize figure
        figure(i); set(gcf,'name',sprintf('%s: %i',parameterFile,i));
        
        % Altitude plot
        subplot(2,1,1);
        plot(results(1).time,results(1).up_ft,'k')
        hold on; plot(results(2).time,results(2).up_ft,'b')
        legend('Ownship','Intruder');
        xlabel('Time (sec)'); ylabel('Altitude (ft)'); grid on;
        title(sprintf('Altitude - Encounter %i', encIds(i)))
        
        % Plan View - x marks the initial position
        subplot(2,1,2);
        plot(results(1).east_ft,results(1).north_ft,'k')
        hold on; plot(results(2).east_ft,results(2).north_ft,'b')
        plot(results(1).east_ft(1),results(1).north_ft(1),'kx')
        plot(results(2).east_ft(1),results(2).north_ft(1),'bx')
        legend('Ownship','Intruder');
        xlabel('x (ft)'); ylabel('y (ft)')
        axis equal; grid on;
        title(sprintf('Plan View - Encounter %i', encIds(i)));
    end
end

%% Plot benchmarks
figure; set(gcf,'name','benchmark');
subplot(2,1,1); histogram(benchmark.numTrials,0:2:max(benchmark.numTrials)); title('Trials Required to Generate a Encounter'); ylabel('Encounters'); xlabel('# Trials'); grid on;
subplot(2,1,2); ecdf(benchmark.jobTime_s); title('Time (s)'); ylabel('CDF'); xlabel('Seconds'); grid on;
