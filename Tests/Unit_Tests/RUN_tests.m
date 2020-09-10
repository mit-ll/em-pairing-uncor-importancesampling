% Copyright 2018 – 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
if verLessThan('matlab','9.6')
    error('CodeCoveragePlugin with the CoverageReport format introduced in 2019a');
end

%% Import plugins
import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageReport;

% We do this because \Tests\Code scripts will change directories
cd([getenv('AEM_DIR_DAAENC') filesep 'Tests' filesep 'Unit_Tests']);

%% Run suite of tests
% https://www.mathworks.com/help/matlab/ref/runtests.html
% https://www.mathworks.com/help/matlab/matlab_prog/run-tests-for-various-workflows.html
suite = testsuite(pwd,'Name','UnitTest*');
runner = TestRunner.withNoPlugins;
results = runner.run(suite)

% Display status
if all([results.Passed])
    fprintf('Ran %i unit tests, all passed\n',numel(results));
else
    warning('At least one unit test failed');
end

%% Code Coverage for Default Serial Script
% https://www.mathworks.com/help/matlab/ref/matlab.unittest.plugins.codecoverageplugin-class.html
sourceCodeFile = [getenv('AEM_DIR_DAAENC') filesep 'RUN_DAAEncounterModelTool_serial.m'];
reportFile = [getenv('AEM_DIR_DAAENC') filesep 'Tests' filesep 'Code_Coverage'];

% Check MATLAB code files for possible problems
msg = checkcode(sourceCodeFile,'-string','-fullpath');

% Code Coverage
suiteCC = testsuite('TestCodeCoverage');
runnerCC = TestRunner.withNoPlugins;
runnerCC.addPlugin(CodeCoveragePlugin.forFolder(getenv('AEM_DIR_DAAENC'),...
    'IncludingSubfolders',true,...
    'Producing',matlab.unittest.plugins.codecoverage.CoverageReport(reportFile)));
resultCC = runnerCC.run(suiteCC);

%% Save
outFile = [getenv('AEM_DIR_DAAENC') filesep 'Tests' filesep datestr(now,'yyyymmddTHHMMSS') '_' version('-release') '_TestResults.mat'];
save(outFile,'suite','results','suiteCC','resultCC');
