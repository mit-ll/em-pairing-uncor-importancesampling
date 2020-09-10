% Copyright 2018 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%%
function [traj1out, traj2out, uncorrelatedParametersOut, isFailed] = ...
    initializeUncorrelatedEncounter(traj1in, traj2in, uncorrelatedParametersIn, varargin)
%INITIALIZEUNCORRELATEDENCOUNTER computes the initial conditions for uncorrelated encounters.
%
% Inputs:
%  traj1in - sampled ownship trajectory
%  traj2in - sampled intruder trajectory
%  uncorrelatedParametersIn - parameters necessary to generate an
%  uncorrelated encounter
%
%   Optional Inputs:
%       'delhi_min' - Minimum altitude separation at beginning of encounter
%           (ft) (default = 850 ft)
%       'delRhi_min' - Minimum horizontal separation at beginning of
%           encounter (ft) (default = 1 NM)
%       'tca' - time of closest approach (s) (0 - default)
%       'proposed_bin_edges_HMD' and 'proposed_pdf_values_HMD' define the
%           distribution used to sample HMD
%       'vmd_weights' - the weight associated with the sampled VMD
%           (relative altitude at CPA)
% 
% Outputs:
%  traj1out - rotated ownship trajectory after initialization
%  traj2out - rotated intruder trajectory after initialization
%  uncorrelatedParametersOut - updated parameters
%  isFailed - false, if initialization was successful

%%
constants = load_constants;

%Set maxHMD
if isprop(uncorrelatedParametersIn,'maxHMD')
    maxHMD = uncorrelatedParametersIn.maxHMD; %Used for line sampling
else
    maxHMD = constants.nm2ft*3; %3 Nautical Miles
end

isFailed = false;
uncorrelatedParametersOut = uncorrelatedParametersIn;

%% Define and process inputs
p = inputParser;   % Create an instance of the inputParser class.
% Note that the defaults for altitude and horizontal separation are
% consistent with that for TCAS Traffic Advisory alerting below FL180 (the
% max altitude for the uncorrelated model).
p.addOptional('delta_h_init_min_ft',850,@isnumeric);      % Minimum altitude separation at beginning of encounter (ft)
p.addOptional('delta_range_init_min_ft',6076.115,@isnumeric);  % Minimum horizontal separation at beginning of encounter (ft)
p.addOptional('tca_s',0,@isnumeric); % Time of closest approach
p.addOptional('proposed_bin_edges_HMD_ft',linspace(-3000,3000,100),@isnumeric); % proposed distribution for importance sampling
p.addOptional('proposed_pdf_values_HMD',ones(99,1),@isnumeric); % proposed for importance sampling
p.addOptional('vmd_weights',0,@isnumeric);
p.parse(varargin{:});

%% Relative altitude = intruder height at TCA - ownship height at TCA
intAltAtTCA = uncorrelatedParametersIn.intHeightAtTCA;
relAlt = intAltAtTCA - uncorrelatedParametersIn.ownHeightAtTCA;

ac1.vh = max(0.1, traj1in.speed_ftps(1)*cos(traj1in.theta_rad(1)) ); % Horizontal initial airspeed [ft/s]
ac1.dh = traj1in.speed_ftps(1)*sin(traj1in.theta_rad(1)); % Vertical initial airspeed [ft/s]

ac2.vh = max(0.1, traj2in.speed_ftps(1)*cos(traj2in.theta_rad(1)) ); % Horizontal initial airspeed [ft/s]
ac2.dh = traj2in.speed_ftps(1)*sin(traj2in.theta_rad(1)); % Vertical initial airspeed [ft/s]

tca_s = p.Results.tca_s; %TCA

%% Initialize encounter
[traj1out, traj2out] = init_enc(traj1in, traj2in); 

