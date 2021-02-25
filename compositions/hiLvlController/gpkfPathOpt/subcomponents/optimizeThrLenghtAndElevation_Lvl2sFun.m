function optimizeThrLenghtAndElevation_Lvl2sFun(block)
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
block.NumInputPorts  = 8;
block.NumOutputPorts = 5;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
midLvlKfgp = block.DialogPrm(1).Data;
nP   = length(midLvlKfgp.initVals.s0);
IPsizes = [nP nP^2 ones(1,6)];
OPsizes = midLvlKfgp.predictionHorizon*ones(1,5);

for ii = 1:block.NumInputPorts
block.InputPort(ii).Dimensions        = IPsizes(ii);
block.InputPort(ii).DatatypeID        = 0; 
block.InputPort(ii).Complexity        = 'Real';
block.InputPort(ii).DirectFeedthrough = true;
block.InputPort(ii).SamplingMode      = 'Sample';
end

% Override output port properties
for ii = 1:block.NumOutputPorts
block.OutputPort(ii).Dimensions   = OPsizes(ii);
block.OutputPort(ii).DatatypeID   = 0;
block.OutputPort(ii).Complexity   = 'Real';
block.OutputPort(ii).SamplingMode = 'Sample';
end

% Register parameters
block.NumDialogPrms     = 2;

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
% parameters
midLvlKfgp = block.DialogPrm(1).Data;
hiLvlCtrl = block.DialogPrm(2).Data;
% inputs
sk_k     = block.InputPort(1).Data;
ck_k     = reshape(block.InputPort(2).Data,length(sk_k),[]);
zCurrent = block.InputPort(3).Data;
flowVal  = block.InputPort(4).Data;
LthrSP   = block.InputPort(5).Data;
elevSP   = block.InputPort(6).Data;
Lthr     = block.InputPort(7).Data;
elev     = block.InputPort(8).Data;

% y value passed to kfgp
ySamp =  midLvlKfgp.meanFunction(zCurrent,midLvlKfgp.meanFnProps(1),...
    midLvlKfgp.meanFnProps(2)) - flowVal;

% fmincon options
options = optimoptions('fmincon','algorithm','sqp','display','off');

% mid-lvel kalman estimate
[F_t_mpc,sigF_t_mpc,skp1_kp1_mpc,ckp1_kp1_mpc] = ...
    midLvlKfgp.calcKalmanStateEstimates(sk_k,ck_k,zCurrent,ySamp);

%% use fminc to solve for best trajectory
% mpc parameters
dLMax = hiLvlCtrl.midLvlCtrl.dLMax;
dLMin = hiLvlCtrl.midLvlCtrl.dLMin;
dTMax = hiLvlCtrl.midLvlCtrl.dTMax;
dTMin = hiLvlCtrl.midLvlCtrl.dTMin;
LMax  = hiLvlCtrl.midLvlCtrl.LMax;
LMin  = hiLvlCtrl.midLvlCtrl.LMin;
TMax  = hiLvlCtrl.midLvlCtrl.TMax;
TMin  = hiLvlCtrl.midLvlCtrl.TMin;
nPred = midLvlKfgp.predictionHorizon;
dt = hiLvlCtrl.midLvlCtrl.dt;

% upper and lower bounds
lbdL = dLMin*ones(nPred,1);
ubdL = dLMax*ones(nPred,1);
lbdT = dTMin*ones(nPred,1);
ubdT = dTMax*ones(nPred,1);
lb   = [lbdL;lbdT];
ub   = [ubdL;ubdT];

% initial value
x0 = zeros(2*nPred,1);

% optimize          
[optTraj,~] = ...
    fmincon(@(dLdT) -midLvlKfgp.calcMpcObjectiveFnThrLengthAndElvOpt(...
    F_t_mpc,sigF_t_mpc,skp1_kp1_mpc,ckp1_kp1_mpc...
    ,LthrSP,elevSP,Lthr,elev,dLdT,hiLvlCtrl),...
    x0,[],[],[],[],lb,ub,...
    @(dLdT)midLvlCtrl_nonlincon(dLdT,nPred,dt,LMax,LMin,TMax,TMin,Lthr,elev),...
    options);

% get other values
[~,powTraj,LthrTraj,elevTraj] = ...
    midLvlKfgp.calcMpcObjectiveFnThrLengthAndElvOpt(...
    F_t_mpc,sigF_t_mpc,skp1_kp1_mpc,ckp1_kp1_mpc...
    ,LthrSP,elevSP,Lthr,elev,optTraj,hiLvlCtrl);

dLTraj = optTraj(1:nPred);
dTtraj = optTraj(nPred+1:end);
            
block.OutputPort(1).Data = real(dLTraj);
block.OutputPort(2).Data = real(dTtraj);
block.OutputPort(3).Data = real(LthrTraj);
block.OutputPort(4).Data = real(elevTraj);
block.OutputPort(5).Data = real(powTraj);

%end Outputs

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate

