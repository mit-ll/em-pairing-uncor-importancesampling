% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
%% This script runs all tests for the encounter generation tool.
% NOTE: the tests must be run in this order because the earlier tests
% generate encounters that are used by the later tests.

% 0. Setup the directory path
cd(getenv('AEM_DIR_DAAENC'));

% 1. Verify that the distributions of generated encounters match expected
% speed/altitude distributions for various input parameters
runInputParameterDistributionTests;

% 2. Test dynamics model used in encounter generation tool
runDynamicsFastTests;

% 3. Verify conversion between encounter model events and
% trajectory/waypoints
runTrajectoryEventsVerificationTests;

% 4. Verify that P(NMAC|encounter cylinder) for generated encounters
% matches gas model results
runPnmacGasModelTests;

% 5. Verify generated encounters can be run in DEGAS.
% ***Note: requires the DEGAS repository.***
if ~isempty(getenv('DEGAS_HOME'))
    runEncounterWithDEGASTests;
else
    warning('Not running runEncounterWithDEGASTests.m because system environment variable DEGAS_HOME not set\n');
end
