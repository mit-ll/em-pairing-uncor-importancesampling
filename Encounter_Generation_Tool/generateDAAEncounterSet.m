% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function generateDAAEncounterSet(parameterFile)
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

%% Verify INI inputs
    checkINIInputs(parameterFile);

%% Set up variables
    iniSettings = ini2struct (parameterFile);
    constants = load_constants;
    sample_time = iniSettings.sample_time;
    
    encIds = iniSettings.encIds;
    N = length(encIds);
    
    saveDirectory = [getenv('AEM_DIR_DAAENC') filesep iniSettings.saveDirectory];
    
    % alt layers
    dim1 = length(iniSettings.altLayers) / 2;
    layers = reshape (iniSettings.altLayers, 2, dim1)';

    round500 = @(num) 500*(floor(num/500) + (mod(num,500) > 250));
    
    trajectoryOut1 = cell(1,N);
    trajectoryOut2 = cell(1,N);
    paramsOut = cell(1,N);
    
%% Set up encounter models
    %Set up ownship encounter model
    if iniSettings.ownshipSampleTrajectory
        %Read in trajectory metadata
        metadata = readtable(iniSettings.ownship_trajectory_datafile); 
    else
        % load encounter model with sufficient statistics for ownship
        encFile1 = [getenv('AEM_DIR_BAYES') filesep 'model' filesep iniSettings.ownshipEmFile];
        ac1 = em_read(encFile1,'isOverwriteZeroBoundaries',true,'idxZeroBoundaries',[1 2 3]); % em_read from em-model-manned-bayes

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
        
        %Set up dirichlets - do not use priors
        dirichlet_initial1 = bn_dirichlet_prior(ac1.N_initial, 0);
        dirichlet_transition1 = bn_dirichlet_prior(ac1.N_transition, 0);
    end
    
    
    %Set up intruder encounter model
    if iniSettings.intruderSampleTrajectory
        %Read in trajectory metadata
        metadata = readtable(iniSettings.intruder_trajectory_datafile); 
    else
        % load encounter model with sufficient statistics for intruder
        encFile2 = [getenv('AEM_DIR_BAYES') filesep 'model' filesep iniSettings.intruderEmFile];
        ac2 = em_read(encFile2,'isOverwriteZeroBoundaries',true,'idxZeroBoundaries',[1 2 3]); % em_read from em-model-manned-bayes

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
        
        %Set up dirichlets - do not use priors
        dirichlet_initial2 = bn_dirichlet_prior(ac2.N_initial, 0);
        dirichlet_transition2 = bn_dirichlet_prior(ac2.N_transition, 0);
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

 %% Generate Encounter
    isFailed = false;

    for j = 1:N %Loop through number of encounters

        % Set random number seed if one is specified
        if isfield (iniSettings, 'randSeed')
            randSeed = iniSettings.randSeed + encIds(j);
            rng(randSeed);
        end

        encounterOk = false;
        counter = 0;

        while ~encounterOk 
            counter = counter + 1;  
            tCPA = iniSettings.tCPA; %Desired time of CPA

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
                % Sample from encounter model
                done = false;
                while ~done

                    if isempty(iniSettings.ownEncStatisticsFile) && isempty(iniSettings.ownEncStatisticsFile)
                        %Using the default uncorrelated encounter model
                        initial = {1,4,[],[],[],[],[]}; %Fix geographic region as CONUS (=1), airspace class as other (=4). Optional setting.
                    else
                        initial = {[],[],[],[],[],[],[]};
                    end
                    
                    [init1, events] = dbn_hierarchical_sample(ac1.G_initial, ac1.G_transition, ac1.temporal_map, ...
                                                              ac1.r_transition, ac1.N_initial, ac1.N_transition, dirichlet_initial1, dirichlet_transition1, ...
                                                              sample_time, ac1.boundaries, ac1.zero_bins, ac1.resample_rates, initial); 

                    % uniform draw for AC1 initial altitude within laye
                    h1 = layers(init1(3),1) + rand*(diff(layers(init1(3),:)));
                    if init1(6) == 0 && iniSettings.quantizeOwnshipAlt500 % round to nearest 500-ft increment if level
                      h1 = round500(h1);
                    end	  

                    % make sure vertical rate not greater than airspeed
                    if init1(4)*1.68781 > abs(init1(6))/60
                        done = true;
                    end 
                end

                % construct controls array for ownship (ac1)
                controls1 = BuildControlsArray(init1,events,5:7);
                init1 = ConvertUnits(init1);
                
                sample1.runTime_s = sample_time;
                sample1.altLayer = init1(3);
                sample1.id = encIds(j);
                sample1.numberOfAircraft = 2;
                sample1.v_ftps = init1(4);
                sample1.n_ft = 0;
                sample1.e_ft = 0;
                sample1.h_ft = h1;
                sample1.heading_rad = 0;
                sample1.pitch_rad = asin(init1(6)/sample1.v_ftps);
                sample1.bank_rad = atan(sample1.v_ftps*init1(7)/constants.g);
                sample1.a_ftpss = init1(5);
                sample1.updates = EncounterModelEvents( 'event', controls1 );

                % Simulate dynamics
                ic1 = [0,sample1.v_ftps,sample1.n_ft,sample1.e_ft,sample1.h_ft,sample1.heading_rad,sample1.pitch_rad,sample1.bank_rad,sample1.a_ftpss];

                % Events (dynamic controls)
                event1 = sample1.updates.event;
                
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
                % Sample from encounter model
                done = false;
                while ~done
                    
                    if isempty(iniSettings.intEncStatisticsFile) && isempty(iniSettings.intEncStatisticsFile)
                        %Using the default uncorrelated encounter model
                        initial = {1,4,[],[],[],[],[]}; %Fix geographic region as CONUS (=1), airspace class as other (=4). Optional setting.
                    else
                        initial = {[],[],[],[],[],[],[]};
                    end
                    
                    [init2, events] = dbn_hierarchical_sample(ac2.G_initial, ac2.G_transition, ac2.temporal_map, ...
                                                              ac2.r_transition, ac2.N_initial, ac2.N_transition, dirichlet_initial2, dirichlet_transition2, ...
                                                              sample_time, ac2.boundaries, ac2.zero_bins, ac2.resample_rates, initial);

                    % uniform draw for AC2 initial altitude within layer
                    h2 = layers(init2(3),1) + rand*(diff(layers(init2(3),:)));
                    if init2(6) == 0 && iniSettings.quantizeIntruderAlt500 % round to nearest 500-ft increment if level
                      h2 = round500(h2);
                    end	  

                    % make sure vertical rate not greater than airspeed
                    if init2(4)*1.68781 > abs(init2(6))/60
                        done = true;
                    end
                end

                % construct controls array for intruder (ac2)
                controls2 = BuildControlsArray(init2,events,5:7);
                init2 = ConvertUnits(init2);
                
                sample2.runTime_s = sample_time;
                sample2.altLayer = init2(3);
                sample2.id = encIds(j);
                sample2.numberOfAircraft = 2;
                sample2.v_ftps = init2(4);
                sample2.n_ft = 0;
                sample2.e_ft = 0;
                sample2.h_ft = h2;
                sample2.heading_rad = 0;
                sample2.pitch_rad = asin(init2(6)/sample2.v_ftps);
                sample2.bank_rad = atan(sample2.v_ftps*init2(7)/constants.g);
                sample2.a_ftpss = init2(5);
                sample2.updates = EncounterModelEvents( 'event', controls2 );

                % Simulate dynamics
                ic2 = [0,sample2.v_ftps,sample2.n_ft,sample2.e_ft,sample2.h_ft,sample2.heading_rad,sample2.pitch_rad,sample2.bank_rad,sample2.a_ftpss];

                % Events (dynamic controls)
                event2 = sample2.updates.event;
                
                trajectory2 = [];
            end
            
            %% check negative velocities and altitudes
            if ~iniSettings.ownshipSampleTrajectory || ~iniSettings.intruderSampleTrajectory
                if isempty(sample2)
                   results = run_dynamics_fast(ic1,event1,ic1,event1,sample_time); 
                elseif isempty(sample1)
                   results = run_dynamics_fast(ic2,event2,ic2,event2,sample_time); 
                elseif ~isempty(sample1) && ~isempty(sample2)
                   results = run_dynamics_fast(ic1,event1,ic2,event2,sample_time); 
                end
                
                if any(results(1).speed_ftps<0  | results(2).speed_ftps<0 | results(1).up_ft<0 | results(2).up_ft<0)
                    disp('Failed due to negative velocities');
                    continue; % Reject encounter model samples with negative velocities
                end
            end

            % Start encounter generation
            fprintf('\n***********\nGenerating encounter %u, Trial %u \n**********\n', encIds(j), counter);
            
            %% Try to achieve desired VMD distribution
            indtime = tCPA*10+1; % results are in 10hz, so update indtime accordingly
            randNum = rand(1); 
            if iniSettings.ownshipSampleTrajectory
                height = trajectory1.up_ft(indtime); % ownship height at TCA from trajectory
            else
                height = results(1).up_ft(indtime); % ownship height at TCA from encounter model
            end
            if iniSettings.intruderSampleTrajectory
                intheight = trajectory2.up_ft(indtime); % intruder height at TCA from trajectory
            else
                intheight = results(2).up_ft(indtime); % intruder height at TCA from encounter model
            end
            relHeight = intheight - height;
            binIndex = find(relHeight<bin_edges_VMD,1)-1;

            if isnan(height) || isnan(intheight) % Make sure there are no NaNs
                encounterOk = false; 
                disp('NaN height');
                continue;
            elseif (randNum>bin_probs(binIndex)) % Perform rejection sampling to achieve desired VMD distribution
                encounterOk = false;
                disp('VMD bin rejection sampling');
                continue;
            else
                vmd_weights = 1/bin_probs(binIndex);
            end

            fprintf('\n\n Getting height at TCA for encounter %u\n\n',encIds(j))
            encounterOk = true;

            if encounterOk
                %% initialize encounter
                uncorrelatedParametersIn = UncorEncounterParameters(tCPA, sample_time, isFailed, height, intheight, maxHMD);
                uncorrelatedParametersIn.id = encIds(j);
                
                %Transform events into waypoint trajectories
                if ~iniSettings.ownshipSampleTrajectory && iniSettings.intruderSampleTrajectory
                    results = run_dynamics_fast(ic1,event1,ic1,event1,iniSettings.sample_time);
                    trajectory1 = results(1);
                elseif iniSettings.ownshipSampleTrajectory && ~iniSettings.intruderSampleTrajectory
                    results = run_dynamics_fast(ic2,event2,ic2,event2,iniSettings.sample_time);
                    trajectory2 = results(2);
                elseif ~iniSettings.ownshipSampleTrajectory && ~iniSettings.intruderSampleTrajectory
                    results = run_dynamics_fast(ic1,event1,ic2,event2,iniSettings.sample_time);
                    trajectory1 = results(1);
                    trajectory2 = results(2);
                end
                
                %Initialize the encounter geometry
                [trajectoryOut1{j}, trajectoryOut2{j}, paramsOut{j}, isFailed] = initializeUncorrelatedEncounter(trajectory1, trajectory2, uncorrelatedParametersIn, ...
                'tca_s',uncorrelatedParametersIn.tca, 'delta_h_init_min_ft', H_min, 'delta_h_init_min_ft', R_min, 'vmd_weights', vmd_weights,...
                'proposed_bin_edges_HMD_ft',bin_edges_HMD, 'proposed_pdf_values_HMD',pdf_values_HMD);
                
                hmd = paramsOut{j}.hmd;
                vmd = paramsOut{j}.intHeightAtTCA - paramsOut{j}.ownHeightAtTCA;

                % Run encounter properties calculator, and collect property data:
                %   vmd, hmd, tca, runtime, intr_alt_ft (array), intr_gs_ftps (array)
                [enc_metadata(j),enc_properties(j)] = computeEncProperties(trajectoryOut1{j}, trajectoryOut2{j}, paramsOut{j}); %#okgrow

                if ~isFailed

                    fprintf('vmd_ft = %f, vmd = %f\n', enc_metadata(j).vmd, abs(vmd));
                    fprintf('hmd_ft = %f, hmd = %f\n', enc_metadata(j).hmd, abs(hmd));

                    if abs(enc_metadata(j).vmd - abs(vmd)) < 20 && abs(enc_metadata(j).hmd - abs(hmd)) < 500 % Ensure generated encounter has the desired hmd/vmd
                        encounterOk = true;
                    else
                        encounterOk = false;
                        disp('Failed because of hmd/vmd mismatch');
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
                        tca = round(enc_metadata(j).tca);
                        if enc_properties(j).int_alt_ft(tca) > maxIntAlt_ft || ...
                                enc_properties(j).int_alt_ft(tca) < minIntAlt_ft || ...
                                enc_properties(j).int_gs_kt(tca) > iniSettings.maxIntSpeed_kts || ...
                                enc_properties(j).int_gs_kt(tca) < iniSettings.minIntSpeed_kts
                            encounterOk = false;
                            disp('Failed because of intruder altitude/airspeed constraints at CPA');
                        end
                    end
                    
                    %Perform inturder filtering over the entire encounter
                    if iniSettings.applyIntruderFilterWholeEncounter
                        if any(enc_properties(j).int_alt_ft > maxIntAlt_ft) || ...
                                any(enc_properties(j).int_alt_ft < minIntAlt_ft) || ...
                                any(enc_properties(j).int_gs_kt > iniSettings.maxIntSpeed_kts) || ...
                                any(enc_properties(j).int_gs_kt < iniSettings.minIntSpeed_kts)
                            encounterOk = false;
                            disp('Failed because of intruder altitude/airspeed constraints over entire encounter');
                        end
                    end
                    
                    %Perform ownship filtering at CPA
                    if iniSettings.applyOwnshipFilterAtCPA
                        tca = round(enc_metadata(j).tca);
                        if enc_properties(j).own_alt_ft(tca) > maxOwnAlt_ft || ... 
                                enc_properties(j).own_alt_ft(tca) < minOwnAlt_ft || ...
                                enc_properties(j).own_gs_kt(tca) > iniSettings.maxOwnSpeed_kts || ... 
                                enc_properties(j).own_gs_kt(tca) < iniSettings.minOwnSpeed_kts
                            encounterOk = false;
                            disp('Failed because of ownship altitude/airspeed constraints at CPA');
                        end
                    end

                    %Perform ownship filtering over the entire encounter
                    if iniSettings.applyOwnshipFilterWholeEncounter
                        if any(enc_properties(j).own_alt_ft > maxOwnAlt_ft) || ...
                                any(enc_properties(j).own_alt_ft < minOwnAlt_ft) || ...
                                any(enc_properties(j).own_gs_kt > iniSettings.maxOwnSpeed_kts) || ... 
                                any(enc_properties(j).own_gs_kt < iniSettings.minOwnSpeed_kts)
                            encounterOk = false;
                            disp('Failed because of ownship altitude/airspeed constraints over the entire encounter');
                        end
                    end
                    
                    if enc_metadata(j).tca < iniSettings.tCPA || paramsOut{j}.tca < iniSettings.tCPA
                        encounterOk = false;
                        disp('Failed because tca occurs too early');
                    end
                    
                else
                    encounterOk = false;
                    disp('Failed because of initialization function');
                end
                
                rng(randSeed + 1e6*counter + encIds(j)); %Reset random seed
                
            end
        end
        
        %Save trajectories in output files
        if iniSettings.outputTrajectories
            %Output results to trajectory file
            writeTrajectoryToFile(trajectoryOut1{j}, trajectoryOut2{j}, encIds(j), saveDirectory);
            
        end
        
        %If desired, convert trajectories to events
        if iniSettings.outputEvents
            samples(j) = wpt2script(trajectoryOut1{j}, trajectoryOut2{j}, encIds(j), layers); %#okgrow
            
            %If encounters were generated from encounter model events,
            %output the original events. 
            if iniSettings.ownshipSampleTrajectory == 0
                 samples(j).updates(1).event = event1; %#okgrow
            end
            if iniSettings.intruderSampleTrajectory == 0
                 samples(j).updates(2).event = event2; %#okgrow
            end
        end
    end
    
    %% Save metadata and encounter events
    if ~exist(saveDirectory,'dir')
        mkdir(saveDirectory);
    end
    
    %If desired, save encounter events
    if iniSettings.outputEvents
        save([saveDirectory filesep 'scriptedEncounters.mat'],'samples');
    end
    
    %Save metadata
    save([saveDirectory filesep 'metaData.mat'],'enc_metadata');
    
