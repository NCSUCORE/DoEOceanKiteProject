function optimizePathShapeRGP_Lvl2sFunc(block)
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
block.NumInputPorts  = 5;
block.NumOutputPorts = 3;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
rgp = block.DialogPrm(1).Data;
nP  = size(rgp.xBasis,2);
nC  = size(rgp.xBasis,1);
IPsizes = [nC 1 nP nP^2 1];
OPsizes = [nC nP nP^2];

for ii = 1:5
block.InputPort(ii).Dimensions        = IPsizes(ii);
block.InputPort(ii).DatatypeID        = 0; 
block.InputPort(ii).Complexity        = 'Real';
block.InputPort(ii).DirectFeedthrough = true;
block.InputPort(ii).SamplingMode      = 'Sample';
end

% Override output port properties
for ii = 1:3
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
rgp = block.DialogPrm(1).Data;

xSamp  = block.InputPort(1).Data(:);
yVal   = block.InputPort(2).Data;
muGt_1 = block.InputPort(3).Data(:)';
cGt_1  = reshape(block.InputPort(4).Data,length(muGt_1),[]);
lapNum = block.InputPort(5).Data;

[predMean,postVarMat] =...
    rgp.calcPredMeanAndPostVar(muGt_1,cGt_1,xSamp,yVal);

if mod(lapNum,rgp.numLapBetweenRGP) == 0 && lapNum ~=1 
%     nextPoint = rgp.chooseNextPoint(muGt_1,cGt_1,xSamp,yVal);
    if xSamp(1)-2 >= 18
    nextPoint(1) = xSamp(1)-2;
    nextPoint(2) = xSamp(1)/5;
    else
    nextPoint = xSamp;        
    end
else
    nextPoint = xSamp;
end

block.OutputPort(1).Data = nextPoint;
block.OutputPort(2).Data = real(predMean(:));
block.OutputPort(3).Data = real(postVarMat(:));

%end Outputs

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate

