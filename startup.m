% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%% Startup script
% This script should be run before using the encounter model tool. It
% generates and adds all paths in the DAA_Encounter_Tool directory to the
% MATLAB Path.

disp(['Running DAA Encounter Tool startup script...' '(' which('startup') ')'] );

% Self
disp('Adding repository to path');
addpath(genpath(pwd()));

% AEM_DIR_CORE
disp('Adding em-core/matlab to path');
if isempty(getenv('AEM_DIR_CORE'))
    error('startup:aem_dir_core','System environment variable, AEM_DIR_CORE, not found\n')
else
    addpath(genpath([getenv('AEM_DIR_CORE') filesep 'matlab']))
end

% AEM_DIR_BAYES
disp('Adding em-model-manned-bayes matlab code and matlab code to path');
if isempty(getenv('AEM_DIR_BAYES'))
    error('startup:aem_dir_bayes','System environment variable, AEM_DIR_BAYES, not found\n')
else
    addpath(genpath([getenv('AEM_DIR_BAYES') filesep 'code' filesep 'matlab']))
    addpath(genpath([getenv('AEM_DIR_BAYES') filesep 'model']))
end

% DEGAS
if isempty(getenv('DEGAS_HOME'))
    disp('Reminder to add DEGAS to path, if you have access to it');
else
    addpath(genpath(getenv('AEM_DIR_BAYES')));
end

% Check for environment variable AEM_DIR_DAAENC
if isempty(getenv('AEM_DIR_DAAENC'))
    error('startup:aem_dir_daaenc','System environment variable, AEM_DIR_DAAENC, not found\n')
end

disp('Startup Done!'); %Finished!
