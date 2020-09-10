% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
classdef UncorEncounterParameters
    %UNCORENCOUNTERPARAMETERS parameters used to initialize an uncorrelated
    %encounter
    
    properties
        id %encounter id
        
        w @double %encounter weighting computed during initialziaton
        tca @double %time of closest approach
        simtime @double %simulation time
        isFailed @logical %whether the encounter failed to initialize with the desired parameters
        ownHeightAtTCA @ double %actual ownship height at TCA after initialization
        intHeightAtTCA @ double %actual intruder height at TCA after initialization
        maxHMD @double %hmd is sampled on [0, maxHMD]
        hmd @ double %hmd sampled during initialization
        vmd @ double %vmd sampled during initialization
    end
    
    methods
        function this = UncorEncounterParameters(tca, simtime, isFailed, ownHeightAtTCA, intHeightAtTCA, maxHMD)
            if (nargin>0)
                this.tca = tca;
                this.simtime = simtime;
                this.isFailed = isFailed;
                this.ownHeightAtTCA = ownHeightAtTCA;
                this.intHeightAtTCA = intHeightAtTCA;
                this.maxHMD = maxHMD;
            end
        end
    end
end

