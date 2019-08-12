% Script to build a path following controller to follow that can be used
% with the upper level path-optimization ILC. -MC

% Set the relevant variant
FLIGHTCONTROLLER = 'pathFollowingController';

% Create the controller object
pathCtrl = CTR.controller;

% Add saturations for max bank angle and control signal
pathCtrl.add(...
    'SaturationNames',{'maxBank','controlSigMax'});

% Set the values on the saturations
pathCtrl.controlSigMax.lowerLimit.setValue(-30,'');
pathCtrl.controlSigMax.upperLimit.setValue(30,'');

% Add filtered PID controllers
pathCtrl.add(...
    'FPIDNames',{'velAng','rollMoment','yawMoment'},... % Controller names
    'FPIDErrorUnits',{'rad','rad','rad'},... % Units on error (input) signals
    'FPIDOutputUnits',{'rad','N*m','N*m'}) % Units on output signals

pathCtrl.add('GainNames',...
             {'ctrlAllocMat','perpErrorVal','searchSize',...
              'constantPitchSig','winchSpeedOut','winchSpeedIn','maxR',...
              'minR','outRanges','elevatorReelInDef'},...
             'GainUnits',...
             {'(deg)/(m^3)','rad','','deg','m/s','m/s','m','m','',...
              'deg'})

          
% Size of range of path parameters to search 1 = entire path.
pathCtrl.searchSize.setValue(0.5,'');

% Spool in/out max radius
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
