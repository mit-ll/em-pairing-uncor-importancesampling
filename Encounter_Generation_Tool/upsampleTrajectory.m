% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function traj = upsampleTrajectory(traj)
%This function converts a trajectory from 1hz to 10hz
fields = fieldnames(traj);
numData = numel(traj.time);

%Update all of the fields in traj
for i = 1:numel(fields)
    data = traj.(fields{i});
    upsampledData = zeros((numData-1)*10+1,1);
    counter = 1;
    for j = 1:numel(data)-1
        upsampledDataTemp = linspace(data(j),data(j+1),11);
        upsampledData((j-1)*10+1:j*10) = upsampledDataTemp(1:10);
        counter = counter+10;
    end
    upsampledData(end) = data(end);
    
    traj.(fields{i}) = upsampledData;
end
end
