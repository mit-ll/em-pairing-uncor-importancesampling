% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
function checkINIInputs(iniFile)
% Verify that the values in the .ini file are valid.

    %Read in the parameters from the .ini file
    iniSettings = ini2struct (iniFile);
    
    %% Check booleans
    bools = {'applyOwnshipFilterWholeEncounter', 'applyIntruderFilterWholeEncounter', ...
        'applyOwnshipFilterAtCPA', 'applyIntruderFilterAtCPA', 'applyOwnshipFilterSampling', 'applyIntruderFilterSampling', ...
        'quantizeOwnshipAlt500', 'quantizeIntruderAlt500', 'sampleByDurationOwnship', 'sampleByDurationIntruder', ...
        'ownshipSampleTrajectory', 'intruderSampleTrajectory', 'outputEvents', 'outputTrajectories'};
 
    for i = 1:numel(bools)
        errMsg = sprintf('%s must be 0 or 1\n', bools{i});
        assert(iniSettings.(bools{i}) == 1 || iniSettings.(bools{i}) == 0, errMsg);
    end

    %% Check filepaths - warning if there are back slashes (Windows specific)
    paths = {'ownshipEmFile','intruderEmFile', 'ownEncVariablesFile', 'ownEncStatisticsFile', 'intEncVariablesFile', 'intEncStatisticsFile', ...
        'saveDirectory', 'ownship_trajectory_dir', 'ownship_trajectory_datafile', 'intruder_trajectory_dir', 'intruder_trajectory_datafile'}; 
    
    for i = 1:numel(paths)
        warnMsg = sprintf('%s contains /''s which are not compatible with Linux. \n', paths{i});
        if ~isempty(strfind(paths{i},'/'))
            warning(warnMsg);
        end     
    end
    
    %% Check bin_edges are monotonically increasing
    assert(all(diff(iniSettings.bin_edges_VMD)>=0), 'bin_edges_VMD must increase monotonically');
    assert(all(diff(iniSettings.bin_edges_HMD)>=0), 'bin_edges_HMD must increase monotonically');
    
    %% Check proportions are non-negative
    assert(all(iniSettings.desired_proportions_VMD>=0), 'desired_proportions_VMD must be >=0');
    assert(all(iniSettings.desired_proportions_HMD>=0), 'desired_proportions_HMD must be >=0');
    
    %% Check tCPA and sample_time are non-negative and sample_time is > tCPA
    assert(iniSettings.tCPA>=0, 'tCPA must be >=0');
    assert(iniSettings.sample_time>=0, 'sample_time must be >=0');
    assert(iniSettings.tCPA<=iniSettings.sample_time, 'tCPA must occur at or before sample_time');
    
    %% Check encIds are numeric and all unique
    assert(numel(unique(iniSettings.encIds)) == numel(iniSettings.encIds), 'All encIds must be unique');
    assert(isnumeric(iniSettings.encIds) & all(iniSettings.encIds == ceil(iniSettings.encIds)), 'All encIds must be integer');
   
    %% Check miscellaneous numerical parameters are numerical and non-negative
    numericalVars = {'H_min','R_min','randSeed','maxOwnAlt_ft', 'minOwnAlt_ft', 'maxIntAlt_ft', 'minIntAlt_ft', ...
        'maxOwnSpeed_kts', 'minOwnSpeed_kts', 'maxIntSpeed_kts', 'minIntSpeed_kts'};
    
    for i = 1:numel(numericalVars)
        errMsg = sprintf('%s must be a non-negative number\n', numericalVars{i});
        assert(isnumeric(iniSettings.(numericalVars{i})) && all(iniSettings.(numericalVars{i}) >= 0), errMsg);
    end
    
    %% Check min Speed/Altitude is less than max Speed/Altitude
    % Could be cases where max altitude is less than min altitude if the
    % user mixes AGL and MSL for the limits
    if iniSettings.applyOwnshipFilterWholeEncounter || iniSettings.applyOwnshipFilterAtCPA || iniSettings.applyOwnshipFilterSampling
        if iniSettings.maxOwnAlt_ft<iniSettings.minOwnAlt_ft
            warning('maxOwnAlt_ft is less than minOwnAlt_ft');
        end
        if isempty(iniSettings.maxOwnSpeed_kts) || isempty(iniSettings.minOwnSpeed_kts) 
            warning('Ownship filtering is selected, but ownship max or min speed is empty');
        else
            assert(iniSettings.maxOwnSpeed_kts>=iniSettings.minOwnSpeed_kts, 'maxOwnSpeed_kts must be >= minOwnSpeed_kts');
        end
    end
        
    if iniSettings.applyIntruderFilterWholeEncounter || iniSettings.applyIntruderFilterAtCPA || iniSettings.applyIntruderFilterSampling
        if iniSettings.maxIntAlt_ft<iniSettings.minIntAlt_ft
            warning('maxIntAlt_ft is less than minIntAlt_ft');
        end
        if isempty(iniSettings.maxIntSpeed_kts) || isempty(iniSettings.minIntSpeed_kts) 
            warning('Intruder filtering is selected, but intruder max or min speed is empty');
        else
            assert(iniSettings.maxIntSpeed_kts>=iniSettings.minIntSpeed_kts, 'maxIntSpeed_kts must be >= minIntSpeed_kts');
        end
    end
    
    %% Check altTypes are 'MSL or 'AGL' if corresponding limits are not empty
    altTypes = {'maxOwnAltType', 'minOwnAltType', 'maxIntAltType', 'minIntAltType'};
    altLimits = {'maxOwnAlt_ft', 'minOwnAlt_ft', 'maxIntAlt_ft', 'minIntAlt_ft'};
    
    for i = 1:numel(altTypes)
        if ~isempty(iniSettings.(altLimits{i}))
            errMsg = sprintf('%s must be a ''AGL'' or ''MSL''\n', altTypes{i});
            assert(strcmpi(iniSettings.(altTypes{i}),'AGL') || strcmpi(iniSettings.(altTypes{i}),'MSL'), errMsg);
        end
    end
    %% Check altLayers are numerical, nx2 and that the lower bound of each bin is < upper bound of each bin
    assert(isnumeric(iniSettings.altLayers), 'altLayers must be numeric');
    assert(mod(numel(iniSettings.altLayers),2)==0,'altLayers must have an even number of elements');
    
    dim1 = length(iniSettings.altLayers) / 2;
    layers = reshape (iniSettings.altLayers, 2, dim1)';

    assert(all(layers(:,1)<=layers(:,2)), 'The lower bound of each bin must be less than the upper bound of each bin');

