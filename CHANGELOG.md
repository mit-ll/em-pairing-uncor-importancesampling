# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project should adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2021-07-19

### Added

- `.gitattributes` added for repository management
- `preallocateEncProperties` to preallocate struct of encounter metadata
- Basic performance benchmark metrics to generateDAAEncounterSet() and plotted in RUN_DAAEncounterModelTool_serial
- Default input and output directories

### Changed

- Substantial performance boost through preallocating, minimizing use of dynamically growth of arrays, and removing large variables that are not used. On a local windows machine, these improvements reduce the time to generate 100K encounters from days to hours
- Updated mex instructions to use the -g flag
- Trajectory .csv files explicitly use UTF-8 encoding
- Updated line endings for various files to better cross platform compability 
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
