% Script to test the origional model against the modularized model
clear all;clc;

OCTModel_init

modularPlant_init

angVel = [0 0 1];

createThrAttachPtKinematicsBus(gndStnMmtArms)

sim('thrAttachPtKinematics_th')

simout.posVec.Data
simout.velVec.Data
simout1.posVec.Data
simout1.velVec.Data
simout2.posVec.Data
simout2.velVec.Data