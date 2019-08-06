FLIGHTCONTROLLER = 'pathFollowingController';
pathCtrl = CTR.controller;

pathCtrl.add('SaturationNames',{'maxBank','controlSigMax'})
pathCtrl.controlSigMax.lowerLimit.setValue(-30,'');
pathCtrl.controlSigMax.upperLimit.setValue(30,'');

pathCtrl.add('FPIDNames',{'velAng','rollMoment','yawMoment'},...
    'FPIDErrorUnits',{'rad','rad','rad'},...
    'FPIDOutputUnits',{'rad','N*m','N*m'})

pathCtrl.add('GainNames',...
             {'ctrlAllocMat','perpErrorVal','pathParams','searchSize',...
              'constantPitchSig','winchSpeedOut','winchSpeedIn','maxR',...
              'minR','outRanges','elevatorReelInDef'},...
             'GainUnits',...
             {'(deg)/(m^3)','rad','','','deg','m/s','m/s','m','m','',...
              'deg'})

 allMat = zeros(4,3);
 allMat(1,1)=-1/(2*vhcl.portWing.GainCL.Value(2)*...
     vhcl.portWing.refArea.Value*abs(vhcl.portWing.aeroCentPosVec.Value(2)));
 allMat(2,1)=-1*allMat(1,1);
 allMat(3,2)=-1/(vhcl.hStab.GainCL.Value(2)*...
     vhcl.hStab.refArea.Value*abs(vhcl.hStab.aeroCentPosVec.Value(1)));
 allMat(4,3)= 1/(vhcl.vStab.GainCL.Value(2)*...
     vhcl.vStab.refArea.Value*abs(vhcl.vStab.aeroCentPosVec.Value(1))); 
 pathCtrl.ctrlAllocMat.setValue(allMat,'(deg)/(m^3)');


pathCtrl.pathParams.setValue(pathParamVec,''); %Unscalable
pathCtrl.searchSize.setValue(.5,'');

pathCtrl.winchSpeedIn.setValue(-0*flowspeed/3,'m/s')
pathCtrl.winchSpeedOut.setValue(0*flowspeed/3,'m/s')
pathCtrl.maxR.setValue(200,'m')
pathCtrl.minR.setValue(100,'m')
 pathCtrl.outRanges.setValue([.5 1;...
                              2 2],'');
pathCtrl.elevatorReelInDef.setValue(0,'deg')

pathCtrl.maxBank.upperLimit.setValue(27*pi/180,'');
pathCtrl.maxBank.lowerLimit.setValue(-27*pi/180,'');

pathCtrl.yawMoment.kp.setValue(10e5,'(N*m)/(rad)');
pathCtrl.yawMoment.kd.setValue(10*pathCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');

pathCtrl.velAng.kp.setValue(pathCtrl.maxBank.upperLimit.Value/(100*(pi/180)),'(rad)/(rad)');
pathCtrl.velAng.kd.setValue(1.5*pathCtrl.velAng.kp.Value,'(rad)/(rad/s)');
pathCtrl.velAng.tau.setValue(.01,'s');
pathCtrl.rollMoment.tau.setValue (.01,'s');

saveBuildFile('pathCtrl',mfilename,'variant','FLIGHTCONTROLLER');
