close all
clear
clc

ctrl = CTR.controller;
ctrl.add('FPIDNames',{'altitude','roll','yaw'},...
    'FPIDErrorUnits',{'m','deg','deg'},...
    'FPIDOutputUnits',{'m/s','deg','deg'})


ctrl.altitude.kp.Value  = 1;
ctrl.altitude.ki.Value  = 1;
ctrl.altitude.kd.Value  = 1;
ctrl.altitude.tau.Value = 1;

ctrl.roll.kp.Value  = 1;
ctrl.roll.ki.Value  = 1;
ctrl.roll.kd.Value  = 1;
ctrl.roll.tau.Value = 1;

ctrl.yaw.kp.Value  = 1;
ctrl.yaw.ki.Value  = 1;
ctrl.yaw.kd.Value  = 1;
ctrl.yaw.tau.Value = 1;

ctrl.add('GainNames',{'ctrlAllocMat'},...
    'GainUnits',{'deg*s/m'})

ctrl.add('SaturationNames',{'maxAileronDef','maxRudderDef'})

ctrl.maxAileronDef.upperLimit.Value = 1;
ctrl.maxAileronDef.lowerLimit.Value = -1;

ctrl.maxRudderDef.upperLimit.Value = 1;
ctrl.maxRudderDef.lowerLimit.Value = -1;

ctrl.ctrlAllocMat.Value = eye(3);

ctrl.add('SetpointNames',{'altSP'})
ctrl.altSP.Value = 3;
ctrl.altSP.Unit = 'm';

ctrl.scale(0.5)