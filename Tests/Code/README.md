# Unit Tests

To run all tests, run `runAllEncounterToolTests.m` in Matlab. This function runs the five tests described below. In all of the functions, the user may choose to either save or display the test figures. The default is to save the figures in a test directory specified in the .INI file used by each unit test.

**Note:** the tests must be run in the order below because the earlier tests generate encounters that are used by later tests.

### Input Parameter Verification (`runInputParameterDistributionTests.m`)

The purpose of this test is to verify that the encounters output by the Encounter Generation Tool have the characteristics specified by the input files. This function plots the distributions of altitude and speed for both the ownship and intruder at TCA. Because the distributions of aircraft altitudes and speeds are rarely a set distribution (e.g., Gaussian), it will be up to the user to verify visually that altitude and speed distributions match expectations. The specific encounter sets generated are 1) Encounters between two aircraft sampled from the Uncorrelated Encounter Model (with and without 500 ft altitude quantization), and 2) Encounters between a HALE (High Altitude Long Endurance) UAS and a MALE (Medium Altitude Long Endurance) UAS.

This function also tests that the max/min airspeed/altitude limits are properly enforced and that the tool can successfully generate encounters from a set of trajectories. One hundred trajectories sampled from the Uncorrelated Encounter Model are included with this distribution for testing purposes.

**Note:** this test generates 10,000 encounters for each set of test inputs, so the test will take some time to run.

### Dynamics Model Verification (`runDynamicsFastTests.m`)

The purpose of this test is to verify that `runDynamicsFast.c` (a version of the DEGAS dynamics written in C) has been properly implemented. This is important because the dynamics are used to convert sampled encounter model events into trajectories, which are used to generate the encounters. This test checks that commanded turn rate, vertical rate, and accelerations are properly followed.

**Note:** should the simulation used to run the generated encounters have different dynamics assumptions (e.g., maximum climb rate/turn rate limits), then the simulated encounters may not have the same CPA characteristics (e.g., HMD, VMD) that is in the saved encounter metadata. This will alter the assumptions of the model (e.g., those used to compute importance sampling weights). Thus, the user should consider replacing the dynamics model (runDynamicsFast) with their own when generating encounters.

### Trajectory to Events Verification (`runTrajectoryEventsVerificationTests.m`)

The purpose of this test is to ensure that the functions used to convert waypoints to events and vice versa function properly. These functions are pivotal to being able to generate encounters from both encounter model events and user-defined trajectories, and being able to save the encounters as either events or trajectories.

This test converts input events into waypoints and then plots the results. The test then takes the waypoints converts them into events, and then plots the results by running the events through the dynamics model. The two resulting plots should match.

### P(nmac) Gas Model Test (`runPnmacGasModelTests.m`)

The purpose of this test is to verify that the importance sampling weights have been computed correctly. To do this, P(NMAC | successively larger encounter cylinder volumes) are computed using the generated encounters and their corresponding encounter weights. An NMAC is a near mid-air collision, defined as 500 ft of separation horizontally, and 100 ft of separation vertically. This test verifies that the results match the encounter model (gas) assumption described in this [paper](https://doi.org/10.1017/S0373463300018683):

<div align="center"> p(NMAC)<sub>Gas Model</sub> = (<i>h<sub>nmac</sub></i> * <i>v<sub>nmac</sub></i>)/(<i>h<sub>enc</sub></i> * <i>v<sub>enc</sub></i>),</div>
<br>
where <i>h<sub>nmac</sub></i> = 500 ft, <i>v<sub>nmac</sub></i> = 100 ft (the dimensions of an NMAC cylinder), and <i>h<sub>enc</sub></i> and <i>v<sub>enc</sub></i> are the dimensions of the test cylinder. If the importance sampling methods have been properly implemented, p(NMAC) for the encounters and the gas model should be similar.

### DEGAS Integration Verification (`runEncounterWithDEGASTests.m`)

The purpose of the DEGAS integration test is to verify that encounters generated using the Encounter Generation Tool can be used in DEGAS. This test requires the DEGAS directory to be on the user’s Matlab path. This test will create an instance of a NominalEncounter DEGAS class, set up a simulation to use one of the encounters generated in `runInputParameterDistributionTests.m`, and run the simulation. The integration test is successful if no errors occur.

## Distribution Statement

DISTRIBUTION STATEMENT A. Approved for public release. Distribution is unlimited.

© 2018, 2019, 2020 Massachusetts Institute of Technology.

This material is based upon work supported by the National Aeronautics and Space Administration under Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, conclusions or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the National Aeronautics and Space Administration .

Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, U.S. Government rights in this work are defined by DFARS 252.227-7013 or DFARS 252.227-7014 as detailed above. Use of this work other than as specifically authorized by the U.S. Government may violate any copyrights that exist in this work.
