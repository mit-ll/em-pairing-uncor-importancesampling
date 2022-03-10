% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
% ECEF_TO_ENU ECEF to ENU conversion
%
% venu = ecef_to_enu (vecef, gref)
%
% INPUTS:
%   vecef    ECEF vector, a structure with fields x, y and z, in meters (each
%            structure field is Nx1), where:
%               x is at zero longitude
%               y is 90 degrees east longitude
%               z is north pole
%
%   gref     reference geodetic coordinates, a structure with fields lat_deg,
%            long_deg, altitude_m (each structure field is Nx1)
%            Altitude should be given as ellipsoid height
%
% OUTPUT:
%   venu     reference ENU coordinates, a structure with fields x, y, z, in
%            meters (each structure is Nx1)
% ----

function venu = ecef_to_enu(vecef, gref)

    slat = sin(gref.lat_deg * pi / 180);
    clat = cos(gref.lat_deg * pi / 180);
    slon = sin(gref.long_deg * pi / 180);
    clon = cos(gref.long_deg * pi / 180);

    N = length(vecef.x);
    venu.x = zeros(N, 1);
    venu.y = zeros(N, 1);
    venu.z = zeros(N, 1);

    for i = 1:N
        vin.x = vecef.x(i);
        vin.y = vecef.y(i);
        vin.z = vecef.z(i);
        if length(gref.lat_deg) == 1
            j = 1;
        else
            j = i;
        end

        g.lat_deg = gref.lat_deg(j);
        g.long_deg = gref.long_deg(j);
        g.altitude_m = gref.altitude_m(j);

        tmp_x = [-slon(j);  clon(j); 0];
        tmp_y = [-clon(j) * slat(j); -slon(j) * slat(j); clat(j)];
        tmp_z = [clon(j) * clat(j); slon(j) * clat(j); slat(j)];
        M = [tmp_x tmp_y tmp_z];
        M = transpose(M);

        vtmp = geod_to_ecef(g);
        v = [vin.x - vtmp.x; vin.y - vtmp.y; vin.z - vtmp.z];
        vout = M * v;

        venu.x(i) = vout(1);
        venu.y(i) = vout(2);
        venu.z(i) = vout(3);
    end
