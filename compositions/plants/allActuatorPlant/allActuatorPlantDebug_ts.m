close all
clear
clc

duration_s = 10;
timeStep_s = .001;

createAllActuatorCtrlBus
createAllActuatorPlantBus
createRealFlowEnvironmentBus

plnt = allActuatorPlantClass;

ctrl = allActuatorCtrlClass;

plnt.setInitialConditions('Position',[0,0,ctrl.altitudeSetpoint.Value],'EulerAngles', [ctrl.rollSetpoint.Value,ctrl.pitchSetpoint.Value,0]);

sim('allActuatorPlant_th')