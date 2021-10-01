function generateDAAEncounterSet(parameterFile)
% Copyright 2018 - 2021, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
% Generates encounters between ownship and intruder aircraft. User may
% sample the ownship/intruder trajectories from an encounter model (default
% is the uncorrelated encounter model) or from a set of trajectories. User
% may choose to save the generated encounters as events and/or
% trajectories. Encounter weights are also generated and saved.
%
% INPUTS
% ------
% parameterFile - encounter set characteristics (saved as .ini file)
% ----
%
% SEE ALSO UncorEncounterModel checkINIInputs sampleFullUncorModel run_dynamics_fast initializeUncorrelatedEncounter 

%% Verify INI inputs
checkINIInputs(parameterFile);

%% Set up variables
% load constants
constants = load_constants;

% Parse ini file
iniSettings = ini2struct (parameterFile);
sample_time = iniSettings.sample_time;

% Verbose level
if isfield (iniSettings, 'verbose_level')
    verbose_level = iniSettings.verbose_level;
else
    verbose_level = 0;
end

% Number of encounters and their ids
encIds = iniSettings.encIds;
N = length(encIds);

% Output save directory
saveDirectory = [getenv('AEM_DIR_DAAENC') filesep iniSettings.saveDirectory];

% alt layers
dim1 = length(iniSettings.altLayers) / 2;
layers = reshape(iniSettings.altLayers, 2, dim1)';

% Default start used by dbn_hierarchical_sample() in sampleFullUncorModel()
% Fix geographic region as CONUS (=1), airspace class as other (=4). Optional setting.
startDefault = {1,4,[],[],[],[],[]};

% Dynamic constraints
% v_low,v_high,dh_ftps_min,dh_ftps_max,qmax,rmax
% ftps, ftps, ftps, ftps, rad, rad
dyn1 = [1.7 1116 -10000 10000 deg2rad(3), 1000000];
dyn2 = [1.7 1116 -10000 10000 deg2rad(3), 1000000];

trajPerWrite = 10;
counterWrite = 0;

%% Preallocate
% Create save directory if it doesn't exist
if ~exist(saveDirectory,'dir')
    mkdir(saveDirectory);
end

% Preallocate samples array
if iniSettings.outputEvents
    samples(N,1) = ScriptedEncounter;
end

% Preallocate performance benchmarks
numTrials = zeros(N,1);
jobTime_s = zeros(N,1);

%% Set up encounter models
%Set up ownship encounter model
if iniSettings.ownshipSampleTrajectory
    %Read in trajectory metadata
    metadata = readtable(iniSettings.ownship_trajectory_datafile);
