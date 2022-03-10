% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
% GEOF_TO_ECEF Convert geodetic coordinates to ECEF
%
% vecef = geod_to_ecef (gref)
%
% INPUT:
%   gref     reference geodetic coordinates, a structure with fields
%            lat_deg, long_deg, altitude_m (each structure is Nx1)
%
% OUTPUT:
%   vecef    ecef vector, a structure with fields x, y and z, in meters
%            (each structure is Nx1), where:
%               x is at zero longitude
%               y is 90 degrees east longitude
%               z is north pole
% ----

function vecef = geod_to_ecef(gref)

    WGS84_SEMI_MAJOR_AXIS = 6378137.0;
    ESQ                   = 0.00669437999013;

    slat = sin(gref.lat_deg * pi / 180);
    clat = cos(gref.lat_deg * pi / 180);
    slon = sin(gref.long_deg * pi / 180);
    clon = cos(gref.long_deg * pi / 180);

    geo_rad = WGS84_SEMI_MAJOR_AXIS ./ sqrt(1.0 - ESQ * slat .* slat);

    vecef.x = (geo_rad + gref.altitude_m) .* clat .* clon;
    vecef.y = (geo_rad + gref.altitude_m) .* clat .* slon;
    vecef.z = (geo_rad * (1.0 - ESQ) + gref.altitude_m) .* slat;
