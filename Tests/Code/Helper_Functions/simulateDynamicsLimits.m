% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function results = simulateDynamicsLimits(sample)
% This function simulates the input encounter (sample)'s dynamics using
% run_dynamics_fast_test.c that has a 3 deg/sec turn rate limit and 25 ftps
% vertical rate limit.

% Get encounter initial conditions
ic1 = [0,sample.v_ftps(1),sample.n_ft(1),sample.e_ft(1),sample.h_ft(1),sample.heading_rad(1),sample.pitch_rad(1),sample.bank_rad(1),sample.a_ftpss(1)];
ic2 = [0,sample.v_ftps(2),sample.n_ft(2),sample.e_ft(2),sample.h_ft(2),sample.heading_rad(2),sample.pitch_rad(2),sample.bank_rad(2),sample.a_ftpss(2)];

% Events (dynamic controls)
event1 = sample.updates(1).event;
event2 = sample.updates(2).event;

% Simulate dynamics
results = run_dynamics_fast_test(ic1,event1,ic2,event2,sample.runTime_s);

end