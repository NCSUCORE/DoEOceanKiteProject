function altOptMPC_level2SFunc(block)
%MSFUNTMPL_BASIC A Template for a Level-2 MATLAB S-Function
%   The MATLAB S-function is written as a MATLAB function with the
%   same name as the S-function. Replace 'msfuntmpl_basic' with the 
%   name of your S-function.

%   Copyright 2003-2018 The MathWorks, Inc.

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
setup(block);

%endfunction

%% Function: setup ===================================================
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
%%   Required         : Yes
%%   C MEX counterpart: mdlInitializeSizes
%%
function setup(block)

% Register number of ports
block.NumInputPorts  = 3;
block.NumOutputPorts = 3;

% Setup port properties to be inherited or dynamic
% block.SetPreCompInpPortInfoToDynamic;
% block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
Amat = block.DialogPrm(1).Data;
nPred = block.DialogPrm(11).Data;
nS   = length(Amat);
IPsizes = [1 nS nS^2];
OPsizes = nPred*[1 1 1];

for ii = 1:numel(IPsizes)
block.InputPort(ii).Dimensions        = IPsizes(ii);
block.InputPort(ii).DatatypeID        = 0; 
block.InputPort(ii).Complexity        = 'Real';
block.InputPort(ii).DirectFeedthrough = true;
block.InputPort(ii).SamplingMode      = 'Sample';
end

% Override output port properties
for ii = 1:numel(OPsizes)
block.OutputPort(ii).Dimensions       = OPsizes(ii);
block.OutputPort(ii).DatatypeID       = 0;
block.OutputPort(ii).Complexity       = 'Real';
% block.InputPort(ii).DirectFeedthrough = true;
block.OutputPort(ii).SamplingMode     = 'Sample';
end

% Register parameters
block.NumDialogPrms     = 15;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [-1 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Terminate', @Terminate); % Required
% block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode);

%end setup



%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C MEX counterpart: mdlOutputs
%%
function Outputs(block)

% block parameters
Amat            = block.DialogPrm(1).Data;
Qmat            = block.DialogPrm(2).Data;
Hmat            = block.DialogPrm(3).Data;
Rmat            = block.DialogPrm(4).Data;
Ks              = block.DialogPrm(5).Data;
Ks12            = block.DialogPrm(6).Data;
covAmp          = block.DialogPrm(7).Data;
altScale        = block.DialogPrm(8).Data;
zDiscrete       = block.DialogPrm(9).Data;
powerLawParams  = block.DialogPrm(10).Data;
nPred           = block.DialogPrm(11).Data;
zMin            = block.DialogPrm(12).Data;
zMax            = block.DialogPrm(13).Data;
zStepMax        = block.DialogPrm(14).Data;
tradeOffCons    = block.DialogPrm(15).Data;

% block inputs
zCurrent     = block.InputPort(1).Data;
sKp1_Kp1     = block.InputPort(2).Data;
sigKp1_Kp1   = reshape(block.InputPort(3).Data,length(sKp1_Kp1),[]);

% use fmincon to solve for best trajectory subject to constraints
% set solver and display options
options = optimoptions('fmincon','algorithm','sqp','display','off');
% make A and B matrix such that the altitude setpoint remains between zMin
% and zMax and change in altitude setpoint <= zStepMax
duMax = zStepMax;
Astep = zeros(nPred-1,nPred);
bstep = duMax*ones(2*(nPred-1),1);
for ii = 1:nPred-1
    for jj = 1:nPred
        if ii == jj
            Astep(ii,jj) = -1;
            Astep(ii,jj+1) = 1;
        end
        
    end
end
Astep = [Astep;-Astep];
% bounds on first step
fsBoundsA = zeros(2,nPred);
fsBoundsA(1,1) = 1;
fsBoundsA(2,1) = -1;
A = [fsBoundsA;Astep];
% upper and lower bounds
lb = zMin*ones(1,nPred);
ub = zMax*ones(1,nPred);
% make the b matrix
fsBoundsB(1,1) = min(zCurrent + duMax,zMax);
fsBoundsB(2,1) = min(-(zCurrent - duMax),-zMin);
b = [fsBoundsB;bstep];

% optimize
optTraj = fmincon(@(u) altOptCostFn(sKp1_Kp1,sigKp1_Kp1,u,...
   zDiscrete,Amat,Qmat,Hmat,Rmat,Ks,Ks12,covAmp,altScale,tradeOffCons,...
   powerLawParams),zCurrent*ones(nPred,1),A,b,[],[],lb,ub,[],options);

% get other values
[~,jExploit,jExplore] = ...
    altOptCostFn(sKp1_Kp1,sigKp1_Kp1,optTraj,...
   zDiscrete,Amat,Qmat,Hmat,Rmat,Ks,Ks12,covAmp,altScale,tradeOffCons,...
   powerLawParams);

% begin outputs 
block.OutputPort(1).Data = real(optTraj);
block.OutputPort(2).Data = real(jExploit);
block.OutputPort(3).Data = real(jExplore);

%end Outputs

%%
%% Terminate:predMean
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate

