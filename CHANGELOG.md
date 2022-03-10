# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project should adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `sampleFullUncorModel` called by `generateDAAEncounterSet` to minimize code duplication

### Changed

- Updated double array (`ic`, `ic1`, `ic2`) inputs to run_dynamics_fast in response to [pull request #8 in `em-core`](https://github.com/Airspace-Encounter-Models/em-core/pull/9)
- Style fixes for entire repository using [MH Style from MISS_HIT](https://misshit.org/). Specifically used the following code in the root directory for this repository: `mh_style . --fix`
- Implemented `UncorEncounterModel` class for loading the parameters and sampling the Bayesian networks. The track generation capability of the class is not implemented here, rather `run_dynamics_fast` is still called directly.
- Updated calls to `run_dynamics_fast` with two additional inputs corresponding to dynamic limit constraints. Dynamic constraints were previously hardcoded constants in `run_dynamics_fast.c`
- Updated `runDynamicsFastTests` to compare results to a now stored baseline results from the .mat files. Previously this script just plotted encounters but had no means to test or compare changes
- Helper functions of `BuildControlsArray` and `ConvertUnits` moved to be helper functions of `sampleFullUncorModel`
- Moved `ScriptedEncounter` and `UncorEncounterParameters` to class specific directories for better organization
- Property validation syntax for `ScriptedEncounter` and `UncorEncounterParameters`

### Fixed

- `simulateDynamicsLimits` incorrectly stated that a 3 degree per second dynamic limit was used when in actuality it was a 1.5 degree per second limit. Function comments updated.

### Removed

- `run_dynamics_fast_test` removed because there is no need for different variants of run_dynamics_fast with different dynamic constraints
- `EncounterModelEvents` was moved to em-model-manned-bayes

## [1.2.0] - 2021-07-19

### Added

- `.gitattributes` added for repository management
- `preallocateEncProperties` to preallocate struct of encounter metadata
- Basic performance benchmark metrics to `generateDAAEncounterSet()` and plotted in `RUN_DAAEncounterModelTool_serial`
- Default input and output directories

### Changed

- Substantial performance boost through preallocating, minimizing use of dynamically growth of arrays, and removing large variables that are not used. On a local windows machine, these improvements reduce the time to generate 100K encounters from days to hours
- Updated mex instructions to use the -g flag
- Trajectory .csv files explicitly use UTF-8 encoding
- Updated line endings for various files to better cross platform compatibility
- Renamed matlab startup script
- MATLAB startip script checks for symbolic math toolbox
- MATLAB startup script to add self path using system environment variable instead of `pwd()`
- Removed various unnecessary unit conversions by [@cserres](https://github.com/cserres)

### Fixed

- Random seed sequentially updated and guaranteed to be unique up to a seed of 2^32 (the MATLAB limit)
- Fix bug when checking duplicate settings when looking if there has been any encounter model customization
- `generateDAAEncounterSet` formats input to `wpt2script` correctly

### Removed

- Remove `em_read` that was shadowed by the version in [em-model-manned-bayes](https://github.com/airspace-Encounter-Models/em-model-manned-bayes)
- `checkINIInputs()` no longer issues warnings about the uncor_1200code_v2p1 model
- Removed instances %#okgrow that suppressed warnings

## [1.1.0] - 2020-10-02

### Changed

- Updated to output original encounter model events

## [1.0.0] - 2020-09-10

### Added

- Initial public release

[1.2.0]: https://github.com/Airspace-Encounter-Models/em-pairing-uncor-importancesampling/releases/tag/v1.2
[1.1.0]: https://github.com/Airspace-Encounter-Models/em-pairing-uncor-importancesampling/releases/tag/v1.1
[1.0.0]: https://github.com/Airspace-Encounter-Models/em-pairing-uncor-importancesampling/releases/tag/v1.0
