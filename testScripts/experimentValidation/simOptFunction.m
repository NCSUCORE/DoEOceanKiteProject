function val = simOptFunction(vhcl,thr,...
    initVals,coeffs,tscExp,dataRange)

% modify simulation parameters
vhcl.portWing.CL.setValue(coeffs(1).*initVals.CLWing,'')
vhcl.portWing.CD.setValue(coeffs(2).*initVals.CDWing,'')

vhcl.stbdWing.CL.setValue(coeffs(1).*initVals.CLWing,'')
vhcl.stbdWing.CD.setValue(coeffs(2).*initVals.CDWing,'')

vhcl.hStab.CL.setValue(coeffs(1).*initVals.CLhStab,'')
vhcl.hStab.CD.setValue(coeffs(2).*initVals.CDhStab,'')

vhcl.vStab.CL.setValue(coeffs(1).*initVals.CLvStab,'')
vhcl.vStab.CD.setValue(coeffs(2).*initVals.CDvStab,'')

% vhcl.addedMass.setValue(coeffs(3:5).*initVals.addedMass)
% 
% vhcl.buoyFactor.setValue(coeffs(6)*initVals.buoyFactor)


%% run sim Model
simWithMonitor('OCTModel')
parseLogsout

% process sim data
tscSim = evalin('base','tsc');

timeSim = 0:(tscExp.roll_rad.Time(end) - tscExp.roll_rad.Time(end-1)):...
    tscSim.eulerAngles.Time(end);

tscSim.positionVec = squeeze(resample(tscSim.positionVec,timeSim));
tscSim.eulerAngles = squeeze(resample(tscSim.eulerAngles,timeSim));
tscSim.velocityVec = squeeze(resample(tscSim.velocityVec,timeSim));
tscSim.angularVel = squeeze(resample(tscSim.angularVel,timeSim));

%% calculate optimization objective function
val = calObjF(tscSim,tscExp,dataRange)

end






