% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
% This script demonstrates how to iterate over multiple .ini files to
% create different encounter sets

%% Inputs
% Directory of .ini files
dirParent = [getenv('AEM_DIR_DAAENC') filesep 'Example_Inputs'];

% Filenames of .ini files
parameterFiles = {[dirParent filesep 'FWMEVsFWME.ini'];...
    [dirParent filesep 'FWSEVsFWSE.ini'];...
    [dirParent filesep 'FWSEVsRotorcraft.ini'];...
    [dirParent filesep 'RotorcraftVsRotorcraft.ini'];...
    [dirParent filesep 'UncorVsUncor.ini'];};

%% Generate Uncorrelated Encounters
for i = 1:1:numel(parameterFiles)
    generateDAAEncounterSet(parameterFiles{i});
end
