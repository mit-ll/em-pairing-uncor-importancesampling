% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function [N_initial, N_transition] = male_uncor_statistics()
% MALE_UNCOR_STATISTICS returns the sufficient statistics for the
% uncorrelated encounter model modified for a generic MALE (Medium
% Altitude, Long Endurance) aircraft
%
%   [N_initial N_transition] = male_uncor_statistics()
%
% See also UNCOR_VARIABLES
%

%% Initial Bayesian Network
N_initial = cell(7,1);

% G - region (Only use CONUS)
N_initial{1} = [ 1; % Contiguous United States (CONUS), Alaska, Canada, and Mexico
                 0; % Islands
                 0; % CONUS Offshore
                 0 ]; %Islands Offshore 

%  A - Airspace Class
%           L =  500-1200  	1200-3000   3000-5000   5000+
N_initial{2} = [ 0          0           0           0;  %B
                 1          1           1           0;  %C
                 1          1           0           0;  %D
                 1          1           1           1]; %O


% L - Layer             
N_initial{3} = [ 1; % 500 - 1200
                 1; % 1200 - 3000
                 1; % 3000 - 5000
                 1  % 5000 +  
                 ]; % Altitude sampled uniformly within layer
             
% V - Airspeed (KTAS)
%           L =  500-1200  	1200-3000   3000-5000   5000+
N_initial{4} = [ 50         50          50          25;    % 50-100
                 50         50          50          50;    % 100-150
                  0          0           0          25;    % 150-200
                  0          0           0          0 ];  % 200-250
    

% dv - Airspeed Acceleration (kt/s^2)
N_initial{5} = 1;

% dh - Vertical Rate (ft/min)
%           L =  500-1200  	1200-3000   3000-5000   5000+
N_initial{6} = [ 7.5        7.5         10          10;   % -2500 - -2000
                 20         20          25          25;   % -2000 - -1000
                 7.5        7.5         10          10;   % -1000 - -400
                 15         15          20          20;   % 0
                 5          5           5           5;    % 400 - 1000
                 20         20          15          15;   % 1000 - 2000
                 15         15          15          15;   % 2000 - 3000
                 10         10          0           0;    % 3000 - 4000
                 0          0           0           0 ];  % 4000 - 4500

% dpsi - Turn rate (deg/s)
%           L =  500-1200  	1200-3000   3000-5000   5000+
N_initial{7} = [ 2          2           2           0;    % -2.5 to -2
                 3          3           3           3;    % -2 to -1
                 5          5           5           6;    % -1 to -0.1
                80         80          80          82;    % 0
                 5          5           5           6;    % 0.1 to 1
                 3          3           3           3;    % 1 to 2
                 2          2           2           0];   % 2 to 2.5

%% Transition Bayesian Network
N_transition = cell(10,1);

% dv(t+1)
N_transition{8} = eye( size(N_initial{5},1) );

% dh(t+1)
%           dh(t) >  -2500 -2000 -1000 -400 400 1000 2000 3000 4000 
N_transition{9} =   [   98     1     0    0   0    0    0    0    0;   % -2500 - -2000
                         2    96     2    0   0    0    0    0    0;   % -2000 - -1000
                         0     3    96    1   0    0    0    0    0;   % -1000 - -400
                         0     0     2   98   2    0    0    0    0;   % 0
                         0     0     0    1  96    2    0    0    0;   % 400 - 1000
                         0     0     0    0   2   96    2    0    0;   % 1000 - 2000
                         0     0     0    0   0    2   96    3    0;   % 2000 - 3000
                         0     0     0    0   0    0    2   96    2;   % 3000 - 4000
                         0     0     0    0   0    0    0    1   98];  % 4000 - 4500
% dpsi(t+1)
%         dpsi(t) >  -2.5  -2  -1  -0.1  0.1   1   2 
N_transition{10} = [   95   4   0     0    0   0   0;    % -2.5 to -2
                        5  92   3     0    0   0   0;    % -2 to -1
                        0   4  94     1    0   0   0;    % -1 to -0.1
                        0   0   3    98    3   0   0;    % 0
                        0   0   0     1   94   4   0;    % 0.1 to 1
                        0   0   0     0    3  92   5;    % 1 to 2
                        0   0   0     0    0   4  95];   % 2 to 2.5
