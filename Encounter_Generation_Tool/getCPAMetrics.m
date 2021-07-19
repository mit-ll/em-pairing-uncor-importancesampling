function [hmd_ft, vmd_ft, tca_s, isNmac] = getCPAMetrics(trajectory1, trajectory2)
% Copyright 2018 - 2021, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
% Compute CPA properties: HMD, VMD, TCA 

% Parse trajectories
own_e_ft = trajectory1.east_ft;
int_e_ft = trajectory2.east_ft;
own_n_ft = trajectory1.north_ft;
int_n_ft = trajectory2.north_ft;
own_h_ft = trajectory1.up_ft;
int_h_ft = trajectory2.up_ft;

% Horizontal and vertical distances during encounter
horizontalDist_ft = hypot(own_e_ft-int_e_ft, own_n_ft-int_n_ft);
verticalDist_ft = abs(own_h_ft-int_h_ft);

% Calculate hmd and vmd
[hmd_ft,tca_s] = min(horizontalDist_ft);
vmd_ft = abs(own_h_ft(tca_s)-int_h_ft(tca_s));

% An nmac occurs if the horizontal distance is less than 500 ft and the
% vertical distance is less than 100 ft.
isNmac = any(horizontalDist_ft < 500 & verticalDist_ft < 100);

end