% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function const = load_constants ()
%  Define various constants used throughout the code
const.nm2ft = 6076.115;                         % Nautical miles to feet
const.ft2m = 12 * 2.54 / 100.;                  % Feet to meters
const.hr2min = 60;                              % Hours to minutes
const.min2sec = 60;                             % Minutes to seconds
const.hr2sec = 3600;                            % Hours to seconds
const.kt2ftps = const.nm2ft / const.hr2sec;     % Knots to ft/sec (1.68781)
const.g = 32.2;                                 % Gravity (ft/s**2)
