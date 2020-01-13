function val = simOptFunction(vhcl,thr,wnch,fltCtrl,...
    initVals,coeffs,tscExp,dataRange)

%% modify simulation parameters
% vehicle
vhcl.portWing.CL.setValue(coeffs(1).*initVals.CLWing,'')
vhcl.portWing.CD.setValue(coeffs(2).*initVals.CDWing,'')

vhcl.stbdWing.CL.setValue(coeffs(1).*initVals.CLWing,'')
vhcl.stbdWing.CD.setValue(coeffs(2).*initVals.CDWing,'')

vhcl.hStab.CL.setValue(coeffs(3).*initVals.CLhStab,'')
vhcl.hStab.CD.setValue(coeffs(4).*initVals.CDhStab,'')

vhcl.vStab.CL.setValue(coeffs(5).*initVals.CLvStab,'')
vhcl.vStab.CD.setValue(coeffs(6).*initVals.CDvStab,'')

% vhcl.addedMass.setValue(coeffs(3:5).*initVals.addedMass)
% 
% vhcl.buoyFactor.setValue(coeffs(6)*initVals.buoyFactor)

% winches
maxReleaseSpeed = coeffs(7)*initVals.wnchMaxReleaseSpeed;
wnch.winch1.maxSpeed.setValue(maxReleaseSpeed,'m/s')
wnch.winch2.maxSpeed.setValue(maxReleaseSpeed,'m/s')
wnch.winch3.maxSpeed.setValue(maxReleaseSpeed,'m/s')

% tether controllers
aKp = 1.5*maxReleaseSpeed;
pKp = 1*maxReleaseSpeed;
rKp = 2*maxReleaseSpeed;

fltCtrl.tetherAlti.kp.setValue(aKp,'(m/s)/(m)');
fltCtrl.tetherAlti.ki.setValue(0,'(m/s)/(m*s)');
fltCtrl.tetherAlti.kd.setValue(0,'(m/s)/(m/s)');
fltCtrl.tetherAlti.tau.setValue(2,'s');

fltCtrl.tetherPitch.kp.setValue(pKp,'(m/s)/(rad)');
fltCtrl.tetherPitch.ki.setValue(0,'(m/s)/(rad*s)');
fltCtrl.tetherPitch.kd.setValue(2*pKp,'(m/s)/(rad/s)');
fltCtrl.tetherPitch.tau.setValue(0.5,'s');

fltCtrl.tetherRoll.kp.setValue(rKp,'(m/s)/(rad)');
fltCtrl.tetherRoll.ki.setValue(0,'(m/s)/(rad*s)');
fltCtrl.tetherRoll.kd.setValue(2*rKp,'(m/s)/(rad/s)');
fltCtrl.tetherRoll.tau.setValue(0.5,'s');


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






