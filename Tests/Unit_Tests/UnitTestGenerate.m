% Copyright 2018 - 2022, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%% Test Class Definition
classdef UnitTestGenerate < matlab.unittest.TestCase

    %% Test Method Block
    % https://www.mathworks.com/help/matlab/matlab_prog/author-class-based-unit-tests-in-matlab.html
    methods (Test)

        %% Test Function
        function testGenEncs(testCase)
            %% Exercise function under test

            % Setup input parameter (.ini) file
            parameterFile = [getenv('AEM_DIR_DAAENC') filesep 'Example_Inputs' filesep 'ParamsUnitTests.ini'];
            iniSettings = ini2struct (parameterFile);

            % Create encounters
            generateDAAEncounterSet(parameterFile);

            % Load encounters
            x = load([getenv('AEM_DIR_DAAENC') filesep iniSettings.saveDirectory filesep 'scriptedEncounters.mat']);

            %% Verify using test qualification
            % https://www.mathworks.com/help/matlab/matlab_prog/types-of-qualifications.html
            % exp = your expected value
            % testCase.<qualification method>(act,exp);

            testCase.verifyEqual(x.samples(1).id, 1);
            testCase.verifyEqual(x.samples(1).runTime_s, 180);
            testCase.verifySize(x.samples(1).v_ftps, [1 2]);
        end

    end
end
