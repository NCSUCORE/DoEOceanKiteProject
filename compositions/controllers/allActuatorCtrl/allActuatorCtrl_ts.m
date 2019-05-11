clear
close all
clc
createAllActuatorCtrlBus
createAllActuatorPlantBus
createRealFlowEnvironmentBus

ctrl = allActuatorCtrlClass;
ctrl.winchSpeedCmdLim.Unit = 'm/s';
ctrl.altitudeKp.Unit = '1/s';
ctrl.altitudeSetpoint.Value
ctrl.scale(0.5,1)
ctrl.altitudeSetpoint.Value

% sim('allActuatorCtrl_th')
% 
% simout