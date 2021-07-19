function [encMetadata, encProperties] = preallocateEncProperties(numEnc)
% Copyright 2018 - 2021, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%This function preallocates information about the encounters:
%
%encMetaData includes intruder/ownship height and speed at TCA, HMD, VMD,
%TCA, whether an NMAC occurs, encounter weight, encounter duration
%(simtime), and whether the ownship/intruder has a nominal maneuver
%
%encProperties contains the ownship/intruder heights and speeds over the
%entire encounter. This is used to filter by min/max height/speeds limits,
%if desired.
% SEE ALSO: computeEncProperties generateDAAEncounterSet

% Input handling
if nargin < 1
    numEnc = 1;
end

% CPA Metrics
encMetadata(numEnc).hmd = [];
encMetadata(numEnc).vmd = [];
encMetadata(numEnc).tca = [];
encMetadata(numEnc).nmac = [];
encMetadata(numEnc).w = [];
encMetadata(numEnc).id = [];
encMetadata(numEnc).simTime = [];

%Speed/Height at TCA
encMetadata(numEnc).ownHeightAtTCA_ft = [];
encMetadata(numEnc).intHeightAtTCA_ft = [];
encMetadata(numEnc).ownSpeedAtTCA_kt = [];
encMetadata(numEnc).intSpeedAtTCA_kt = [];

%Initial Speed/Height
encMetadata(numEnc).ownInitialHeight_ft = [];
encMetadata(numEnc).intInitialHeight_ft = [];
encMetadata(numEnc).ownInitialSpeed_kt = [];
encMetadata(numEnc).intInitialSpeed_kt = [];

% Ouputs 1, if the ownship/intruder has a nominal turn/climb maneuver
encMetadata(numEnc).ownshipHorzManeuver = [];
encMetadata(numEnc).ownshipVertManeuver = [];
encMetadata(numEnc).intruderHorzManeuver = [];
encMetadata(numEnc).intruderVertManeuver = [];
encMetadata(numEnc).anyOwnHorzManeuverBeforeTCA = [];
encMetadata(numEnc).anyOwnVertManeuverBeforeTCA = [];
encMetadata(numEnc).anyIntHorzManeuverBeforeTCA = [];
encMetadata(numEnc).anyIntVertManeuverBeforeTCA = [];

% Over the entire encounter
encProperties(numEnc).own_alt_ft = [];
encProperties(numEnc).own_gs_ftps = [];
encProperties(numEnc).own_gs_kt = [];
encProperties(numEnc).int_alt_ft = [];
encProperties(numEnc).int_gs_ftps = [];
encProperties(numEnc).int_gs_kt = [];
end
