clear
close all
clc
createAllActuatorCtrlBus
createAllActuatorPlantBus
createRealFlowEnvironmentBus

ctrl = allActuatorCtrlClass;

sim('allActuatorCtrl_th')

simout