end % function

%% Build controls array (for encounter events)
function controls = BuildControlsArray(initial,events,vars)
    constants = load_constants;

    t = 0;
    controls = [];
    x = initial;
    for event = events'
        delta_t = event(1);
        if delta_t > 0
            controls = [controls; t x(vars)]; %#okgrow   % t dh psi dv (vars will reorder the variables)
            t = t + delta_t;
        end
        if event(2) > 0 
            x(event(2)) = event(3);
        end
    end

    % reorder to [t dh dpsi dv] as DEGAS expects
    controls = controls(:,[1 3 4 2]);

    % convert units to DEGAS units
    controls(:,2) = controls(:,2) / constants.min2sec;    % fpm to fps
    controls(:,3) = deg2rad(controls(:,3));               % deg/s to rad/s
    controls(:,4) = controls(:,4) * constants.kt2ftps;    % kts/s to ft/s2;

end


%% Unit conversion
function xOut = ConvertUnits(xIn)
    constants = load_constants;

    xOut(1:3) = xIn(1:3);
    xOut(4) = xIn(4) * constants.kt2ftps;   % v: KTAS -> ft/s (use mean altitude for layer)
    xOut(5) = xIn(5) * constants.kt2ftps;   % vdot: kt/s -> ft/s^2
    xOut(6) = xIn(6) / constants.min2sec;   % hdot: ft/min -> ft/s
    xOut(7) = deg2rad(xIn(7));              % psidot: deg/s -> rad/s

end
