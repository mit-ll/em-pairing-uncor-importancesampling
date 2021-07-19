function isPenetrate = getCylinderPenetration(trajectory1, trajectory2, radius, height)
% Copyright 2018 - 2021, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
% This function determines whether the intruder (trajectory2) penetrates a
% cylinder with the input radius and height centered on the ownship
% (trajectory1) during the encounter.
%
% radius can be a vector of values. height is a constant.

own_e_ft = trajectory1.east_ft;
int_e_ft = trajectory2.east_ft;
own_n_ft = trajectory1.north_ft;
int_n_ft = trajectory2.north_ft;
own_h_ft = trajectory1.up_ft;
int_h_ft = trajectory2.up_ft;

horizontalDist = hypot(own_e_ft-int_e_ft, own_n_ft-int_n_ft);
verticalDist = abs(own_h_ft-int_h_ft);

% Preallocate
isPenetrate = zeros(1, numel(radius));

% Iterate over radius
for r = 1:numel(radius)
    isPenetrate(r) = any(horizontalDist < radius(r) & verticalDist < height);
end

end