else
    % load encounter model with sufficient statistics for ownship
    
    
    % Instantiate object
    encFile1 = [getenv('AEM_DIR_BAYES') filesep 'model' filesep iniSettings.ownshipEmFile];
    ac1 = UncorEncounterModel('parameters_filename',encFile1,'isOverwriteZeroBoundaries',true,'idxZeroBoundaries',[1 2 3]);
    
    %Read in customized encounter model variables, if provided
    if ~isempty(iniSettings.ownEncVariablesFile)
        iniSettings.ownEncVariablesFile = strrep(iniSettings.ownEncVariablesFile,'/','\');
        k = strfind(iniSettings.ownEncVariablesFile,'\');
        folderpath = iniSettings.ownEncVariablesFile(1:k(end)-1);
        addpath(folderpath);
        filename = split(iniSettings.ownEncVariablesFile,'\');
        filename = filename{end};
        if length(filename)>2 && strcmp(filename(end-1:end),'.m')
            filename = filename(1:end-2);
        end
        [ac1.G_initial, ac1.r_initial, ac1.G_transition, ac1.r_transition, ac1.temporal_map, ac1.zero_bins, ac1.labels_initial, ac1.labels_transition, ac1.boundaries, ac1.resample_rates] = feval(filename);
    end
    
    %Read in customized encounter model statistics, if provided
    if ~isempty(iniSettings.ownEncStatisticsFile)
        iniSettings.ownEncStatisticsFile = strrep(iniSettings.ownEncStatisticsFile,'/','\');
        k = strfind(iniSettings.ownEncStatisticsFile,'\');
        folderpath = iniSettings.ownEncStatisticsFile(1:k(end)-1);
        addpath(folderpath);
        filename = split(iniSettings.ownEncStatisticsFile,'\');
        filename = filename{end};
        if length(filename)>2 && strcmp(filename(end-1:end),'.m')
            filename = filename(1:end-2);
        end
        [ac1.N_initial, ac1.N_transition] = feval(filename);
    end
    
    %Verify encounter model inputs
    checkEncounterModelInputs(ac1);
    
    % Set up dirichlets
    % dirchlets updated when prior is updated
    ac1.isAutoUpdate = true;
    ac1.prior = 0;
end

%Set up intruder encounter model
if iniSettings.intruderSampleTrajectory
    %Read in trajectory metadata
    metadata = readtable(iniSettings.intruder_trajectory_datafile);
else
    % load encounter model with sufficient statistics for intruder
    encFile2 = [getenv('AEM_DIR_BAYES') filesep 'model' filesep iniSettings.intruderEmFile];
    ac2 = UncorEncounterModel('parameters_filename',encFile2,'isOverwriteZeroBoundaries',true,'idxZeroBoundaries',[1 2 3]);

    %Read in customized encounter model variables, if provided
    if ~isempty(iniSettings.intEncVariablesFile)
        iniSettings.intEncVariablesFile = strrep(iniSettings.intEncVariablesFile,'/','\');
        k = strfind(iniSettings.intEncVariablesFile,'\');
        folderpath = iniSettings.intEncVariablesFile(1:k(end)-1);
        addpath(folderpath);
        filename = split(iniSettings.intEncVariablesFile,'\');
        filename = filename{end};
        if length(filename)>2 && strcmp(filename(end-1:end),'.m')
            filename = filename(1:end-2);
        end
        [ac2.G_initial, ac2.r_initial, ac2.G_transition, ac2.r_transition, ac2.temporal_map, ac2.zero_bins, ac2.labels_initial, ac2.labels_transition, ac2.boundaries, ac2.resample_rates] = feval(filename);
    end
    
    %Read in customized encounter model statistics, if provided
    if ~isempty(iniSettings.intEncStatisticsFile)
        iniSettings.intEncStatisticsFile = strrep(iniSettings.intEncStatisticsFile,'/','\');
        k = strfind(iniSettings.intEncStatisticsFile,'\');
        folderpath = iniSettings.intEncStatisticsFile(1:k(end)-1);
        addpath(folderpath);
        filename = split(iniSettings.intEncStatisticsFile,'\');
        filename = filename{end};
        if length(filename)>2 && strcmp(filename(end-1:end),'.m')
            filename = filename(1:end-2);
        end
        [ac2.N_initial, ac2.N_transition] = feval(filename);
    end
    
    %Verify encounter model inputs
    checkEncounterModelInputs(ac2);
    
    % Set up dirichlets
    % dirchlets updated when prior is updated
    ac2.isAutoUpdate = true;
    ac2.prior = 0;
end

%% Pair up encounters by height
%VMD Bins
bin_edges_VMD = iniSettings.bin_edges_VMD;
desired_proportions = iniSettings.desired_proportions_VMD;
pdf_values = desired_proportions/sum(desired_proportions);
pdf_values_VMD = pdf_values./diff(bin_edges_VMD);

%Get weight probabilities
denominator = 0;
for i = 1:length(pdf_values_VMD)
    denominator = denominator + (bin_edges_VMD(i+1)-bin_edges_VMD(i))*pdf_values_VMD(i);
end
x = 1/denominator;
cdf_y_edges = cumsum(diff(bin_edges_VMD).*pdf_values_VMD*x);

cdf_y_edges = [0, cdf_y_edges];
bin_probs = diff(cdf_y_edges);

%Normalize the bin_probs to reduce the rejection rate:
bin_probs = bin_probs/max(bin_probs);

%Set up bin_edges so that relative altitudes outside of max VMD are
%rejected
bin_edges_VMD = [-Inf, bin_edges_VMD, Inf];
bin_probs = [0, bin_probs, 0];

% Set minimum initial separation between ownship and intruder
H_min = iniSettings.H_min;
R_min = iniSettings.R_min * constants.nm2ft;
maxHMD = 10 * constants.nm2ft; %Needed for line sampling

%HMD Bins
bin_edges_HMD = iniSettings.bin_edges_HMD;
desired_proportions = iniSettings.desired_proportions_HMD;

pdf_values = desired_proportions/sum(desired_proportions);
pdf_values_HMD = pdf_values./diff(bin_edges_HMD);

if isfield (iniSettings, 'randSeed')
    randSeed =  iniSettings.randSeed;
else
    randSeed = 0;
end
maxSeed = 2^32;

%% Generate Encounter
isFailed = false;

% Preallocate information about the encounters
[enc_metadata, ~] = preallocateEncProperties(N);

for j = 1:N %Loop through number of encounters
    % Start timer for jobTime_s
    tic
    
    % Preallocate output trajectory
    trajectoryOut1 = struct;
    trajectoryOut2 = struct;
    paramsOut = UncorEncounterParameters;
    
    % Preallocate logical flag and counter
    encounterOk = false;
    counterTrials = 0;
    
    % Display status
    if verbose_level <= 2
        fprintf('***********\nGenerating encounter %u\n', encIds(j));
    end
    
    while ~encounterOk
        counterTrials = counterTrials + 1;
        tCPA = iniSettings.tCPA; %Desired time of CPA
        
        % Update random seed
        randSeed = randSeed + 1;
        if randSeed < maxSeed
            rng(randSeed);
        else
            warning('Maximum random seed exceeded, seed not updated');
        end
        
        % Display counter
        if verbose_level <= 1
            fprintf('Trial %u, randSeed %u\n', counterTrials, randSeed);
        end
        
        %% Draw sample for ac1
        if iniSettings.ownshipSampleTrajectory
            %Sample ownship trajectory from a set of trajectories located in user-specified folder
            trajectoryDirectory = iniSettings.ownship_trajectory_dir;
            nSamps = 1; %one sample at a time
            duration = iniSettings.sample_time;
            applyFilter = iniSettings.applyOwnshipFilterSampling;
            minOwnAlt = iniSettings.minOwnAlt_ft;
            maxOwnAlt = iniSettings.maxOwnAlt_ft;
            minOwnSpeed = iniSettings.minOwnSpeed_kts;
            maxOwnSpeed = iniSettings.maxOwnSpeed_kts;
            minOwnAltType = iniSettings.minOwnAltType;
            maxOwnAltType = iniSettings.maxOwnAltType;
            
            [trajectory1, elevations_own] = sampleTrajectory(metadata,trajectoryDirectory,nSamps,duration+1,applyFilter,...
                minOwnAlt,maxOwnAlt,minOwnSpeed, maxOwnSpeed, minOwnAltType, maxOwnAltType, iniSettings.sampleByDurationOwnship);
            trajectory1 = upsampleTrajectory(trajectory1{1}); % upsample the results to 10hz. *IMPORTANT: assumes input trajectories are 1hz*
            sample1 = [];
        else
            
            if isempty(iniSettings.ownEncVariablesFile) && isempty(iniSettings.ownEncStatisticsFile)
                start = startDefault;
            else
                start = {[],[],[],[],[],[],[]};
            end
            ac1.start = start;
            
            [sample1, event1, ic1] = sampleFullUncorModel(encIds(j),ac1,sample_time,layers,logical(iniSettings.quantizeOwnshipAlt500));
            trajectory1 = [];
        end
        
        %% Draw sample for ac2
        % (do not fix altitude layer)
        if iniSettings.intruderSampleTrajectory
            % Sample intruder trajectory from a set of trajectories located in user-specified folder
            trajectoryDirectory = iniSettings.intruder_trajectory_dir;
            nSamps = 1; % one sample at a time
            duration = iniSettings.sample_time;
            applyFilter = iniSettings.applyIntruderFilterSampling;
            minIntAlt = iniSettings.minIntAlt_ft;
            maxIntAlt = iniSettings.maxIntAlt_ft;
            minIntSpeed = iniSettings.minIntSpeed_kts;
            maxIntSpeed = iniSettings.maxIntSpeed_kts;
            minIntAltType = iniSettings.minIntAltType;
            maxIntAltType = iniSettings.maxIntAltType;
            
            [trajectory2, elevations_int] = sampleTrajectory(metadata,trajectoryDirectory,nSamps,duration+1,applyFilter,...
                minIntAlt,maxIntAlt,minIntSpeed, maxIntSpeed, minIntAltType, maxIntAltType, iniSettings.sampleByDurationIntruder);
            trajectory2 = upsampleTrajectory(trajectory2{1}); % upsample the results to 10hz. *IMPORTANT: assumes input trajectories are 1hz*
            sample2 = [];
        else
            
            if isempty(iniSettings.intEncVariablesFile) && isempty(iniSettings.intEncStatisticsFile)
                start = startDefault;
            else
                start = {[],[],[],[],[],[],[]};
            end
            ac2.start = start;
            
            % Sample from encounter model
            [sample2, event2, ic2] = sampleFullUncorModel(encIds(j),ac2,sample_time,layers,logical(iniSettings.quantizeIntruderAlt500));
            trajectory2 = [];
        end
        
        %% check negative velocities and altitudes
        if ~iniSettings.ownshipSampleTrajectory || ~iniSettings.intruderSampleTrajectory
            if isempty(sample2)
                results = run_dynamics_fast(ic1,event1,dyn1,ic1,event1,dyn1,sample_time);
            elseif isempty(sample1)
                results = run_dynamics_fast(ic2,event2,dy2,ic2,event2,dyn2,sample_time);
            elseif ~isempty(sample1) && ~isempty(sample2)
                results = run_dynamics_fast(ic1,event1,dyn1,ic2,event2,dyn2,sample_time);
            end
            
            if any(results(1).speed_ftps<0  | results(2).speed_ftps<0 | results(1).up_ft<0 | results(2).up_ft<0)
                if verbose_level <= 0
                    disp('reject: negative velocities or altitudes');
                end
                continue; % Reject encounter model samples with negative velocities
            end
        end
        
        %% Try to achieve desired VMD distribution
        indtime = tCPA*10+1; % results are in 10hz, so update indtime accordingly
        randNum = rand(1);
        if iniSettings.ownshipSampleTrajectory
            height_ft = trajectory1.up_ft(indtime); % ownship height at TCA from trajectory
        else
            height_ft = results(1).up_ft(indtime); % ownship height at TCA from encounter model
        end
        if iniSettings.intruderSampleTrajectory
            intheight = trajectory2.up_ft(indtime); % intruder height at TCA from trajectory
        else
            intheight = results(2).up_ft(indtime); % intruder height at TCA from encounter model
        end
        relHeight = intheight - height_ft;
        binIndex = find(relHeight<bin_edges_VMD,1)-1;
        
        if isnan(height_ft) || isnan(intheight) % Make sure there are no NaNs
            encounterOk = false;
            if verbose_level <= 0
                disp('reject: NaN height');
            end
            continue;
        elseif (randNum>bin_probs(binIndex)) % Perform rejection sampling to achieve desired VMD distribution
            encounterOk = false;
            if verbose_level <= 0
                disp('reject: VMD bin sampling');
            end
            continue;
        else
            vmd_weights = 1/bin_probs(binIndex);
        end
        
        %fprintf('\n\n Getting height at TCA for encounter %u\n\n',encIds(j))
        encounterOk = true;
        
        if encounterOk
            %% initialize encounter
            uncorrelatedParametersIn = UncorEncounterParameters(tCPA, sample_time, isFailed, height_ft, intheight, maxHMD);
            uncorrelatedParametersIn.id = encIds(j);

            %Transform events into waypoint trajectories
            if ~iniSettings.ownshipSampleTrajectory && iniSettings.intruderSampleTrajectory
                results = run_dynamics_fast(ic1,event1,dyn1,ic1,event1,dyn1,iniSettings.sample_time);
                trajectory1 = results(1);
            elseif iniSettings.ownshipSampleTrajectory && ~iniSettings.intruderSampleTrajectory
                results = run_dynamics_fast(ic2,event2,dyn2,ic2,event2,dyn2,iniSettings.sample_time);
                trajectory2 = results(2);
            elseif ~iniSettings.ownshipSampleTrajectory && ~iniSettings.intruderSampleTrajectory
               results = run_dynamics_fast(ic1,event1,dyn1,ic2,event2,dyn2,iniSettings.sample_time);

                trajectory1 = results(1);
                trajectory2 = results(2);
            end
            
            %Initialize the encounter geometry
            [trajectoryOut1, trajectoryOut2, paramsOut, isFailed] = initializeUncorrelatedEncounter(trajectory1, trajectory2, uncorrelatedParametersIn, ...
                'tca_s',uncorrelatedParametersIn.tca, 'delta_h_init_min_ft', H_min, 'delta_h_init_min_ft', R_min, 'vmd_weights', vmd_weights,...
                'proposed_bin_edges_HMD_ft',bin_edges_HMD, 'proposed_pdf_values_HMD',pdf_values_HMD);
            
            hmd_ft = paramsOut.hmd;
            vmd_ft = paramsOut.intHeightAtTCA - paramsOut.ownHeightAtTCA;
            
            % Run encounter properties calculator, and collect property data:
            %   vmd, hmd, tca, runtime, intr_alt_ft (array), intr_gs_ftps (array)
            [j_metadata,j_properties] = computeEncProperties(trajectoryOut1, trajectoryOut2, paramsOut);
            
            if ~isFailed
                
                if verbose_level <= 0
                    fprintf('vmd_ft = %f, vmd = %f\n', j_metadata.vmd, abs(vmd_ft));
                    fprintf('hmd_ft = %f, hmd = %f\n', j_metadata.hmd, abs(hmd_ft));
                end
                
                if abs(j_metadata.vmd - abs(vmd_ft)) < 20 && abs(j_metadata.hmd - abs(hmd_ft)) < 500 % Ensure generated encounter has the desired hmd/vmd
                    encounterOk = true;
                else
                    encounterOk = false;
                    if verbose_level <= 0
                        disp('Reject: hmd/vmd mismatch');
                    end
                end
                
                %% Check that altitude and speed fall with the constraints
                % Constraints are specified in the INI file
                maxIntAlt_ft = iniSettings.maxIntAlt_ft;
                minIntAlt_ft = iniSettings.minIntAlt_ft;
                maxOwnAlt_ft = iniSettings.maxOwnAlt_ft;
                minOwnAlt_ft = iniSettings.minOwnAlt_ft;
                
                if strcmpi(iniSettings.minIntAltType,'MSL') && iniSettings.intruderSampleTrajectory
                    %Convert the criteria to AGL - ensure altitude limit is non-negative
                    minIntAlt_ft = max(0,iniSettings.minIntAlt_ft - elevations_int);
                end
                if strcmpi(iniSettings.maxIntAltType,'MSL') && iniSettings.intruderSampleTrajectory
                    %Convert the criteria to AGL - ensure altitude limit is non-negative
                    maxIntAlt_ft = max(0,iniSettings.maxIntAlt_ft - elevations_int);
                end
                if strcmpi(iniSettings.minOwnAltType,'MSL') && iniSettings.ownshipSampleTrajectory
                    %Convert the criteria to AGL - ensure altitude limit is non-negative
                    minOwnAlt_ft = max(0,iniSettings.minOwnAlt_ft - elevations_own);
                end
                if strcmpi(iniSettings.maxOwnAltType,'MSL') && iniSettings.ownshipSampleTrajectory
                    %Convert the criteria to AGL - ensure altitude limit is non-negative
                    maxOwnAlt_ft = max(0,iniSettings.maxOwnAlt_ft - elevations_own);
                end
                
                %Perform intruder filtering at CPA
                if iniSettings.applyIntruderFilterAtCPA
                    tca = round(j_metadata.tca);
                    if j_properties.int_alt_ft(tca) > maxIntAlt_ft || ...
                            j_properties.int_alt_ft(tca) < minIntAlt_ft || ...
                            j_properties.int_gs_kt(tca) > iniSettings.maxIntSpeed_kts || ...
                            j_properties.int_gs_kt(tca) < iniSettings.minIntSpeed_kts
                        encounterOk = false;
                        if verbose_level <= 0
                            disp('Reject: intruder altitude/airspeed constraints at CPA');
                        end
                    end
                end
                
                %Perform inturder filtering over the entire encounter
                if iniSettings.applyIntruderFilterWholeEncounter
                    if any(j_properties.int_alt_ft > maxIntAlt_ft) || ...
                            any(j_properties.int_alt_ft < minIntAlt_ft) || ...
                            any(j_properties.int_gs_kt > iniSettings.maxIntSpeed_kts) || ...
                            any(j_properties.int_gs_kt < iniSettings.minIntSpeed_kts)
                        encounterOk = false;
                        if verbose_level <= 0
                            disp('Reject: intruder altitude/airspeed constraints over entire encounter');
                        end
                    end
                end
                
                %Perform ownship filtering at CPA
                if iniSettings.applyOwnshipFilterAtCPA
                    tca = round(j_metadata.tca);
                    if j_properties.own_alt_ft(tca) > maxOwnAlt_ft || ...
                            j_properties.own_alt_ft(tca) < minOwnAlt_ft || ...
                            j_properties.own_gs_kt(tca) > iniSettings.maxOwnSpeed_kts || ...
                            j_properties.own_gs_kt(tca) < iniSettings.minOwnSpeed_kts
                        encounterOk = false;
                        if verbose_level <= 0
                            disp('Reject: ownship altitude/airspeed constraints at CPA');
                        end
                    end
                end
                
                %Perform ownship filtering over the entire encounter
                if iniSettings.applyOwnshipFilterWholeEncounter
                    if any(j_properties.own_alt_ft > maxOwnAlt_ft) || ...
                            any(j_properties.own_alt_ft < minOwnAlt_ft) || ...
                            any(j_properties.own_gs_kt > iniSettings.maxOwnSpeed_kts) || ...
                            any(j_properties.own_gs_kt < iniSettings.minOwnSpeed_kts)
                        encounterOk = false;
                        if verbose_level <= 0
                            disp('Reject: ownship altitude/airspeed constraints over the entire encounter');
                        end
                    end
                end
                
                if j_metadata.tca < iniSettings.tCPA || paramsOut.tca < iniSettings.tCPA
                    encounterOk = false;
                    if verbose_level <= 0
                        disp('Reject: tca occurs too early');
                    end
                end
                
            else
                encounterOk = false;
                if verbose_level <= 0
                    disp('Reject: initialization function');
                end
            end
        end
    end
    
    % Assign metadata and properties
    enc_metadata(j) = j_metadata;
    %enc_properties(j) = j_properties; % Not used elsewhere, so not saved
    
    %Save trajectories in output files
    if iniSettings.outputTrajectories
        %Output results to trajectory file
        writeTrajectoryToFile(trajectoryOut1, trajectoryOut2, encIds(j), saveDirectory);
    end
    
    %If desired, convert trajectories to events
    if iniSettings.outputEvents
        samples(j) = wpt2script(trajectoryOut1, trajectoryOut2, encIds(j), layers);
    end
    
    % Record number of trials and time required to generate encounter
    numTrials(j) = counterTrials;
    jobTime_s(j) = toc;
    %     counterWrite = counterWrite + 1;
    %     if counterWrite >= trajPerWrite
    %
    %         % Reset counter to zero
    %         counterWrite = 0;
    %     end
    
end

%% Save metadata and encounter events

% If desired, save encounter events
if iniSettings.outputEvents
    save([saveDirectory filesep 'scriptedEncounters.mat'],'samples','-v7.3');
end

% Save metadata
save([saveDirectory filesep 'metaData.mat'],'enc_metadata','-v7.3');

% Save performance benchmarks
save([saveDirectory filesep 'benchmark.mat'],'numTrials','jobTime_s','-v7.3');

end % function