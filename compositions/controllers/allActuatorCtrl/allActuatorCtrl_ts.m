clear
close all
clc
createAllActuatorCtrlBus
createAllActuatorPlantBus
createRealFlowEnvironmentBus

ctrl = allActuatorCtrlClass;
ctrl.altitudeSetpoint.Value
ctrl.scale(0.5,1)
ctrl.altitudeSetpoint.Value
