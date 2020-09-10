% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function [G_initial, r_initial, G_transition, r_transition, temporal_map, zero_bins, labels_initial, labels_transition, boundaries, resample_rates] = ... 
  uncor_variables()
% UNCOR_VARIABLES returns variables for the uncorrelated encounter
% model modified for a generic HALE/MALE aircraft.
%
%  [G_initial, r_initial, G_transition, r_transition, temporal_map, ...
%       zero_bins, labels_initial, labels_transition, ...
%       boundaries, resample_rates] = ...
%       uncor_variables();
%
% See also HALE_UNCOR_STATISTICS, MALE_UNCOR_STATISTICS

%% Labels
% Geographic region (G), airspace class (A), altitude layer (L), velocity
% (v), acceleration (dv), vertical rate (dh), turn rate (dpsi)
labels_initial = {'G', 'A' 'L' 'v' '\dot v' '\dot h' '\dot \psi'};
labels_transition = {'G','A' 'L' 'v' '\dot v(t)' '\dot h(t)' '\dot \psi(t)' ...
    '\dot v(t+1)' '\dot h(t+1)' '\dot \psi(t+1)'};

n_initial = 7;
n_transition = 10;

%% Initial Network
G_initial = zeros(7); % initial distribution graph structure

G_initial(3,2) = 1; % L -> A
G_initial(3,4) = 1; % L -> v
G_initial(3,6) = 1; % L -> dh
G_initial(3,7) = 1; % L -> dpsi

G_initial = logical(G_initial);

%% Transition Network
G_transition = zeros(10);
G_transition(5,8) = 1; % dv(t)->dv(t+1)
G_transition(6,9) = 1; % dh(t)->dh(t+1)
G_transition(7,10) = 1; % dpsi(t)->dpsi(t+1)

G_transition = logical(G_transition); % continuous transition model graph structure
  
%% CUTPOINTS INITIAL
cutpoints_initial = {
    [ 2 3 4 ], ... % G
    [ 2 3 4 ], ... % A
    [ 2 3 4 ], ... % L - layers bins are 500-1200, 1200-3000, 3000-5000, 5000-18000 ft
    [ 100 150 200 ], ... % v (KTAS)
    [], ... % dv (kt/s^2)
    [ -2000 -1000 -400 400 1000 2000 3000 4000 ], ... % dh (ft/min) 
    [-2 -1 -0.1 0.1 1 2], ... % dpsi (deg/s)
};

r_initial = zeros(n_initial, 1);
for i = 1:n_initial
    r_initial(i) = length(cutpoints_initial{i}) + 1; % a column vector specifying the number of bins for each variable in the initial network
end

%% CUTPOINTS TRANSITION
cutpoints_transition = {
    cutpoints_initial{1}, ... % G
    cutpoints_initial{2}, ... % A
    cutpoints_initial{3}, ... % L
    cutpoints_initial{4}, ... % v
    cutpoints_initial{5}, ... % dv
    cutpoints_initial{6}, ... % dh
    cutpoints_initial{7}, ... % dpsi
    cutpoints_initial{5}, ... % dv(t+1)
    cutpoints_initial{6}, ... % dh(t+1)
    cutpoints_initial{7} ... % dpsi(t+1)
};
    r_transition = zeros(length(cutpoints_transition), 1);
    for i = 1:n_transition
        r_transition(i) = length(cutpoints_transition{i}) + 1; % a column vector specifying the number of bins for each variable in the transition network
    end

%% BOUNDS
bounds_initial = [0 0; ... % Region
                  0 0; ... % Airspace
                  0 0; ... % Layer
                  50 250; ... % Airspeed (KTAS)
                  -1 1; ... % Airspeed Acceleration (kt/s^2)
                  -2500 4500; ... % Vertical Rate (ft/min)
                  -2.5 2.5]; % Turn Rate (deg/s)
              
zero_bins = { [], [], [], [], 1, 4, 4 }; % The location (index) of the bin where the sampled values are 0
              
%Compute boundaries
boundaries = cell(1,n_initial); % Boundaries of the bins from which each of the variables will be sampled
for i = 1:n_initial
    if bounds_initial(i,1) == bounds_initial(i,2)
        boundaries{i} = [];
    else
        boundaries{i} = [bounds_initial(i,1) cutpoints_initial{i} bounds_initial(i,2)];
    end
end

%% TEMPORAL MAP
temporal_map = [5 8; 6 9; 7 10]; % Map of the variables that transition to other variables

%% RESAMPLE RATES
% How often variables change within bounds. Variables that have 0 resample
% rates are not resampled during the course of the trajectory.
all_change = [ 0 0 0 0 0  1 1 ]; %how often variables change
all_repeat = [ 1 1 1 1 1 19 9 ]; %how often variables stay the same

resample_rates = all_change./all_repeat;
