# Example_Outputs

## Encounters

The user has the option to output encounters as ScriptedEncounter objects containing encounter model events or as trajectory files. These outputs are saved in the directory specified in the .INI file.

### Scripted Encounters

Encounters may be saved as instances of the `ScriptedEncounters.m` class. ScriptedEncounters are objects that contain the initial geometry of the encounter and updates in the form of `EncounterModelEvents.m` objects. The initial geometry for the ownship and intruder is stored as 2-element vectors: the first entry is for the ownship and the second entry is for the intruder. The initial encounter geometry includes the following:

- Velocity (v_ftps)
- North (n_ft)
- East (e_ft)
- Altitude (h_ft)
- Heading (heading_rad)
- Pitch Angle (pitch_rad)
- Bank Angle (bank_rad)
- Longitudinal Acceleration (a_ftpss)

Each ScriptedEncounters object includes an EncounterModelEvents object. EncounterModelEvents include an _event_ matrix, which is an nx4 matrix. The columns of this matrix are [time (sec), vertical rate (ftps), turn rate (radps), longitudinal acceleration (ftpss)]. There is one row for each timestep where there is a change in the dynamics.

**Note:** the _event_ matrix must always have an event at time 0. If there are no maneuvers at time 0, the first event is [0, 0, 0, 0].

Encounters in this format are ready to be used with DEGAS. A struct containing ScriptedEncounters objects for all generated encounters will be saved in a .mat file named `scriptedEncounters.mat`. This folder includes an example `scriptedEncounters.mat`.

### Trajectory Files

Encounters may be output in trajectory files. One trajectory file contains the trajectories for both the ownship and the intruder. Each trajectory file contains the following columns:

| Variable: | Name | East | North | Altitude (AGL) | Heading | Speed | Vertical Speed | Time |
| --- | --- | --- |--- |--- |--- |--- |--- |--- |
| **Units:**  | Ownship or Intruder | ft | ft | ft | rad | ftps | ftps | sec |

See files `1.txt` through `5.txt` in this folder for example output trajectory files. `readTrajFiles.m` can be used to read the trajectory file data into a results struct.

## Metadata

For each encounter, the Encounter Generation Tool outputs a metadata (.mat) file that contains a struct with the variables in the following table – see `metadata.mat` in this folder for an example. These values can be used to select a subset of encounters to run or analyze in a DAA analysis. All closest point of approach (CPA) properties are computed for horizontal CPA, which occurs when the two aircraft are at the minimum horizontal distance away from each other.

| Variable | Description |
|---|---|
| id | Unique ID assigned to the encounter (range of IDs are specified in the .INI file) |
| w | Weight given to each encounter when computing metrics (e.g., risk ratio) |
| simTime | Length of the encounter  |
| nmac | True, if an encounter has an NMAC. False, otherwise.  |
| CPA Properties: <br><br> hmd <br>vmd <br>tca | Horizontal miss distance (HMD), vertical miss distance (VMD),  time of closest approach (TCA) |
| Ownship/Intruder Properties at TCA: <br><br> ownHeightAtTCA_ft <br> intHeightAtTCA_ft <br>ownSpeedAtTCA_kt <br>intSpeedAtTCA_kt  | Ownship/intruder speed and altitude at TCA  |
| Ownship/Intruder Initial Properties: <br><br> ownInitialHeight_ft <br> intInitialHeight_ft <br> ownInitialSpeed_kt <br>intInitialSpeed_kt  | Ownship/intruder speed and altitude at start of encounter  |
| New Nominal Maneuvers: <br><br>ownshipHorzManeuver <br> ownshipVertManeuver <br> intruderHorzManeuver <br> intruderVertManeuver  | True, if a new horizontal or vertical maneuver is issued for the ownship/intruder before TCA. A new horizontal maneuver is a change from straight flight to a turn. A new vertical maneuver is a change from level flight to a climb or descend.  |
| Any Nominal Maneuvers: <br><br>anyOwnHorzManeuverBeforeTCA <br> anyOwnHorzManeuverBeforeTCA <br>anyIntHorzManeuverBeforeTCA <br> anyIntVertManeuverBeforeTCA | True, if the ownship/intruder has a vertical rate or is turning at any point before TCA.<br><br>These variables are distinct from the previous variables in that these variables includes encounters where the ownship or intruder may have been climbing or turning continuously from the start of the encounter. |

## Distribution Statement

DISTRIBUTION STATEMENT A. Approved for public release. Distribution is unlimited.

© 2018, 2019, 2020, 2021 Massachusetts Institute of Technology.

This material is based upon work supported by the National Aeronautics and Space Administration under Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, conclusions or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the National Aeronautics and Space Administration .

Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice, U.S. Government rights in this work are defined by DFARS 252.227-7013 or DFARS 252.227-7014 as detailed above. Use of this work other than as specifically authorized by the U.S. Government may violate any copyrights that exist in this work.
