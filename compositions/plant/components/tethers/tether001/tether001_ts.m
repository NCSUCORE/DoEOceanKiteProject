close all
clear
clc

createConstantUniformFlowEnvironmentBus
createThrAttachPtKinematicsBus
createOneTetherThreeSurfaceCtrlBus


thrs = OCT.tethers;
thrs.setNumTethers(1,'')
thrs.setNumNodes(5,'')
thrs.build

thrs.tether1.setDiameter(0.001,'m');
thrs.tether1.setYoungsMod(20e9,'Pa');
thrs.tether1.setVehicleMass(5000,'kg');
thrs.tether1.setDampingRatio(0.01,'');
thrs.tether1.setDragCoeff(0.5,'');
thrs.tether1.setDensity(1300,'kg/m^3');
thrs.tether1.setInitGndNodePos([0 0 0],'m');
thrs.tether1.setInitAirNodePos([0 0 201],'m');
thrs.tether1.setInitGndNodeVel([0 0 0],'m/s');
thrs.tether1.setInitAirNodeVel([0 0 0],'m/s');
thrs.tether1.setDragEnable(true,'');
thrs.tether1.setSpringDamperEnable(true,'');
thrs.tether1.setNetBuoyEnable(true,'');


airPosVec = [0 0 201];
airVelVec = [0 0 0];
airMomArm(1).posVec = [0 0 0];
airAngVel = [0 0 0];

gndPosVec = [0 0 0];
gndVelVec = [0 0 0];
gndMomArm(1).posVec = [0 0 0];
gndAngVel = [0 0 0];

bdy2GndMat = eye(3);

thrReleaseCmd = 0;

env.water.velVec.Value = [0 0 0];

wnch = OCT.winches;
wnch.setNumWinches(1,'');
wnch.build;
wnch.winch1.setInitLength(200,'m');
wnch.winch1.setMaxSpeed(inf,'m/s');
wnch.winch1.setTimeConst(1,'s');
wnch.winch1.setMaxAccel(inf,'m/s^2');


sim('tether001_th')
