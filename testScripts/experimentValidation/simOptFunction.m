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

vhcl.addedMass.setValue(coeffs(7:9).*initVals.addedMass,'kg')
vhcl.addedInertia.setValue(coeffs(10:12).*initVals.addedMass,'kg*m^2')

fprintf(repmat('%0.4f ',1,numel(coeffs)),coeffs);
fprintf('\n ');

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
try
    val = calObjF(tscSim,tscExp,dataRange)
catch
    val = 100
end
fileID = fopen('solutionsRecord.txt','a');
fprintf(fileID,'Design variables=\n');
fprintf(fileID,repmat('%0.3f ',1,numel(coeffs)),coeffs);
fprintf(fileID,'\nObjF = %0.4f\n',val);
fprintf(fileID,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
fclose(fileID);




end






