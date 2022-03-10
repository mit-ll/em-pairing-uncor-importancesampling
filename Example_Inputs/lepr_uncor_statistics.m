% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function [N_initial, N_transition] = lepr_uncor_statistics()
    % LEPR_UNCOR_STATISTICS returns the sufficient statistics for the
    % uncorrelated encounter model modified for a generic LEPR (Low End
    % Performance Representative) aircraft
    %
    %   [N_initial N_transition] = lepr_uncor_statistics()
    %
    % See also UNCOR_VARIABLES_LEPR
    %

    %% Initial Bayesian Network
    N_initial = cell(7, 1);

    % G - region (Only use CONUS)
    N_initial{1} = [1  % Contiguous United States (CONUS), Alaska, Canada, and Mexico
                    0  % Islands
                    0  % CONUS Offshore
                    0]; % Islands Offshore

    %  A - Airspace Class
    %           L =  500-1200   1200-3000   3000-5000   5000+
    N_initial{2} = [0          0           0           0   % B
                    1          1           1           0   % C
                    1          1           0           0   % D
                    1          1           1           1]; % O

    % L - Layer
    N_initial{3} = [1  % 500 - 1200
                    1  % 1200 - 3000
                    1  % 3000 - 5000
                    1  % 5000 +
                   ]; % Altitude is sampled uniformly within layer

    % V - Airspeed (KTAS)
    %           L =  500-1200   1200-3000   3000-5000   5000+
    N_initial{4} = [1         1          1          1];    % 40-100

    % dv - Airspeed Acceleration (kt/s^2)
    N_initial{5} = 1;

    % dh - Vertical Rate (ft/min)
    %           L =  500-1200   1200-3000   3000-5000   5000+
    N_initial{6} = [20         20          30          30    % -500 to -400
                    55         55          55          55    % 0
                    25         25          15          15];  % 400 to 500

    % dpsi - Turn rate (deg/s)
    %           L =  500-1200   1200-3000   3000-5000   5000+
    N_initial{7} = [2          2           2           0     % -2.5 to -2
                    3          3           3           3     % -2 to -1
                    5          5           5           6     % -1 to -0.1
                    80         80          80          82     % 0
                    5          5           5           6     % 0.1 to 1
                    3          3           3           3     % 1 to 2
                    2          2           2           0];   % 2 to 2.5

    %% Transition Bayesian Network
    N_transition = cell(10, 1);

    % dv(t+1)
    N_transition{8} = eye(size(N_initial{5}, 1));

    % dh(t+1)
    %          dh(t) >  -500 to -400  0   400 to 500
    N_transition{9} =   [96       1       0         % -500 to -400
                         2        98      2         % 0
                         0        1       96];  % 400 to 500
    % dpsi(t+1)
    %         dpsi(t) >  -2.5  -2  -1  -0.1  0.1   1   2
    N_transition{10} = [95   4   0     0    0   0   0    % -2.5 to -2
                        5  92   3     0    0   0   0    % -2 to -1
                        0   4  94     1    0   0   0    % -1 to -0.1
                        0   0   3    98    3   0   0    % 0
                        0   0   0     1   94   4   0    % 0.1 to 1
                        0   0   0     0    3  92   5    % 1 to 2
                        0   0   0     0    0   4  95];  % 2 to 2.5
