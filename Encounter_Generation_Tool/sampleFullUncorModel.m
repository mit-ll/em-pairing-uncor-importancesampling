function [sample, eventMatrix, ic] = sampleFullUncorModel(id,mdl,sample_time,layers,isQuantize500)
% Copyright 2018 - 2021, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% SEE ALSO: UncorEncounterModel/sample EncounterModelEvents

% Inputs Hardcode
% Initial 2D position and number of aircraft
n_ft = 0;
e_ft = 0;
numberOfAircraft = 2;

% Model variable indicies
idxL = find(strcmp(mdl.labels_initial,'"L"'));
idxV = find(strcmp(mdl.labels_initial,'"v"'));
idxDV = find(strcmp(mdl.labels_initial,'"\dot v"'));
idxDH = find(strcmp(mdl.labels_initial,'"\dot h"'));
idxDPsi = find(strcmp(mdl.labels_initial,'"\dot \psi"'));

% Generate samples from dynamic bayesian network
[init, ~, ~, EME] = mdl.sample(1,sample_time,...
    'layers',layers,'isQuantize500',isQuantize500);

% Parse
eventMatrix = EME.event;

% Parse initial and convert units as needed
h_ft = init(idxL); % Altitude: no units conversion needed
v_ft_s = init(idxV) * 1.68780972222222;   % v: KTAS -> ft/s (use mean altitude for layer)
dv_ft_ss = init(idxDV) * 1.68780972222222;   % vdot: kt/s -> ft/s^2
dh_ft_s = init(idxDH) / 60;  % hdot: ft/min -> ft/s
dpsi_rad_s = deg2rad(init(idxDPsi));  % psidot: deg/s -> rad/s

% Calculate heading, pitch and bank angles
heading_rad = 0;
pitch_rad = asin(dh_ft_s/v_ft_s);
bank_rad = atan(v_ft_s*dpsi_rad_s/32.2); % 32.2 = acceleration g

% Create samples struct
sample.runTime_s = sample_time;
sample.altLayer = init(idxL);
sample.id = id;
sample.numberOfAircraft = numberOfAircraft;
sample.v_ftps = v_ft_s;
sample.n_ft = n_ft;
sample.e_ft = e_ft;
sample.h_ft = h_ft;
sample.heading_rad = heading_rad;
sample.pitch_rad = pitch_rad;
sample.bank_rad = bank_rad;
sample.a_ftpss = dv_ft_ss;
sample.updates = EME;

% Initial conditions array for run_dynamics_fast
ic = [0,sample.v_ftps,sample.n_ft,sample.e_ft,sample.h_ft,sample.heading_rad,sample.pitch_rad,sample.bank_rad,sample.a_ftpss];
