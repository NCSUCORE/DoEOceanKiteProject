function turbineOpt(block)
%   MPC s-function for lecture 18
%   Written by Chris Vermillion - Built using the MATLAB template as a
%   starting point

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
setup(block);

%endfunction

%% Function: setup ===================================================

function setup(block)

% Register number of ports
block.NumInputPorts  = 5;
block.NumOutputPorts = 1;

block.NumDialogPrms     = 2;



% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

block.InputPort(1).DimensionsMode = 'Fixed';
block.InputPort(1).Dimensions = [3 1];
block.InputPort(2).DimensionsMode = 'Fixed';
block.InputPort(2).Dimensions = [3 1];
block.InputPort(3).DimensionsMode = 'Fixed';
block.InputPort(3).Dimensions = [3 1];
block.InputPort(4).DimensionsMode = 'Fixed';
block.InputPort(4).Dimensions = 1;
block.InputPort(5).DimensionsMode = 'Fixed';
block.InputPort(5).Dimensions = [3 3];
block.OutputPort(1).DimensionsMode = 'Fixed';
block.OutputPort(1).Dimensions = [4 1];


% Register parameters
% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [-1, 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

%   Register all relevant methods
block.RegBlockMethod('Outputs', @Outputs);     % Required
%block.RegBlockMethod('SetInputPortSamplingMode', @SetInpPortFrameData);
block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)
vhcl = block.DialogPrm(1).Data;
thr = block.DialogPrm(2).Data;
N = vhcl.numTurbines.Value;

%   Extract x and y postions from input data
angVel  = block.InputPort(1).Data;
velVec = block.InputPort(2).Data;
velWind  = block.InputPort(3).Data;
thrL = block.InputPort(4).Data*4;
g2b = block.InputPort(5).Data;

% Wind Velocity Magnitude
velW        = sqrt(sum(velWind.^2));
% Apparent Velocity
velApp      = velWind-velVec;
% Apparent Velocity Magnitude
velAppMag   = sqrt(sum(velApp.^2));
% Normalized Z-Angular Velocity
eta         = angVel(3)/velAppMag;
% Angle of Attack
vBdy = g2b*velApp;
alpha = atan2(vBdy(3),vBdy(1))*180/pi;

% TSR
lb = [1; 1];
ub = [8.5;8.5];

opts = optimoptions('fmincon','Display','none');
J = @(gamma)turbPow(alpha,eta,velW,vhcl,thr,thrL,gamma);
g = @(gamma)turbCon(alpha,eta,velW,vhcl,thr,thrL,gamma);
TSR = fmincon(J,[3;3],[],[],[],[],lb,ub,g,opts);

block.OutputPort(1).Data = [TSR(1)*ones(N/2,1); TSR(2)*ones(N/2,1)];

%end Outputs


%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
    %%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate
