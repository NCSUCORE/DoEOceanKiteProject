clc;clear all
if slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  =75*sqrt(lengthScaleFactor);
%% Set up simulation (To be dele
% VEHICLE               = 'vehicle000';
% WINCH                 = 'winch000';
% TETHERS               = 'tether000';
% GROUNDSTATION         = 'groundStation000';
% ENVIRONMENT           = 'constantUniformFlow';
% FLIGHTCONTROLLER      = 'pathFollowingController';
% GNDSTNCONTROLLER      = 'oneDoF';
%% Set up environment
% Create
loadComponent('pathFollowingEnv.mat')
% Set Values
flowspeed = 1.5; %m/s options are .1, .5, 1, 1.5, and 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%8
env.water.velVec.setValue([flowspeed 0 0],'m/s');
% Scale up/down
%% Path Choice
 pathIniRadius = 125; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%7
% pathFuncName='lemOfBooth';
 %pathParamVec=[.73,.8,.4,0,pathIniRadius];%Lem
 % pathParamVec=[1,1.7,.36,0,pathIniRadius];%Lem
  pathFuncName='circleOnSphere'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%6
 pathParamVec=[pi/8,-3*pi/8,0,pathIniRadius];%Circle

swapableID=fopen('swapablePath.m','w');
fprintf(swapableID,[... %This should be removed eventually. Changing the file programmatically is bad form
           'function [posGround,varargout] = swapablePath(pathVariable,geomParams)\n',...
           '     func = @%s;\n',...
           '     posGround = func(pathVariable,geomParams);\n',...
           '     if nargout == 2\n',...
           '          [~,varargout{1}] = func(pathVariable,geomParams);\n',...
           '     end\n',...
           'end'],pathFuncName);
fclose(swapableID);

%% Set Vehicle initial conditions
tetherLength = pathIniRadius;
initVelMag= 6;
onpath = true;
if onpath
    pathParamStart = .1;
    [ini_Rcm,ini_Vcm]=swapablePath(pathParamStart,pathParamVec);
    ini_Vcm=initVelMag*ini_Vcm;
    [long,lat,~]=cart2sph(ini_Rcm(1),ini_Rcm(2),ini_Rcm(3));
    tanToGr = [-sin(lat)*cos(long) -sin(long) -cos(lat)*cos(long);
               -sin(lat)*sin(long) cos(long)  -cos(lat)*sin(long);
               cos(lat)            0          -sin(lat);];
else
    long = -1.9*pi/8;
    lat = -pi/4;
    initVelAng = 90;%degrees
    
    tanToGr = [-sin(lat)*cos(long) -sin(long) -cos(lat)*cos(long);
               -sin(lat)*sin(long) cos(long)  -cos(lat)*sin(long);
               cos(lat)            0          -sin(lat);];
    ini_Rcm = tetherLength*[cos(long).*cos(lat);
                            sin(long).*cos(lat);
                            sin(lat);];
    ini_Vcm= initVelMag*tanToGr*[cosd(initVelAng);sind(initVelAng);0];
end

ini_pitch=atan2(ini_Vcm(3),sqrt(ini_Vcm(1)^2+ini_Vcm(2)^2));
ini_yaw=atan2(-ini_Vcm(2),-ini_Vcm(1));

[bodyToGr,~]=rotation_sequence([0 ini_pitch ini_yaw]);
bodyY_before_roll=bodyToGr*[0 1 0]';
tanZ=tanToGr*[0 0 1]';

if (strcmp(pathFuncName,'lemOfBooth')&& pathParamVec(3) < 0 ) ||  (strcmp(pathFuncName,'circleOnSphere')&& pathParamVec(2)<0) 
ini_roll=((pi/2)+acos(dot(bodyY_before_roll,tanZ)/(norm(bodyY_before_roll)*norm(tanZ))));
else 
    ini_roll=((pi/2)-acos(dot(bodyY_before_roll,tanZ)/(norm(bodyY_before_roll)*norm(tanZ))));
end
ini_Vcm_body = [-initVelMag;0;0];
ini_eul=[ini_roll ini_pitch ini_yaw];

%% Vehicle Parameters
loadComponent('pathFollowingVhcl.mat')

% % % initial conditions
vhcl.setInitPosVecGnd(ini_Rcm,'m');
vhcl.setInitVelVecGnd(ini_Vcm_body,'m/s');
vhcl.setInitEulAng(ini_eul,'rad');
vhcl.setInitAngVelVec([0;0;0],'rad/s');

% % % plot
% vhcl.plot
% vhcl.plotCoeffPolars

%% Ground Station
loadComponent('pathFollowingGndStn.mat')

gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
% gndStn.thrAttch1.velVec.setValue([0 0 0]','m/s');

%% Tethers
% Create
loadComponent('pathFollowingTether.mat')

% Set parameter values
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% winches
loadComponent('oneWnch.mat');
% set initial conditions
wnch.setTetherInitLength(vhcl,env,thr);

%% Controller

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


% pathCtrl.ctrlAllocMat.setValue([-1.1584         0         0;
%                                 1.1584         0         0;
%                                 0             -2.0981    0;
%                                 0              0         4.8067],'(deg)/(N*m)');
pathCtrl.pathParams.setValue(pathParamVec,''); %Unscalable
pathCtrl.searchSize.setValue(.5,'');

pathCtrl.winchSpeedIn.setValue(-0*flowspeed/3,'m/s') %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
pathCtrl.winchSpeedOut.setValue(0*flowspeed/3,'m/s') %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%4
pathCtrl.maxR.setValue(200,'m')
pathCtrl.minR.setValue(100,'m')
 pathCtrl.outRanges.setValue([.5 1;...
                              2 2],''); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%3
%pathCtrl.outRanges.setValue([0 .125;...
%                             .375 .625;...
%                             .875 1],'');
pathCtrl.elevatorReelInDef.setValue(0,'deg')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%!

pathCtrl.maxBank.upperLimit.setValue(27*pi/180,'');
pathCtrl.maxBank.lowerLimit.setValue(-27*pi/180,'');

pathCtrl.yawMoment.kp.setValue(10e5,'(N*m)/(rad)');
pathCtrl.yawMoment.kd.setValue(10*pathCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
pathCtrl.yawMoment.tau.setValue(.01,'s');

pathCtrl.velAng.kp.setValue(pathCtrl.maxBank.upperLimit.Value/(100*(pi/180)),'(rad)/(rad)');
pathCtrl.velAng.kd.setValue(1.5*pathCtrl.velAng.kp.Value,'(rad)/(rad/s)');
pathCtrl.velAng.tau.setValue(.01,'s');
pathCtrl.rollMoment.tau.setValue (.01,'s');

%% gain tuning based on flow speed 
switch flowspeed
case 0.1
    pathCtrl.perpErrorVal.setValue(7*pi/180,'rad');
    pathCtrl.rollMoment.kp.setValue(4e5,'(N*m)/(rad)');
    pathCtrl.rollMoment.kd.setValue(.2*pathCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
case 0.5
    pathCtrl.perpErrorVal.setValue(4*pi/180,'rad');
    pathCtrl.rollMoment.kp.setValue(4e5,'(N*m)/(rad)');
    pathCtrl.rollMoment.kd.setValue(.6*pathCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
case 1  
    pathCtrl.perpErrorVal.setValue(3*pi/180,'rad');
    pathCtrl.rollMoment.kp.setValue(3e5,'(N*m)/(rad)');
    pathCtrl.rollMoment.kd.setValue(2*pathCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
case 1.5
    pathCtrl.perpErrorVal.setValue(5*pi/180,'rad');
    pathCtrl.rollMoment.kp.setValue(6e5,'(N*m)/(rad)');
    pathCtrl.rollMoment.kd.setValue(3*pathCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
    pathCtrl.velAng.tau.setValue(.01,'s');
    pathCtrl.rollMoment.tau.setValue (.01,'s');
case 2
    pathCtrl.perpErrorVal.setValue(3*pi/180,'rad');   
    pathCtrl.rollMoment.kp.setValue(5.9e5,'(N*m)/(rad)');
    pathCtrl.rollMoment.kd.setValue(4.5*pathCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
end

%% Scale
% scale environment
env.scale(lengthScaleFactor,densityScaleFactor);
% scale vehicle
vhcl.scale(lengthScaleFactor,densityScaleFactor);
vhcl.calcFluidDynamicCoefffs;
% scale ground station
gndStn.scale(lengthScaleFactor,densityScaleFactor);
% scale tethers
thr.scale(lengthScaleFactor,densityScaleFactor);
% scale winches
wnch.scale(lengthScaleFactor,densityScaleFactor);
% scale controller
% pathCtrl.scale(lengthScaleFactor)
%% Run the simulation
traditionalBool = 0;
sim('OCTModel')
parseLogsout;
stopCallback