classdef UncorEncounterParameters
    % Copyright 2018 - 2022, MIT Lincoln Laboratory
    % SPDX-License-Identifier: X11
    % UNCORENCOUNTERPARAMETERS parameters used to initialize an uncorrelated
    % encounter

    properties
        id(1, 1) double {mustBeInteger, mustBeNonnegative, mustBeFinite}  % encounter id

        w(:, :) double {mustBeReal} % encounter weighting computed during initialziaton
        tca(:, :) double {mustBeReal} % time of closest approach
        simtime(:, :) double {mustBeReal} % simulation time
        isFailed(:, :) logical {mustBeNumericOrLogical, mustBeNonnegative}  % whether the encounter failed to initialize with the desired parameters
        ownHeightAtTCA(:, :) double {mustBeReal} % actual ownship height at TCA after initialization
        intHeightAtTCA(:, :) double {mustBeReal} % actual intruder height at TCA after initialization
        maxHMD(:, :) double {mustBeReal} % hmd is sampled on [0, maxHMD]
        hmd(:, :) double {mustBeReal}  % hmd sampled during initialization
        vmd(:, :) double {mustBeReal} % vmd sampled during initialization
    end

    methods

        function this = UncorEncounterParameters(tca, simtime, isFailed, ownHeightAtTCA, intHeightAtTCA, maxHMD)
            if nargin > 0
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
