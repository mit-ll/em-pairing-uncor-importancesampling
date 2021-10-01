# Unit Tests and Code Coverage Artifacts

Tests using the MATLAB built-in unit test and code coverage tools. This README assumes the user is familiar with the [MATLAB testing frameworks](https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html) and the [matlab.unittest](https://www.mathworks.com/help/matlab/ref/matlab.unittest-package.html) package. Specifically, this repository uses [Class-Based Unit Tests](https://www.mathworks.com/help/matlab/class-based-unit-tests.html.)

Due to the use of [`matlab.unittest.plugins.codecoverage.CoverageReport`](https://www.mathworks.com/help/matlab/ref/matlab.unittest.plugins.codecoverage.coveragereport-class.html) plugin, this scripts must be run on MATLAB version 2019a or latter.

- [Unit Tests and Code Coverage Artifacts](#unit-tests-and-code-coverage-artifacts)
  - [Disclaimer](#disclaimer)
  - [Run Script](#run-script)
    - [Unit Tests](#unit-tests)
    - [Code Coverage](#code-coverage)
  - [Distribution Statement](#distribution-statement)

## Disclaimer

This repository does not contain comprehensive nor sufficient testing to be deemed a best practice. Rather this functionality was a prototype of basic unit testing using the default MATLAB capabilities. It is meant to be used as example and template to spur further development. This disclaimer will be removed in future revisions if full unit test capability is developed for this repository.

## Run Script

[`RUN_tests`](RUN_tests.m) is the single script that executes all the tests. It will import the required [matlab.unittest](https://www.mathworks.com/help/matlab/ref/matlab.unittest-package.html) plugins and then run two sets of [test suites](https://www.mathworks.com/help/matlab/ref/testsuite.html). The first suite is for traditional unit tests and the other suite is for code coverage artifacts. Unit tests have are classdefs with the `UnitTest` prefix (there can be multiple files) while [`TestCodeCoverage`](TestCodeCoverage.m) is used to generate code coverage artifacts.

The active directory should be the same as where [`RUN_tests`](RUN_tests.m) is stored. By default this should be \Tests\Unit_Tests\.

### Unit Tests

[A unit test is a determines the correctness of a unit of software](https://www.mathworks.com/help/matlab/matlab_prog/author-class-based-unit-tests-in-matlab.html). A basic unit test class includes a `classdef`, a `methods` block, and a `function` declaration. Foremost, the `classdef`  must inherent from `matlab.unittest.TestCase`. The `methods` block declaration must include the `Test` attribute, such as `methods (Test)`. Each unit test is a `function` contained within a methods block. The function must accept a `TestCase` instance as an input. The test function exercises the function under test and then uses specific functions to verify the test qualification. Refer to [this MATLAB documentation on types of test qualification](https://www.mathworks.com/help/matlab/matlab_prog/types-of-qualifications.html)

### Code Coverage

The [`matlab.unittest.plugins.CodeCoveragePlugin`](https://www.mathworks.com/help/matlab/ref/matlab.unittest.plugins.codecoverageplugin-class.html) is a plugin that produces a code coverage report. This code coverage report is different than what is produced when using [`profile`](https://www.mathworks.com/help/matlab/ref/profile.html). By default the code coverage report is generated in [Test_Outputs/Code_Coverage](../Test_Outputs/Code_Coverage/README.md).

The class is defined in [`TestCodeCoverage`](TestCodeCoverage.m). While the [`RUN_tests`](RUN_tests.m) configures the [`TestRunner`](https://www.mathworks.com/help/matlab/ref/matlab.unittest.testrunner-class.html) with the code coverage plugins for the test suite used to determine code coverage.

Note this repository currently only has a single class defined for code coverage artifacts. However this is a design choice and multiple classes can be used to when create the test suite, similar to how this repository organizes unit tests.

## Distribution Statement

DISTRIBUTION STATEMENT A. Approved for public release. Distribution is unlimited.

© 2018, 2019, 2020, 2021 Massachusetts Institute of Technology.

This material is based upon work supported by the National Aeronautics and Space Administration under Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, conclusions or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the National Aeronautics and Space Administration.

Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, U.S. Government rights in this work are defined by DFARS 252.227-7013 or DFARS 252.227-7014 as detailed above. Use of this work other than as specifically authorized by the U.S. Government may violate any copyrights that exist in this work.
