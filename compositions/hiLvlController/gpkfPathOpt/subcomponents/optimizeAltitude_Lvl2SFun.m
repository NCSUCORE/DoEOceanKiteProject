function optimizeAltitude_Lvl2SFun(block)
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
block.NumOutputPorts = 5;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
mpckfgp = block.DialogPrm(1).Data;
nP   = length(mpckfgp.initVals.s0);
IPsizes = [nP nP^2 1 1];
OPsizes = mpckfgp.predictionHorizon*[1 1 1 1 1];

for ii = 1:4
block.InputPort(ii).Dimensions         = IPsizes(ii);
block.InputPort(ii).DatatypeID        = 0; 
block.InputPort(ii).Complexity        = 'Real';
block.InputPort(ii).DirectFeedthrough = true;
block.InputPort(ii).SamplingMode      = 'Sample';
end

% Override output port properties
for ii = 1:5
block.OutputPort(ii).Dimensions    = OPsizes(ii);
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
mpckfgp = block.DialogPrm(1).Data;
hiLvlCtrl = block.DialogPrm(2).Data;

sk_k    = block.InputPort(1).Data;
ck_k    = reshape(block.InputPort(2).Data,length(sk_k),[]);
zCurrent   = block.InputPort(3).Data;
flowVal = block.InputPort(4).Data;

options = optimoptions('fmincon','algorithm','sqp','display','off');

predictionHorz = mpckfgp.predictionHorizon;

ySamp =  mpckfgp.meanFunction(zCurrent,mpckfgp.meanFnProps(1),...
    mpckfgp.meanFnProps(2)) - flowVal;

% mpc kalman estimate
[F_t_mpc,sigF_t_mpc,skp1_kp1_mpc,ckp1_kp1_mpc] = ...
    mpckfgp.calcKalmanStateEstimates(sk_k,ck_k,zCurrent,ySamp);

%% use fminc to solve for best trajectory
% constraints
duMax = hiLvlCtrl.maxStepChange;
Astep = zeros(predictionHorz-1,predictionHorz);
bstep = duMax*ones(2*(predictionHorz-1),1);
for ii = 1:predictionHorz-1
    for jj = 1:predictionHorz
        if ii == jj
            Astep(ii,jj) = -1;
            Astep(ii,jj+1) = 1;
        end
        
    end
end
Astep = [Astep;-Astep];
% bounds on first step
fsBoundsA = zeros(2,predictionHorz);
fsBoundsA(1,1) = 1;
fsBoundsA(2,1) = -1;
A = [fsBoundsA;Astep];
% upper and lower bounds
lb      = hiLvlCtrl.minVal*ones(1,predictionHorz);
ub      = hiLvlCtrl.maxVal*ones(1,predictionHorz);
%
fsBoundsB(1,1) = zCurrent + duMax;
fsBoundsB(2,1) = -(zCurrent - duMax);
b = [fsBoundsB;bstep];

% optimize
[optTraj,~] = ...
    fmincon(@(u) -mpckfgp.calcMpcObjectiveFnForAltOpt(...
    F_t_mpc,sigF_t_mpc,skp1_kp1_mpc,ckp1_kp1_mpc...
    ,u,hiLvlCtrl),zCurrent*ones(predictionHorz,1),A,b,[],[]...
    ,lb,ub,[],options);

% get other values
[~,jExploitFmin,jExploreFmin,flowPred] = ...
    mpckfgp.calcMpcObjectiveFnForAltOpt(F_t_mpc,sigF_t_mpc,skp1_kp1_mpc,...
    ckp1_kp1_mpc,optTraj,hiLvlCtrl);

elTraj = hiLvlCtrl.elevationGrid(flowPred(:),optTraj(:));
thrLTraj = hiLvlCtrl.thrLenGrid(flowPred(:),optTraj(:));

block.OutputPort(1).Data = real(optTraj);
block.OutputPort(2).Data = real(jExploitFmin);
block.OutputPort(3).Data = real(jExploreFmin);
block.OutputPort(4).Data = real(elTraj);
block.OutputPort(5).Data = real(thrLTraj);

%end Outputs

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate

