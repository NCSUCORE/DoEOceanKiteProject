function calcKalmanEstimate_Lvl2sFunc(block)
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
block.NumInputPorts  = 4;
block.NumOutputPorts = 4;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
kfgp = block.DialogPrm(1).Data;
nP   = length(kfgp.initVals.s0);
nP2  = length(kfgp.xMeasure);
IPsizes = [nP nP^2 1 1];
OPsizes = [nP2 nP2 nP nP^2];

for ii = 1:4
block.InputPort(ii).Dimensions         = IPsizes(ii);
block.InputPort(ii).DatatypeID        = 0; 
block.InputPort(ii).Complexity        = 'Real';
block.InputPort(ii).DirectFeedthrough = true;
block.InputPort(ii).SamplingMode      = 'Sample';
end

% Override output port properties
for ii = 1:4
block.OutputPort(ii).Dimensions    = OPsizes(ii);
block.OutputPort(ii).DatatypeID   = 0;
block.OutputPort(ii).Complexity   = 'Real';
block.OutputPort(ii).SamplingMode = 'Sample';
end

% Register parameters
block.NumDialogPrms     = 1;

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
kfgp = block.DialogPrm(1).Data;

sk_k    = block.InputPort(1).Data;
ck_k    = reshape(block.InputPort(2).Data,length(sk_k),[]);
xSamp   = block.InputPort(3).Data;
flowVal = block.InputPort(4).Data;

ySamp =  kfgp.meanFunction(xSamp,kfgp.meanFnProps(1),kfgp.meanFnProps(2))...
    - flowVal;

[F_t,sigF_t,skp1_kp1,ckp1_kp1] = ...
    kfgp.calcKalmanStateEstimates(sk_k,ck_k,xSamp,ySamp);
% KFGP: calculate prediction mean and posterior variance
[muKFGP,sigKFGP] = kfgp.calcPredMeanAndPostVar(kfgp.xMeasure,F_t,sigF_t);

predMeansKFGP = kfgp.initVals.meanFnVec(:) - muKFGP(:);
postVarsKFGP  = sigKFGP(:);
    
block.OutputPort(1).Data = real(predMeansKFGP);
block.OutputPort(2).Data = real(postVarsKFGP);
block.OutputPort(3).Data = real(skp1_kp1(:));
block.OutputPort(4).Data = real(ckp1_kp1(:));

%end Outputs

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate

