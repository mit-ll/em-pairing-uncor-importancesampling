function results = simulateDynamics(sample)
    % Copyright 2018 - 2022, MIT Lincoln Laboratory
    % SPDX-License-Identifier: X11
    % This function simulates the input encounter (sample)'s dynamics using
    % run_dynamics_fast.c

    % Get encounter initial conditions
    ic1 = [sample.v_ftps(1), sample.n_ft(1), sample.e_ft(1), sample.h_ft(1), sample.heading_rad(1), sample.pitch_rad(1), sample.bank_rad(1), sample.a_ftpss(1)];
    ic2 = [sample.v_ftps(2), sample.n_ft(2), sample.e_ft(2), sample.h_ft(2), sample.heading_rad(2), sample.pitch_rad(2), sample.bank_rad(2), sample.a_ftpss(2)];

    % Events (dynamic controls)
    event1 = sample.updates(1).event;
    event2 = sample.updates(2).event;

    % Dynamic constraints
    dyn1 = [1.7 1116 -10000 10000 deg2rad(3), 1000000];
    dyn2 = [1.7 1116 -10000 10000 deg2rad(3), 1000000];

    % Simulate dynamics
    results = run_dynamics_fast(ic1, event1, dyn1, ic2, event2, dyn2, sample.runTime_s);

end
