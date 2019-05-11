% Test script to test Ayaz's three tether + aero surfaces model
format compact
% Initialize the highest level model
OCTModel_init

%% master scaling parameters
lengthScaleFactor   = 1/1;    % length scale
densityScaleFactor  = 1/1;    % density scale

% Initialize the controller
allActuatorCtrl_init
allActuatorPlant_init
realFlowEnvironment_init

% Scale the controller
ctrl = ctrl.scale(lengthScaleFactor);





