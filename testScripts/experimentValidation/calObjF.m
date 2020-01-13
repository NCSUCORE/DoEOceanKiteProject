function val = calObjF(tscSim,tscExp,dataRange)

% load data
timeExp = tscExp.roll_rad.Time;
timeSim = tscSim.eulerAngles.Time;

% find indices in time corresponding to dataRange
startIdxSim = find((timeSim - dataRange(1)).^2 < 1e-6);
endIdxSim = find((timeSim - dataRange(2)).^2 < 1e-6);

startIdxExp = find((timeExp - dataRange(1)).^2 < 1e-6);
endIdxExp = find((timeExp - dataRange(2)).^2 < 1e-6);

if startIdxSim ~= startIdxExp && endIdxSim ~=endIdxExp
    error('Start and end index while computing objF dont match')
end

% extract simulation values
yPosSim = tscSim.positionVec.Data(2,startIdxSim:endIdxSim);
zPosSim = tscSim.positionVec.Data(3,startIdxSim:endIdxSim);
rollSim = tscSim.eulerAngles.Data(1,startIdxSim:endIdxSim);
yawSim = tscSim.eulerAngles.Data(3,startIdxSim:endIdxSim);

yPosExp = tscExp.CoMPosVec_cm.Data(2,startIdxSim:endIdxSim);
zPosExp = tscExp.CoMPosVec_cm.Data(3,startIdxSim:endIdxSim);
rollExp = tscExp.roll_rad.Data(startIdxSim:endIdxSim);
yawExp = tscExp.yaw_rad.Data(startIdxSim:endIdxSim);

% val = calcRMSE(yPosSim,yPosExp)/max(abs(yPosExp));

val = 1.0*calcRMSE(yawSim,yawExp)/max(abs(yawExp)) + ...
    1.0*calcRMSE(yPosSim,yPosExp)/max(abs(yPosExp)) + ...
    1.0*calcRMSE(zPosSim,zPosExp)/max(abs(zPosExp)) + ...
    1.0*calcRMSE(rollSim,rollExp)/max(abs(rollExp));

end




