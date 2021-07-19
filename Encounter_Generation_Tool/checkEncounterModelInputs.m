function checkEncounterModelInputs(ac)
% Copyright 2018 - 2021, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
% Verify that aircraft struct (ac) has valid encounter statistics and
% variables.
% SEE ALSO checkINIInputs em_read generateDAAEncounterSet

%% Check that model using the uncorrelated bayes net
% generateDAAEncounterSet assumes the uncorrelated bayes net and there are
% some variables / functions that are hardcoded in response
% Expected labels of initial network
labels_initial = {'"G"';'"A"';'"L"';'"v"';'"\dot v"';'"\dot h"';'"\dot \psi" '};

errMsg = sprintf('The input model initial network labels are not what is expected');
assert(all(strcmp(labels_initial, ac.labels_initial)),errMsg);

errMsg = sprintf('The expected uncorrelated encounter models have 7 variables in the initial network, the input model has %i', ac.n_initial);
assert(ac.n_initial == 7,errMsg);

%% Check values in the vector are numeric and non-negative
numericalVars = {'r_initial','r_transition'};
for i = 1:numel(numericalVars)
    errMsg = sprintf('Elements of %s must be >=0\n', numericalVars{i});
    assert(isnumeric(ac.(numericalVars{i})) && all(ac.(numericalVars{i})>=0), errMsg);
end

%% Check values in the cell array are numeric and non-negative
numericalCells = {'N_initial', 'N_transition'};
for i = 1:numel(numericalCells)
    errMsg = sprintf('Elements of %s must be >=0\n', numericalCells{i});
    for j = 1:numel(ac.(numericalCells{i}))
        assert(isnumeric(ac.(numericalCells{i}){j}) && all(all(ac.(numericalCells{i}){j}>=0)), errMsg);
    end
end

%% Check values are logical
logicalVars = {'G_initial', 'G_transition'};
for i = 1:numel(logicalVars)
    errMsg = sprintf('%s must be logical\n', logicalVars{i});
    assert(islogical(ac.(logicalVars{i})), errMsg);
end

%% zero_bins must be be less than than number of elements in boundaries
ac.zero_bins(cellfun('isempty',ac.zero_bins)) = {0}; %Assign 0 to the empty cells
assert(isnumeric([ac.zero_bins{:}]) ...
    && (all([ac.zero_bins{:}]<cellfun('length',ac.boundaries) | [ac.zero_bins{:}]==0)) ...
    && all([ac.zero_bins{:}]>=0), ...
    'Values in zero_bins must be less than the corresponding number of elements in boundaries');

%% Check dimensions of variables associated with the initial network match expectations
assert(ac.n_initial == numel(ac.labels_initial), 'n_initial should equal the number of labels_initial');
[rowG_init,colG_init] = size(ac.G_initial);
assert(rowG_init == ac.n_initial && colG_init == ac.n_initial, 'The dimensions of G_initial should be n_initial x n_initial');

initial_dimension_vars = {'r_initial','N_initial','boundaries'};
for i = 1:numel(initial_dimension_vars)
    errMsg = sprintf('The number of elements in %s should equal n_initial',initial_dimension_vars{i});
    assert(numel(ac.(initial_dimension_vars{i}))==ac.n_initial, errMsg);
end

%% Check dimensions of variables associated with the transition network match expectations
assert(ac.n_transition == numel(ac.labels_transition), 'n_transition should equal the number of labels_transition');
[rowG_trans,colG_trans] = size(ac.G_transition);
assert(rowG_trans == ac.n_transition && colG_trans == ac.n_transition, 'The dimensions of G_transition should be n_transition x n_transition');

transition_dimension_vars = {'r_transition','N_transition'};
for i = 1:numel(transition_dimension_vars)
    errMsg = sprintf('The number of elements in %s should equal n_transition',transition_dimension_vars{i});
    assert(numel(ac.(transition_dimension_vars{i}))==ac.n_transition, errMsg);
end

%% Check values in the temporal map are less than the number of elements in labels_initial/labels_transition
assert(isnumeric(ac.temporal_map) && all(ac.temporal_map(:,1)<=ac.n_initial),...
    'Values in the first column of temporal_map should be <= n_initial');
assert(isnumeric(ac.temporal_map) && all(ac.temporal_map(:,2)<=ac.n_transition),...
    'Values in the second column of temporal_map should be <= n_transition');

%% resample_rates should be between 0 and 1
assert(isnumeric(ac.resample_rates) && all(ac.resample_rates>=0) && all(ac.resample_rates)<=1,'resample_rates should be between 0 and 1');

%% boundaries should be monotonically increasing
for i = 1:numel(ac.boundaries)
    if ~isempty(ac.boundaries{i})
        assert(all(diff(ac.boundaries{i})>=0), 'boundaries should be monotonically increasing');
    end
end

end