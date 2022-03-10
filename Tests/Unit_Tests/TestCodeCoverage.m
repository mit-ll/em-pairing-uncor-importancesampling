% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%% Test Class Definition
classdef TestCodeCoverage < matlab.unittest.TestCase

    %% Test Method Block
    % https://www.mathworks.com/help/matlab/matlab_prog/author-class-based-unit-tests-in-matlab.html
    methods (Test)

        %% Test Function
        % 0. Default demo run script with serial processing
        function testSerial(testCase)
            % Exercise function under test
            sourceCodeFile = [getenv('AEM_DIR_DAAENC') filesep 'RUN_DAAEncounterModelTool_serial.m'];
            run(sourceCodeFile);
        end

        % 1. Verify that the distributions of generated encounters match expected
        % speed/altitude distributions for various input parameters
        function testInputParam(testCase)
            % Exercise function under test
            sourceCodeFile = [getenv('AEM_DIR_DAAENC') filesep 'Tests' filesep 'Code' filesep 'runInputParameterDistributionTests.m'];
            run(sourceCodeFile);
        end

        % 2. Test dynamics model used in encounter generation tool
        function testDynamics(testCase)
            % Exercise function under test
            sourceCodeFile = [getenv('AEM_DIR_DAAENC') filesep 'Tests' filesep 'Code' filesep 'runDynamicsFastTests.m'];
            run(sourceCodeFile);
        end

        % 3. Verify conversion between encounter model events and
        % trajectory/waypoints
        function testEventsWypts(testCase)
            % Exercise function under test
            sourceCodeFile = [getenv('AEM_DIR_DAAENC') filesep 'Tests' filesep 'Code' filesep 'runTrajectoryEventsVerificationTests.m'];
            run(sourceCodeFile);
        end

        % 4. Verify that P(NMAC|encounter cylinder) for generated encounters
        % matches gas model results
        function testPNAMC(testCase)
            % Exercise function under test
            sourceCodeFile = [getenv('AEM_DIR_DAAENC') filesep 'Tests' filesep 'Code' filesep 'runPnmacGasModelTests.m'];
            run(sourceCodeFile);
        end

        % 5. Verify generated encounters can be run in DEGAS.
        % ***Note: requires the DEGAS repository.***
        function testDEGAS(testCase)
            % Exercise function under test
            sourceCodeFile = [getenv('AEM_DIR_DAAENC') filesep 'Tests' filesep 'Code' filesep 'runPnmacGasModelTests.m'];
            if ~isempty(getenv('DEGAS_HOME'))
                run(sourceCodeFile);
            else
                warning('Not running runEncounterWithDEGASTests.m because system environment variable DEGAS_HOME not set\n');
            end
        end

    end % End methods
end % End classdef
