

FLIGHTCONTROLLER = 'pathFollowingController';

%Properties that must be user defined (defined in the test script)
    %pathParamVec
    %outRanges
    %traditionalBool
%Properties that are dependant (defined in the test script)
    %ctrlAllocMat
    %winchSpeedIn
    %winchSpeedOut
fltCtrl = CTR.controller;
%% Saturations
fltCtrl.add('SaturationNames',{'maxBank','controlSigMax'})

%fltCtrl.maxBank.upperLimit.setValue(30*pi/180,'');
%fltCtrl.maxBank.lowerLimit.setValue(-30*pi/180,'');

fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');


fltCtrl.controlSigMax.lowerLimit.setValue(-30,'');
fltCtrl.controlSigMax.upperLimit.setValue(30,'');

%% FPID's
fltCtrl.add('FPIDNames',{'velAng','rollMoment','yawMoment'},...
    'FPIDErrorUnits',{'rad','rad','rad'},...
    'FPIDOutputUnits',{'rad','N*m','N*m'})

fltCtrl.velAng.kp.setValue(fltCtrl.maxBank.upperLimit.Value/(100*(pi/180)),'(rad)/(rad)');
fltCtrl.velAng.kd.setValue(1.5*fltCtrl.velAng.kp.Value,'(rad)/(rad/s)');
fltCtrl.velAng.tau.setValue(.01,'s');

%fltCtrl.yawMoment.kp.setValue(10e5,'(N*m)/(rad)');
%fltCtrl.yawMoment.kd.setValue(0*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
%fltCtrl.yawMoment.tau.setValue(.01,'s');

fltCtrl.rollMoment.kp.setValue(4e5,'(N*m)/(rad)');
fltCtrl.rollMoment.kd.setValue(.2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue (.01,'s');

%% Gains
fltCtrl.add('GainNames',...
             {'ctrlAllocMat','perpErrorVal','pathParams','searchSize',...
              'winchSpeedIn','winchSpeedOut','minR','maxR',...
              'outRanges','elevatorReelInDef','startControl',...
              'traditionalBool'},...
             'GainUnits',...
             {'(deg)/(m^3)','rad','','','m/s','m/s','m','m','',...
              'deg','s',''})

%see top of file for list of variables that must be defined outside of mat file
fltCtrl.perpErrorVal.setValue(7*pi/180,'rad');
fltCtrl.searchSize.setValue(.5,'');

fltCtrl.minR.setValue(100,'m')
fltCtrl.maxR.setValue(200,'m')

fltCtrl.elevatorReelInDef.setValue(25,'deg')

fltCtrl.startControl.setValue(1,'s')
%% Save
saveBuildFile('fltCtrl',mfilename,'variant','FLIGHTCONTROLLER');