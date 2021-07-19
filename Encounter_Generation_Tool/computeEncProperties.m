function [encMetadata, encProperties] = computeEncProperties(trajectory1, trajectory2, properties)
% Copyright 2018 - 2021, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%This function returns information about the encounters: 
%
%encMetaData includes intruder/ownship height and speed at TCA, HMD, VMD,
%TCA, whether an NMAC occurs, encounter weight, encounter duration
%(simtime), and whether the ownship/intruder has a nominal maneuver
%
%encProperties contains the ownship/intruder heights and speeds over the
%entire encounter. This is used to filter by min/max height/speeds limits,
%if desired. 
% SEE ALSO preallocateEncProperties

%Constants
fps2kts = 0.592483801295896;

% CPA Metrics
[encMetadata.hmd, encMetadata.vmd, encMetadata.tca, encMetadata.nmac] = getCPAMetrics(trajectory1, trajectory2); 
encMetadata.w = properties.w;
encMetadata.id = properties.id;
encMetadata.simTime = properties.simtime;

% Over the entire encounter
encProperties.own_alt_ft = trajectory1.up_ft;
encProperties.own_gs_ftps = trajectory1.speed_ftps;
encProperties.own_gs_kt = trajectory1.speed_ftps * fps2kts;
encProperties.int_alt_ft = trajectory2.up_ft;
encProperties.int_gs_ftps = trajectory2.speed_ftps;
encProperties.int_gs_kt = trajectory2.speed_ftps * fps2kts;

%Speed/Height at TCA
encMetadata.ownHeightAtTCA_ft = encProperties.own_alt_ft(encMetadata.tca);
encMetadata.intHeightAtTCA_ft = encProperties.int_alt_ft(encMetadata.tca);
encMetadata.ownSpeedAtTCA_kt = encProperties.own_gs_kt(encMetadata.tca);
encMetadata.intSpeedAtTCA_kt = encProperties.int_gs_kt(encMetadata.tca);

%Initial Speed/Height
encMetadata.ownInitialHeight_ft = encProperties.own_alt_ft(1);
encMetadata.intInitialHeight_ft = encProperties.int_alt_ft(1);
encMetadata.ownInitialSpeed_kt = encProperties.own_gs_kt(1);
encMetadata.intInitialSpeed_kt = encProperties.int_gs_kt(1);

% Ouputs 1, if the ownship/intruder has a nominal turn/climb maneuver
[encMetadata.ownshipHorzManeuver, encMetadata.ownshipVertManeuver, ...
    encMetadata.intruderHorzManeuver, encMetadata.intruderVertManeuver, ...
    encMetadata.anyOwnHorzManeuverBeforeTCA, encMetadata.anyOwnVertManeuverBeforeTCA, ...
    encMetadata.anyIntHorzManeuverBeforeTCA, encMetadata.anyIntVertManeuverBeforeTCA] = getNominalManeuvers(trajectory1, trajectory2, encMetadata.tca); 

end