clear
clc
format compact

% this is the build script for creating controller using class definition
% 'controller' for a three tethered system that is being used by ayaz

% the script saves the variable 'ctrl' to a 'ayazThreeTetCtrl.mat'

%% Set up controller
% Create
ctrl = CTR.controller;
% add filtered PID controllers
% FPID controllers are initialized to zero gains, 1s time const
ctrl.add('FPIDNames',{'tetherAlti','tetherPitch','tetherRoll','elevators','ailerons','rudder'},...
    'FPIDErrorUnits',{'m','rad','rad','deg','deg','deg'},...
    'FPIDOutputUnits',{'m/s','m/s','m/s','deg','deg','deg'});

% add control allocation matrix (implemented as a simple gain)
ctrl.add('GainNames',{'ctrlSurfAllocationMat','thrAllocationMat','ySwitch','rollAmp'},...
    'GainUnits',{'','','m','deg'});

% add output saturation
ctrl.add('SaturationNames',{'outputSat'});

% add setpoints
ctrl.add('SetpointNames',{'altiSP','pitchSP','yawSP'},...
    'SetpointUnits',{'m','deg','deg'});

% tether controllers
ctrl.tetherAlti.kp.setValue(0,'(m/s)/(m)');
ctrl.tetherAlti.ki.setValue(0,'(m/s)/(m*s)');
ctrl.tetherAlti.kd.setValue(0,'(m/s)/(m/s)');
ctrl.tetherAlti.tau.setValue(5,'s');

ctrl.tetherPitch.kp.setValue(2*1,'(m/s)/(rad)');
ctrl.tetherPitch.ki.setValue(0,'(m/s)/(rad*s)');
ctrl.tetherPitch.kd.setValue(4*1,'(m/s)/(rad/s)');
ctrl.tetherPitch.tau.setValue(0.1,'s');

ctrl.tetherRoll.kp.setValue(4*1,'(m/s)/(rad)');
ctrl.tetherRoll.ki.setValue(0,'(m/s)/(rad*s)');
ctrl.tetherRoll.kd.setValue(12*1,'(m/s)/(rad/s)');
ctrl.tetherRoll.tau.setValue(0.01,'s');

ctrl.thrAllocationMat.setValue([1 .5 -.5; 1 -.5 0; 1 .5 .5],'');

% Set the values of the controller parameters
ctrl.ailerons.kp.setValue(0,'(deg)/(deg)');
ctrl.ailerons.ki.setValue(0,'(deg)/(deg*s)');
ctrl.ailerons.kd.setValue(0,'(deg)/(deg/s)');
ctrl.ailerons.tau.setValue(0.5,'s');

ctrl.elevators.kp.setValue(0,'(deg)/(deg)'); % do we really want to represent unitless values like this?
ctrl.elevators.ki.setValue(0,'(deg)/(deg*s)');
ctrl.elevators.kd.setValue(0,'(deg)/(deg/s)'); % Likewise, do we want (deg*s)/(deg) or just s?
ctrl.elevators.tau.setValue(0.01,'s');

ctrl.rudder.kp.setValue(0,'(deg)/(deg)');
ctrl.rudder.ki.setValue(0,'(deg)/(deg*s)');
ctrl.rudder.kd.setValue(0,'(deg)/(deg/s)');
ctrl.rudder.tau.setValue(0.5,'s');

ctrl.ctrlSurfAllocationMat.setValue([-1 0 0; 1 0 0; 0 -1 0; 0 0 1],'');

ctrl.outputSat.upperLimit.setValue(0,'');
ctrl.outputSat.lowerLimit.setValue(0,'');


%% save file in its respective directory
currentMfileLoc = fileparts(mfilename('fullpath'));

if isempty(ctrl.altiSP.Value.Data) || isempty(ctrl.pitchSP.Value.Data) || isempty(ctrl.yawSP.Value.Data)...
        || isempty(ctrl.ySwitch.Value) || isempty(ctrl.rollAmp.Value)
    save(strcat(currentMfileLoc,'\ayazThreeTetCtrl.mat'),'ctrl');
else
    error('Please do not specify setpoints in build script')
end