%% Helper functions
function [traj1out, traj2out] = init_enc(traj1in, traj2in)
    
    %Initialize traj1out, traj2out
    traj1out = traj1in;
    traj2out = traj2in;
    
    v1 = ac1.vh;
    v2 = ac2.vh;

    dh1 = ac1.dh;
    dh2 = ac2.dh;

    %Sample AC2 heading
    randval = rand(2,1); %Draw 2 random values
    psi1p = 0; % Initial heading AC1 (at TCA)   
    psi2p = (randval(1)-0.5)*2*pi; % Initial heading AC2 
    psi2pKeep = false;
    while ~psi2pKeep
        psi2p = (randval(1)-0.5)*2*pi; % Initial heading AC2 
        Ppsi = ((cos(psi2p)*v2-v1).^2+sin(psi2p).^2*v2.^2+(dh2-dh1)^2).^(1/2); % Unnormalized Pr(heading)
        Ppsimax = ((-v2-v1).^2+(dh2-dh1)^2).^(1/2); % Unnormalized Pr(max heading) when head-on
        psi2pKeep = randval(2)<=Ppsi/Ppsimax; % Decide if should keep psi2p
        if ~psi2pKeep % Reject previous sample and try again                    
            randval(1) = rand;
            randval(2) = rand;
        end
    end        

    %Check that the trajectories are long enough
    if (max(traj1in.time)<tca_s) || (max(traj2in.time)<tca_s)
        isFailed = true;
        return;
    end

    indtime = find(traj1in.time==tca_s); % Get index at desired TCA
    traj1in.vertical_speed = traj1in.speed_ftps.*sin(traj1in.theta_rad); % Compute vertical rate
    traj2in.vertical_speed = traj2in.speed_ftps.*sin(traj2in.theta_rad);      

    % Get parameters at TCA
    dh1 = traj1in.vertical_speed(indtime);
    dh2 = traj2in.vertical_speed(indtime);

    v1 = sqrt(max(traj1in.speed_ftps(indtime)^2-dh1^2,0.1)); % Horizontal portion of airspeed
    v2 = sqrt(max(traj2in.speed_ftps(indtime)^2-dh2^2,0.1));

    %Sample HMD
    [ Npt, Ept, w, hmd ] = sampinitloc(maxHMD, v1, v2, dh1, dh2, psi2p, ...
    p.Results.proposed_bin_edges_HMD_ft, p.Results.proposed_pdf_values_HMD, ...
    p.Results.vmd_weights);                

       %% Rotate to satisfy positions and headings at TCA

        % Get positions such that we rotate around CPA
        % (both positions at CPA are set to zero)
        posAC1 = [traj1in.north_ft - traj1in.north_ft(indtime), traj1in.east_ft - traj1in.east_ft(indtime)];
        posAC2 = [traj2in.north_ft - traj2in.north_ft(indtime), traj2in.east_ft - traj2in.east_ft(indtime)];

        % Rotate AC1 such that psi1 = 0 at TCA
        ownship_heading = traj1in.psi_rad(indtime); 
        rotpsiAC1 = psi1p - ownship_heading;
        rotAC1 = [cos(rotpsiAC1),-sin(rotpsiAC1);sin(rotpsiAC1),cos(rotpsiAC1)]; % Rotation matrix

        intruder_heading = traj2in.psi_rad(indtime);
        rotpsiAC2 = psi2p - intruder_heading;
        rotAC2 = [cos(rotpsiAC2),-sin(rotpsiAC2);sin(rotpsiAC2),cos(rotpsiAC2)]; % Rotation matrix

        % Rotated positions
        posAC1_n = (rotAC1*posAC1')';
        posAC2_n = (rotAC2*posAC2')';
        posAC2_n = [posAC2_n(:,1)+Npt, posAC2_n(:,2)+Ept]; % Translate AC2 to CPA (AC1 remains at origin)

        % Get the new initial positions
        n1 = posAC1_n(1,1);
        e1 = posAC1_n(1,2);

        % Set initial position for ownship to (0,0), and shift intruder to be
        % relative to ownship
        posAC1_n(:,1) = posAC1_n(:,1) - n1;
        posAC1_n(:,2) = posAC1_n(:,2) - e1;
        posAC2_n(:,1) = posAC2_n(:,1) - n1;
        posAC2_n(:,2) = posAC2_n(:,2) - e1;

        % Adjust so starting time = 0
        traj1out.time = traj1in.time - traj1in.time(1);
        traj2out.time = traj2in.time - traj2in.time(1);

        % Adjust so first ownship point is (0,0)
        traj1out.north_ft = posAC1_n(:,1);
        traj1out.east_ft = posAC1_n(:,2);
        traj2out.north_ft = posAC2_n(:,1);
        traj2out.east_ft = posAC2_n(:,2);
        
        % Get the new initial positions
        n1 = traj1out.north_ft(1);
        e1 = traj1out.east_ft(1);

        h1 = traj1out.up_ft(1);
        h2 = traj2out.up_ft(1);

        n2 = traj2out.north_ft(1);
        e2 = traj2out.east_ft(1);

        %Update Heading in the Two Trajectories
        ediff1 = diff(traj1out.east_ft);
        ndiff1 = diff(traj1out.north_ft);
        ediff1 = [ediff1(1); ediff1];
        ndiff1 = [ndiff1(1); ndiff1];
        
        ediff2 = diff(traj2out.east_ft);
        ndiff2 = diff(traj2out.north_ft);
        ediff2 = [ediff2(1); ediff2];
        ndiff2 = [ndiff2(1); ndiff2];
        
        % Heading:  adjust atan2 results for clockwise from north
        traj1out.psi_rad = wrapTo2Pi(atan2(ediff1, ndiff1));
        traj2out.psi_rad = wrapTo2Pi(atan2(ediff2, ndiff2));
        
        %Set output parameters
        uncorrelatedParametersOut.w = w;
        uncorrelatedParametersOut.hmd = hmd;
        uncorrelatedParametersOut.vmd = relAlt;
        uncorrelatedParametersOut.tca = tca_s;
    
    %% Check that separation of AC1 and AC2 initially is large enough
    % If not, then reject the encounter
    delhi = h2-h1;                        % Initial vertical separtion
    delRhi = sqrt((e2-e1).^2+(n2-n1).^2); % Initial horizontal separation

    if (abs(delhi)<p.Results.delta_h_init_min_ft && delRhi<p.Results.delta_range_init_min_ft) || (abs(delhi)<p.Results.delta_h_init_min_ft && delRhi<p.Results.delta_range_init_min_ft) 
        isFailed = true;
        return;
    end 
end

% Sample HMD
function [ Npt, Ept, w, hmd ] = sampinitloc(maxHMD, s0, s1, dh0, dh1, heading, proposed_bin_edges_HMD_ft, proposed_pdf_values_HMD, vmd_weights)
    %heading is AC2 initial heading
   
    %Sample HMD on the desired distribution
    hmd = sampleHMD(proposed_bin_edges_HMD_ft, proposed_pdf_values_HMD);
      
    %Determine E and N at CPA
    psi1p = 0; psi2p = heading;
    V1 = s0*[cos(psi1p),sin(psi1p)]; % Horizontal velocity AC1 [N,E]
    V2 = s1*[cos(psi2p),sin(psi2p)]; % Horizontal velocity AC2 [N,E]
    VR = V2-V1; % Relative velocity of AC2 w.r.t. AC1 [N,E]

    % Get east and north position (hmd location when VR is
    % perpendicular to relative position vector)
    % There are technically two, but we will just choose one
    Ept = -1./(VR(:,1).^2+VR(:,2).^2).^(1/2).*hmd.*VR(:,1);
    Npt = 1./(VR(:,1).^2+VR(:,2).^2).^(1/2).*VR(:,2).*hmd;
    
    % Determine weighting scheme
    vrelnorm = (4*(2*s0.*s1+dh0.^2+dh1.^2-2*dh1.*dh0+s0.^2+s1.^2).^(1/2).*ellipticE(2*s0.^(1/2).*s1.^(1/2)./(2*s0.*s1+dh0.^2+dh1.^2-2*dh1.*dh0+s0.^2+s1.^2).^(1/2)));
    
    %HMD likelihood weighting
    actual_hmd_w = 1/(maxHMD - (-maxHMD));
    modeled_hmd_w = getHMDWeight(hmd,proposed_bin_edges_HMD_ft, proposed_pdf_values_HMD);
    hmd_w = actual_hmd_w/modeled_hmd_w;
    
    %VMD likelihood weights -- calculated when pairing
    vmd_w = vmd_weights;
    
    % Calculate weight
    w = vrelnorm * hmd_w * vmd_w;
    
end

%Get weight associated with sampled HMD
function hmd_w = getHMDWeight(hmd, bin_edges, pdf_values)
%Actual hmd distribution is a symmetric piecewise uniform distribution
    denominator = 0;
    for i = 1:length(pdf_values)
        denominator = denominator + (bin_edges(i+1)-bin_edges(i))*pdf_values(i);
    end

    x = 1/denominator;

    pdf_index = find(hmd<bin_edges,1)-1;
    if(isempty(pdf_index))
        pdf_index = length(pdf_values);
    end

    % Calculate weight
    hmd_w = pdf_values(pdf_index)*x;

end

function sampledHMD = sampleHMD(bin_edges, pdf_values)
    %sample HMD from the given distribution
    denominator = 0;
    for i = 1:length(pdf_values)
        denominator = denominator + (bin_edges(i+1)-bin_edges(i))*pdf_values(i);
    end

    x = 1/denominator;

    cdf_y_edges = cumsum(diff(bin_edges).*pdf_values*x);

    bin = find(rand(1)<cdf_y_edges,1);

    sampledHMD = rand(1)*(bin_edges(bin+1)-bin_edges(bin)) + bin_edges(bin);

end

end   % End main function (function nesting stops here)