% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function [hmd, vmd, tca, nmac] = getCPAMetrics(trajectory1, trajectory2)
%Compute CPA properties: HMD, VMD, TCA
own_e_ft = trajectory1.east_ft;
int_e_ft = trajectory2.east_ft;
own_n_ft = trajectory1.north_ft;
int_n_ft = trajectory2.north_ft;
own_h_ft = trajectory1.up_ft;
int_h_ft = trajectory2.up_ft;

%Horizontal and vertical distances during encounter
horizontalDist = hypot(own_e_ft-int_e_ft, own_n_ft-int_n_ft);
verticalDist = abs(own_h_ft-int_h_ft);

[hmd,tca] = min(horizontalDist);
vmd = abs(own_h_ft(tca)-int_h_ft(tca));

% An nmac occurs if the horizontal distance is less than 500 ft and the
% vertical distance is less than 100 ft.
nmac = any(horizontalDist < 500 & verticalDist < 100);

end