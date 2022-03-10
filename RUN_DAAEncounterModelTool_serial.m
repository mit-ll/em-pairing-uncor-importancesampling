% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%% Inputs
% Using trajectories sampled from an Uncorrelated encounter model

% Setup input parameter (.ini) file
parameterFile = [getenv('AEM_DIR_DAAENC') filesep 'Example_Inputs' filesep 'UncorVsUncor.ini'];

% If true, plot
isPlot = true;

%% Generate Uncorrelated Encounters
% generateDAAEncounterSet(parameterFile);

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
    ic1 = [sample.v_ftps(1), sample.n_ft(1), sample.e_ft(1), sample.h_ft(1), sample.heading_rad(1), sample.pitch_rad(1), sample.bank_rad(1), sample.a_ftpss(1)];
    ic2 = [sample.v_ftps(2), sample.n_ft(2), sample.e_ft(2), sample.h_ft(2), sample.heading_rad(2), sample.pitch_rad(2), sample.bank_rad(2), sample.a_ftpss(2)];

    % Events (dynamic controls)
    event1 = sample.updates(1).event;
    event2 = sample.updates(2).event;

    % Simulate dynamics
    % Dynamic constraints
    % v_low,v_high,dh_ftps_min,dh_ftps_max,qmax,rmax
    dyn1 = [1.7 1116 -10000 10000 deg2rad(3), 1000000];
    dyn2 = [1.7 1116 -10000 10000 deg2rad(3), 1000000];
    results = run_dynamics_fast(ic1, event1, dyn1, ic2, event2, dyn2, sample.runTime_s);

    fig = figure;
    tiledlayout('flow', 'Padding', 'compact');
    nexttile;
    plot(results(1).east_ft, results(1).north_ft, 'b-', 'DisplayName', 'Ownship');
    hold on;
    plot(results(2).east_ft, results(2).north_ft, 'r--', 'DisplayName', 'Intruder');
    hold on;
    plot(results(1).east_ft(1), results(1).north_ft(1), 'bs', 'DisplayName', 'Ownship Initial');
    hold on;
    plot(results(2).east_ft(1), results(2).north_ft(1), 'rs', 'DisplayName', 'Intruder Initial');
    hold on;
    xlabel('East (ft)');
    ylabel('North (ft)');
    grid on;

    axis equal;
    nexttile;
    plot(results(1).time, results(1).up_ft, 'b-', 'DisplayName', 'Ownship');
    hold on;
    plot(results(2).time, results(2).up_ft, 'r--', 'DisplayName', 'Intruder');
    hold on;
    plot(results(1).time(1), results(1).up_ft(1), 'bs', 'DisplayName', 'Ownship Initial');
    hold on;
    plot(results(2).time(1), results(2).up_ft(1), 'rs', 'DisplayName', 'Intruder Initial');
    hold on;
    xlabel('Time (seconds)');
    ylabel('Up (ft)');
    grid on;
    legend('Location', 'best', 'NumColumns', 1);

    fig = figure;
    plot3(results(1).east_ft, results(1).north_ft, results(1).up_ft, 'b-', 'DisplayName', 'Ownship');
    hold on;
    plot3(results(2).east_ft, results(2).north_ft, results(2).up_ft, 'r--', 'DisplayName', 'Intruder');
    hold on;
    plot3(results(1).east_ft(1), results(1).north_ft(1), results(1).up_ft(1), 'bs', 'DisplayName', 'Ownship Initial');
    hold on;
    plot3(results(2).east_ft(1), results(2).north_ft(1), results(2).up_ft(1), 'rs', 'DisplayName', 'Intruder Initial');
    hold on;
    xlabel('East (ft)');
    ylabel('North (ft)');
    zlabel('Up (ft)');
    legend('Location', 'best');
    axis equal;
    axis square;
    grid on;

    if isPlot
        % Initialize figure
        figure(i);
        set(gcf, 'name', sprintf('%s: %i', parameterFile, i));

        % Altitude plot
        subplot(1, 2, 1);
        plot(results(1).time, results(1).up_ft, 'k');
        hold on;
        plot(results(2).time, results(2).up_ft, 'b');
        legend('Aircraft 1', 'Aircraft 2');
        xlabel('Time (sec)');
        ylabel('Altitude (ft)');
        grid on;
        title(sprintf('Altitude - Encounter %i', encIds(i)));

        % Plan View - x marks the initial position
        subplot(1, 2, 2);
        plot(results(1).east_ft, results(1).north_ft, 'k');
        hold on;
        plot(results(2).east_ft, results(2).north_ft, 'b');
        plot(results(1).east_ft(1), results(1).north_ft(1), 'kx');
        plot(results(2).east_ft(1), results(2).north_ft(1), 'bx');
        legend('Aircraft 1', 'Aircraft 2');
        xlabel('x (ft)');
        ylabel('y (ft)');
        axis equal;
        grid on;
        title(sprintf('Plan View - Encounter %i', encIds(i)));
    end
end

%% Plot benchmarks
figure;
set(gcf, 'name', 'benchmark');
subplot(2, 1, 1);
histogram(benchmark.numTrials, 0:2:max(benchmark.numTrials));
title('Trials Required to Generate a Encounter');
ylabel('Encounters');
xlabel('# Trials');
grid on;
subplot(2, 1, 2);
ecdf(benchmark.jobTime_s);
title('Time (s)');
ylabel('CDF');
xlabel('Seconds');
grid on;
