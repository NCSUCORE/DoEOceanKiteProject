clc 
clear all
close all

h = 20*pi/180;  w = 80*pi/180; elInit = 50*pi/180                             %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
loadComponent('constBoothLem');        %   High level controller
loadComponent('pathFollowCtrlExp');                         %   Path-following controller with AoA control
FLIGHTCONTROLLER = 'pathFollowingControllerExp';
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller                           %   Ground station
loadComponent('raftGroundStation');
loadComponent('winchManta');                                %   Winches
loadComponent('MantaTether');                               %   Manta Ray tether
loadComponent('realisticSensors');                             %   Sensors
loadComponent('lineAngleSensor');
loadComponent('idealSensorProcessing');                      %   Sensor processing
loadComponent('poolScaleKiteAbney');                %   AR = 8; 8m span
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen12int";
loadComponent('ConstXYZT');                                 %   Environment

direc = 'G:\Shared drives\Kite Experimentation\Pool testing\Friday Pool Test\06 16 21\Data';
listing =  dir(direc) ;
towSpeed = 0.77;
runs = [9];
runQuery = min(runs);
runCount = min(runs);
runLim = max(runs);
i = 1;
j = 1;
while runCount <= runLim
    if listing(j).isdir ~= 1
        load(strcat(direc,'\',listing(j).name));
    else
        j = j+1;
        continue
    end
    
    ind = find(tsc.runCounter.Data == runCount,1);
    if isempty(ind)
        j = j+1;
        continue
    end
    runStart = find(tsc.rollSP.Data(ind:end) > 0 , 1)+ind;
    if isempty(runStart)
        j=j+1;
        continue
    end
        
    T = tsc.winch1LinPos.Time(runStart);
    runData = reSampleDataUsingTime(tsc,T,T+30);
    i = i+1;
    if i > numel(runs)
        break
    end
    runCount = runs(i);
    ind = [];
    runStart = [];
end

T = runData.kite_azi.Time;
el = squeeze(runData.kite_elev.Data);
az = squeeze(runData.kite_azi.Data);

pos = 2.63*[-cosd(az).*cosd(el)+towSpeed/2.63*T...
    sind(az).*cosd(el)...
    sind(el)];

runData.posVec = timeseries(pos,T);
eul = [runData.kiteRoll.Data runData.kitePitch.Data runData.kiteYaw.Data]*pi/180;
runData.eulAngle = timeseries(eul,T);
angRate = [runData.kiteRollRate.Data runData.kitePitchRate.Data runData.kiteYawRate.Data]*pi/180;
% roll = squeeze(eul(:,1,:));
% pitch = squeeze(eul(:,2,:));
% yaw = squeeze(eul(:,3,:));
n = numel(T);
% omegaMat(1,1,:) = sin(pitch).* sin(roll);
% omegaMat(1,2,:) = cos(roll);
% omegaMat(1,3,:) = zeros(1,1,n);
% omegaMat(2,1,:) = sin(pitch).*cos(roll);
% omegaMat(2,2,:) = -sin(roll);
% omegaMat(2,3,:) = zeros(1,1,n);
% omegaMat(3,1,:) = cos(pitch);
% omegaMat(3,2,:) = zeros(1,1,n);
% omegaMat(3,3,:) = ones(1,1,n);
% 
% for i = 1:n
%     omega(1,:,i) = omegaMat(:,:,i)*angRate(:,:,i)';
% end
runData.angVelVec = timeseries(angRate,T);

basisParams = [ones(1,1,n)*a ,ones(1,1,n)*b,ones(1,1,n)*elInit,ones(1,1,n)*180*pi/180,ones(1,1,n)*2.63];
runData.basisParams = timeseries(basisParams,T);

sim('testHierCtrl')
tsc = signalcontainer(ans.logsout)

figure('Position',[100 100 800 400])
hold on; grid on;
plot(tsc.velAngleError*180/pi)
xlabel 'Time [s]'
ylabel 'Velocity Angle Error [deg]'

figure('Position',[100 100 800 400])
hold on; grid on;
plot(tsc.tanRollDes*180/pi)
xlabel 'Time [s]'
ylabel 'Desired Tangent Roll Angle [deg]'

figure('Position',[100 100 800 400])
hold on; grid on;
plot(tsc.centralAngle*180/pi)
xlabel 'Time [s]'
ylabel 'Central Angle [deg]'

figure('Position',[100 100 800 400])
hold on; grid on;
plot(tsc.ctrlSurfDefl)
xlabel 'Time [s]'
ylabel 'Control Surface Commands [deg]'

figure('Position',[100 100 800 400])
hold on; grid on;
plot(tsc.desiredMoment)
xlabel 'Time [s]'
ylabel 'Desired Moments [N-m]'

figure('Position',[100 100 800 400])
hold on; grid on;
plot(tsc.closestPathVariable)
xlabel 'Time [s]'
ylabel 'Path Parameter'

figure('Position',[100 100 800 400])
hold on; grid on;
plot(runData.kite_azi.Data,runData.kite_elev.Data,...
    'DisplayName','Experimental Path')
plotsq(tsc.pathAz.Data,tsc.pathEl.Data,'DisplayName','Path Geometry')
xlabel 'Azimuth Angle [deg]'
ylabel 'Elevation Angle [deg]'
legend
set(gca,'FontSize',15)

figure('Position',[100 100 800 400])
hold on; grid on;
% plot(runData.kite_azi.Data,tsc.tanRoll.Data*180/pi,...
%     'DisplayName','')
plotsq(tsc.eul.Data(1,:,:)*180/pi,tsc.tanRoll.Data*180/pi,'DisplayName','Path Geometry')
xlabel 'Roll Angle [deg]'
ylabel 'Tan Roll Angle [deg]'
legend
set(gca,'FontSize',15)
