clc;clear all
if slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end

startControl= 1; %duration_s for 0 control signals. Does not apply to constant elevator angle
lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 75*sqrt(lengthScaleFactor);
%% Set up simulation
% VEHICLE               = 'vehicle000';
% WINCH                 = 'winch000';
% TETHERS               = 'tether000';
% GROUNDSTATION         = 'groundStation000';
% ENVIRONMENT           = 'constantUniformFlow';
% FLIGHTCONTROLLER      = 'pathFollowingController';
% GNDSTNCONTROLLER      = 'oneDoF';
%% Create busses
%  createConstantUniformFlowEnvironmentBus
%  plant_bc;
%  oneTetherThreeSurfaceCtrl_bc;
%  oneDoFGndStnCtrl_bc;
%  createPathFollowingControllerCtrlBus;
% loadComponent('pathFollowingControllerRequiredBusses');

loadComponent('basicILC');
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
% pathCtrl.yawMoment.kp.setValue(3e5,'(N*m)/(rad)');
% pathCtrl.yawMoment.kd.setValue(5*pathCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
%pathCtrl.yawMoment.tau.setValue(.01,'s');

pathCtrl.tanRoll.kp.setValue(pathCtrl.maxBank.upperLimit.Value/(100*(pi/180)),'(rad)/(rad)');
pathCtrl.tanRoll.kd.setValue(1.5*pathCtrl.tanRoll.kp.Value,'(rad)/(rad/s)');
pathCtrl.tanRoll.tau.setValue(.01,'s');
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
    pathCtrl.tanRoll.tau.setValue(.01,'s');
    pathCtrl.rollMoment.tau.setValue (.01,'s');
case 2
    pathCtrl.perpErrorVal.setValue(3*pi/180,'rad');   
    pathCtrl.rollMoment.kp.setValue(5.9e5,'(N*m)/(rad)');
    pathCtrl.rollMoment.kd.setValue(4.5*pathCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
end
% pathCtrl.rollMoment.kp.setValue(5e5,'(N*m)/(rad)');
% pathCtrl.perpErrorVal.setValue(3*pi/180,'rad');   
% pathCtrl.rollMoment.kd.setValue(.3*pathCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
 % pathCtrl.rollMoment.kd.setValue(3*pathCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
% pathCtrl.perpErrorVal.setValue(8*pi/180,'rad');
%pathCtrl.scale(scaleFactor);%% scale 
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
simWithMonitor('OCTModel')
parseLogsout;
%% Saving for Presentation
% newfold='trad/circ/15mps'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1
% mkdir(newfold) 
% cd(newfold)
% 
% plotPosition
% saveas(gcf,'position.png')
% savefig('pos.fig')
% plotVelocity
% saveas(gcf,'velocity.png')
% savefig('vel.fig')
% plotTenVecMags
% saveas(gcf,'tension.png')
% savefig('ten.fig')
% plotSphericalCoordinates
% saveas(gcf,'spherical.png')
% savefig('sph.fig')
% 
figure
 timevec=tsc.velocityVec.Time;
 ten=squeeze(sqrt(sum(tsc.FThrNetBdy.Data.^2,1)));
plot(tsc.thrReleaseSpeeds.Time,tsc.thrReleaseSpeeds.Data.*ten)
xlabel('time (s)')
ylabel('Power (Watts)')
 [~,i1]=min(abs(timevec - 200));
 [~,i2]=min(abs(timevec -400)); %(timevec(end)/2)));
 [~,poweri1]=min(tsc.thrReleaseSpeeds.Data(i1:i2).*ten(i1:i2));
poweri1 = poweri1 + i1;
[~,i3]=min(abs(timevec - (timevec(end)/2)));
[~,i4]=min(abs(timevec - timevec(end)));
i4=i4-1;
[~,poweri2]=min(tsc.thrReleaseSpeeds.Data(i3:i4).*ten(i3:i4));
poweri2 = poweri2 + i3;
% Manual Override. Rerun with this to choose times
%           t1 = input("time for first measurement");
%             [~,poweri1]=min(abs(timevec - t1));
%             t2 = input("time for second measurement");
%             [~,poweri2]=min(abs(timevec - t2));
hold on
ylims=ylim;
plot([timevec(poweri1) timevec(poweri1)], [-1e6 1e6],'r--')
plot([timevec(poweri2) timevec(poweri2)], [-1e6 1e6],'r--')
ylim(ylims);
 meanPower = mean(tsc.thrReleaseSpeeds.Data(poweri1:poweri2).*ten(poweri1:poweri2));
title(sprintf('Power vs Time; Average Power between lines = %4.2f Watts',meanPower));
saveas(gcf,'power.png')
savefig('pow.fig')
% 
% velmags = sqrt(sum((tsc.velocityVec.Data(:,:,:)).^2,1));
% meanVelocity = mean(squeeze(velmags));
% meanTension = mean(squeeze(sqrt(sum(tsc.FThrNetBdy.Data.^2,1))));
% meanLOverD = mean(squeeze(sqrt(sum(tsc.FLiftBdy.Data.^2,1)))./squeeze(sqrt(sum(tsc.FDragBdy.Data.^2,1))));
% meanAlpha = mean(squeeze(tsc.alphaLocal.Data(1,1,:)));
% 
% fid=fopen('means.txt','w');
% fprintf(fid,strcat('Mean Power = %e Watts\n',...
%              'Mean Velocity = %f m/s\n',...
%              'Mean Tension = %e Newtons\n',...
%              'Mean L/D = %f\n',...
%              'Mean Angle of Attack = %f degrees\n'),...
%             meanPower,meanVelocity,meanTension,meanLOverD,meanAlpha);
% fclose(fid);
% save('allvars')
% kiteAxesPlot
% close all
% cd ../../../..
 %% %% Plot choices
% % errorSigsPlot = 0;
% % velMagsPlot = 1;
% % radialPosPlot = 1;
% % tetherTenMagPlot = 1;
% % alphaLocalPlot = 0;
% % powerPlot = 1;
% % clcdPlots = 0;
% % means = 1;
% % animate = 1;
% % plotAll = 0;
% % 
% % % Plots
% % if errorSigsPlot == 1
% %     figure;
% %     subplot(1,3,1)
% %     tsc.velAngleAdjustedError.plot
% %     subplot(1,3,2)
% %     tsc.tanRollDes.plot
% %     deslims=ylim;
% %     subplot(1,3,3)
% %     tsc.tanRoll.plot
% %     ylim(deslims)
% % end
% % 
% % if velMagsPlot 
%     figure
%     vels=tsc.velocityVec.Data(:,:,:);%[(1-tsc.velocityVec.Data(1,1,:)); tsc.velocityVec.Data(2:3,1,:)];
%     velmags = sqrt(sum((vels).^2,1));
%     plot(tsc.velocityVec.Time, squeeze(velmags));
%     xlabel('time (s)')
%     ylabel('ground frame velocity (m)')
%     hold on
% end
% 
% if radialPosPlot 
%     figure
%     radialPos = sqrt(sum(tsc.positionVec.Data.^2,1));
%     plot(tsc.velocityVec.Time,squeeze(radialPos));
%     xlabel('time (s)')
%     ylabel('radial position/tether length (m)')
%     title("Radial Position")
% end
% 
% if tetherTenMagPlot
%     figure
%     plot(tsc.FThrNetBdy.Time,squeeze(sqrt(sum(tsc.FThrNetBdy.Data.^2,1))));
%     xlabel('time (s)')
%     ylabel('Tether Tension Magnitude on Body (N)')
%     title("Tether Tension")
% end
% 
% if alphaLocalPlot
%     figure
%     plot(tsc.alphaLocal.Time,squeeze(tsc.alphaLocal.Data(1,1,:)))
%     xlabel('time (s)')
%     ylabel('Alpha on the Left Wing')
% end
% 
% if clcdPlots
%     figure;
%     subplot(2,2,1)
%     drags=vhcl.aeroSurf1.CD.Value+vhcl.aeroSurf2.CD.Value+vhcl.aeroSurf3.CD.Value;
%     lifts=vhcl.aeroSurf1.CL.Value+vhcl.aeroSurf2.CL.Value+vhcl.aeroSurf3.CL.Value;
%     scatter(drags,lifts)
%     xlabel("C_D")
%     ylabel("C_L")
%     title("Vehicle C_L vs C_D")
% 
%     subplot(2,2,2)
%     scatter(vhcl.aeroSurf1.alpha.Value,lifts)
%     xlabel("Alpha (deg)")
%     ylabel("C_L")
%     title("Vehicle C_L vs Alpha")
% 
%     subplot(2,2,3)
%     scatter(vhcl.aeroSurf1.alpha.Value,drags)
%     xlabel("Alpha (deg)")
%     ylabel("C_D")
%     title("Vehicle C_D vs Alpha")
% 
%     subplot(2,2,4)
%     scatter(vhcl.aeroSurf1.alpha.Value,lifts./drags)
%     xlabel("Alpha (deg)")
%     ylabel('C_L / C_D')
%     title("Vehicle Lift to Drag Ratio vs alpha")
% 
%     sgtitle("Old file with Added Drag")
% end
% 
% if means
%     meanVelocity = mean(squeeze(velmags))
%     meanTension = mean(squeeze(sqrt(sum(tsc.FThrNetBdy.Data.^2,1))))
% end
% %%
% if powerPlot
%     figure
%     timevec=tsc.velAngleAdjustedError.Time;
%     ten=squeeze(sqrt(sum(tsc.FThrNetBdy.Data.^2,1)));
%      if max(tsc.winchSpeeds.Data)
%         plot(tsc.winchSpeeds.Time,tsc.winchSpeeds.Data.*ten)
%         xlabel('time (s)')
%         ylabel('Power (Watts)')
%             [~,i1]=min(abs(timevec - 30));
%             [~,i2]=min(abs(timevec - (duration_s/2)));
%             [~,poweri1]=min(tsc.winchSpeeds.Data(i1:i2).*ten(i1:i2));
%             poweri1 = poweri1 + i1;
%             [~,i3]=min(abs(timevec - (duration_s/2)));
%             [~,i4]=min(abs(timevec - 700));%duration_s));
%             [~,poweri2]=min(tsc.winchSpeeds.Data(i3:i4).*ten(i3:i4));
%             poweri2 = poweri2 + i3;
%             %Manual Override. Rerun with this to choose times
% %             t1 = input("time for first measurement");
% %             [~,poweri1]=min(abs(timevec - t1));
% %             t2 = input("time for second measurement");
% %             [~,poweri2]=min(abs(timevec - t2));
%         hold on
%         ylims=ylim;
%         plot([timevec(poweri1) timevec(poweri1)], [-1e6 1e6],'r--')
%         plot([timevec(poweri2) timevec(poweri2)], [-1e6 1e6],'r--')
%         ylim(ylims);
%         title(sprintf('Power vs Time; Average Power between lines = %4.2f Watts',mean(tsc.winchSpeeds.Data(poweri1:poweri2).*ten(poweri1:poweri2))));
%     else
%         plot(timevec,ten)
%         xlabel('time (s)')
%         ylabel('Tether Tension (Newtons)')
%         hold on
%         yyaxis right
%         plot(timevec,tsc.sStar.Data)
%         ylabel('SStar')
%     end
% end
% %% Animations/Plot Everything
% if plotAll
%     stopCallback
% end
% if animate
% %     animateSim
% pause(5)
     kiteAxesPlot
% end