% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%% Test Class Definition
classdef UnitTestUncorEncounterParameters < matlab.unittest.TestCase

    %% Test Method Block
    % https://www.mathworks.com/help/matlab/matlab_prog/author-class-based-unit-tests-in-matlab.html
    methods (Test)

        %% Test Function
        function testInit(testCase)
            %% Exercise function under test
            tca = 1;
            simtime = 1;
            isFailed = false;
            ownHeightAtTCA = 1;
            intHeightAtTCA = 1;
            maxHMD = 1;

            x = UncorEncounterParameters(tca, simtime, isFailed, ownHeightAtTCA, intHeightAtTCA, maxHMD);

            %% Verify using test qualification
            % https://www.mathworks.com/help/matlab/matlab_prog/types-of-qualifications.html
            % exp = your expected value
            % testCase.<qualification method>(act,exp);
            testCase.verifySize(x.tca, [1 1]);
            testCase.verifySize(x.simtime, [1 1]);
            testCase.verifySize(x.isFailed, [1 1]);
            testCase.verifySize(x.ownHeightAtTCA, [1 1]);
            testCase.verifySize(x.intHeightAtTCA, [1 1]);
            testCase.verifySize(x.maxHMD, [1 1]);
        end

    end
end
