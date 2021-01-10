%% Test script for John to control the kite model
clear;clc;close all;
Simulink.sdi.clear
%%  Select sim scenario
%   0 = fig8;   1.a = fig8-2rot;   2.a = fig8-winch;   3.a = Steady   4.a = LaR

%%  Set Test Parameters
saveSim = 0;                                                %   Flag to save results
thrLength = 400;  altitude = 200;  elev = 30;               %   Initial tether length/operating altitude/elevation angle 
flwSpd = .3;                                                %   m/s - Flow speed
Tmax = 38;                                                  %   kN - Max tether tension 
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
%%  Load components
fpath = fullfile(fileparts(which('OCTProject.prj')),...
    'vehicleDesign\Tether\Tension\');
maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
el = asin(altitude/thrLength);
loadComponent('pathFollowWithAoACtrl');                 %   Path-following controller with AoA control
FLIGHTCONTROLLER = 'pathFollowingControllerMantaBandLin';
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
loadComponent('MantaGndStn');                               %   Ground station
loadComponent('winchManta');                                %   Winches
loadComponent('MantaTether');                           %   Manta Ray tether
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
loadComponent('Manta2RotXFoil_AR8_b8');                             %   AR = 8; 8m span
SIXDOFDYNAMICS = 'sixDoFDynamicsCoupledFossen12Int';
VEHICLE = 'vehicleManta2RotBandLin';
%%  Environment Properties
loadComponent('ConstXYZT');                                 %   Environment
env.water.setflowVec([flwSpd 0 0],'m/s');               %   m/s - Flow speed vector
    ENVIRONMENT = 'environmentManta2RotBandLin';                   %   Two turbines
%%  Set basis parameters for high level controller
loadComponent('varAltitudeBooth');                          %   High level controller
hiLvlCtrl.elevationLookup.setValue(maxT.R.EL,'deg');

hiLvlCtrl.ELctrl.setValue(1,'');
hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
hiLvlCtrl.ThrCtrl.setValue(1,'');

hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
%%  Ground Station Properties
%%  Vehicle Properties
vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,6.5*flwSpd*norm([1;0;0]))

%%  Tethers Properties
load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tmax)),'Pa');
thr.tether1.density.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.density',Tmax)),'kg/m^3');
thr.tether1.setDiameter(eval(sprintf('AR8b8.length600.tensionValues%d.outerDiam',Tmax)),'m');
%%  Winches Properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.LaRspeed.setValue(1,'m/s');
%%  Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,'');
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
fltCtrl.rudderGain.setValue(0,'')
fltCtrl.elevatorReelInDef.setValue(3,'deg');
fltCtrl.AoACtrl.setValue(1,'');                     fltCtrl.RCtrl.setValue(0,'');
fltCtrl.AoASP.setValue(1,'');                       fltCtrl.AoAConst.setValue(vhcl.optAlpha.Value*pi/180,'deg');
fltCtrl.alphaCtrl.kp.setValue(.3,'(kN)/(rad)');     fltCtrl.Tmax.setValue(Tmax,'kN');
fltCtrl.elevCtrl.kp.setValue(125,'(deg)/(rad)');    fltCtrl.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
fltCtrl.rollCtrl.kp.setValue(200,'(deg)/(rad)');    fltCtrl.rollCtrl.ki.setValue(1,'(deg)/(rad*s)');
fltCtrl.firstSpoolLap.setValue(10,'');              fltCtrl.winchSpeedIn.setValue(.1,'m/s');
fltCtrl.elevCtrlMax.upperLimit.setValue(8,'');      fltCtrl.elevCtrlMax.lowerLimit.setValue(0,'');
vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
% vhcl.turb1.setDiameter(.72,'m');     vhcl.turb2.setDiameter(.72,'m')
%%  Set up critical system parameters and run simulation
simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')
snaps = 0.05:0.1:0.95;
for i = 1 : length(snaps)
    x(i) = find(logsout{12}.Values.Data >= snaps(i)-.01 & logsout{12}.Values.Data <= snaps(i)+0.01, 1, 'last');
end
tsnaps = logsout{12}.Values.Time(x);
io = getlinio('OCTModel');
op = findop('OCTModel',tsnaps);
% stateorder = {'y';'z';'roll';'pitch';'yaw';'u';'v';'w';'p';'q';'r'}
options = linearizeOptions('IgnoreDiscreteStates','on');
opts = bodeoptions('cstprefs');
opts.PhaseVisible = 'off';
opts.FreqUnits = 'Hz';
opts.Grid = 'on';
opts.Xlim = [0.05,5];
dispName = {};
for i = 1:length(snaps)
    dispName{i} = sprintf('Path Parameter = %.2f',snaps(i));
end
magdb = cell(4,4,length(snaps)); wHz = cell(4,4,length(snaps))
for i = 1:4
    for ii = 1:4
        for iii = 1:length(snaps)
            tic
            linsys = linearize('OCTModel',[io(i) io(4+ii)],op(iii),options);
            [mag,phase,wout] = bode(linsys,{0.001*2*pi 2*pi});
            magdb{i,ii,iii} = 20*log10(mag*[flwSpd 1 1]);
            wHz{i,ii,iii} = wout/(2*pi);
            toc
        end
    end
end
titleCellIn = {' Horizontal Stabilizer',' Port Wing',...
    ' Starboard Wing',' Vertical Stabilizer'};
titleCellOut = {' Side Slip Error',' Central Angle Error',...
    ' Tangent Roll Error',' Velocity Angle Error'};
subTitleCellIn = {' Normalized Velocity Magnitude',' Angle of Attack',' Side Slip Angle'};
yLabelIn = 'Magnitude [dB]';
xLabelIn = 'Frequency [Hz]';
for i = 1:4
    for ii = 1:4
        figure
        sgtitle({strcat('Frequency Response:',titleCellIn{i},' local flow disturbance'),...
            strcat(' to ',titleCellOut{ii})})
        for iii = 1:length(snaps)
            if iii <= 7
                serName = sprintf('Path Parameter = %.2f',snaps(iii));
                subplot(1,3,1); xlabel(xLabelIn); ylabel(yLabelIn);
                title(subTitleCellIn{1})
                semilogx(wHz{i,ii,iii},squeeze(magdb{i,ii,iii}(:,1,:))); hold on;
                subplot(1,3,2); xlabel(xLabelIn); ylabel(yLabelIn);
                title(subTitleCellIn{2})
                semilogx(wHz{i,ii,iii},squeeze(magdb{i,ii,iii}(:,2,:))); hold on;
                subplot(1,3,3); xlabel(xLabelIn); ylabel(yLabelIn);
                title(subTitleCellIn{3})
                semilogx(wHz{i,ii,iii},squeeze(magdb{i,ii,iii}(:,3,:)),'DisplayName',serName); hold on;
            else
                serName = sprintf('Path Parameter = %.2f',snaps(iii));
                subplot(1,3,1)
                semilogx(wHz{i,ii,iii},squeeze(magdb{i,ii,iii}(:,1,:)),'--','DisplayName',serName);hold on;
                subplot(1,3,2)
                semilogx(wHz{i,ii,iii},squeeze(magdb{i,ii,iii}(:,2,:)),'--');hold on;
                subplot(1,3,3)
                semilogx(wHz{i,ii,iii},squeeze(magdb{i,ii,iii}(:,3,:)),'--','DisplayName',serName);hold on;
            end
            legend
            xlabel('Frequency [Hz]')
            ylabel('Magnitude [dB]')
        end
    end
end

for i = 1:3
    for ii = 1:4
        figure
        sgtitle({strcat('Frequency Response: Local ',subTitleCellIn{i},' disturbance'),...
            strcat(' to ',titleCellOut{ii})})
        for iii = 1:length(snaps)
            if iii <= 7
                serName = sprintf('Path Parameter = %.2f',snaps(iii));
                subplot(1,4,3); xlabel(xLabelIn); ylabel(yLabelIn);
                title(titleCellIn{1})
                semilogx(wHz{1,ii,iii},squeeze(magdb{1,ii,iii}(:,i,:))); hold on;
                subplot(1,4,1); xlabel(xLabelIn); ylabel(yLabelIn);
                title(titleCellIn{2})
                semilogx(wHz{2,ii,iii},squeeze(magdb{2,ii,iii}(:,i,:))); hold on;
                subplot(1,4,2); xlabel(xLabelIn); ylabel(yLabelIn);
                title(titleCellIn{3})
                semilogx(wHz{3,ii,iii},squeeze(magdb{3,ii,iii}(:,i,:))); hold on;
                subplot(1,4,4); xlabel(xLabelIn); ylabel(yLabelIn);
                title(titleCellIn{4})
                semilogx(wHz{4,ii,iii},squeeze(magdb{4,ii,iii}(:,i,:)),'DisplayName',serName); hold on;
            else
                serName = sprintf('Path Parameter = %.2f',snaps(iii));
                subplot(1,4,3); xlabel(xLabelIn); ylabel(yLabelIn);
                title(titleCellIn{1})
                semilogx(wHz{1,ii,iii},squeeze(magdb{1,ii,iii}(:,i,:)),'--'); hold on;
                subplot(1,4,1); xlabel(xLabelIn); ylabel(yLabelIn);
                title(titleCellIn{2})
                semilogx(wHz{2,ii,iii},squeeze(magdb{2,ii,iii}(:,i,:)),'--'); hold on;
                subplot(1,4,2); xlabel(xLabelIn); ylabel(yLabelIn);
                title(titleCellIn{3})
                semilogx(wHz{3,ii,iii},squeeze(magdb{3,ii,iii}(:,i,:)),'--'); hold on;
                subplot(1,4,4); xlabel(xLabelIn); ylabel(yLabelIn);
                title(titleCellIn{4})
                semilogx(wHz{4,ii,iii},squeeze(magdb{4,ii,iii}(:,i,:)),'--','DisplayName',serName); hold on;
            end
            legend
            xlabel('Frequency [Hz]')
            ylabel('Magnitude [dB]')
        end
    end
end

tsc = signalcontainer(logsout);
%%  Log Results
tsc = signalcontainer(logsout);

    Pow = tsc.rotPowerSummary(vhcl,env);
    [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
    AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
    airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
    gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
    ten = max([max(airNode(ran)) max(gndNode(ran))]);
    fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);

dt = datestr(now,'mm-dd_HH-MM');

%     filename = sprintf(strcat('Turb%.1f_V-%.3f_EL-%.1f_D-%.2f_Tmax-%d.mat'),simScenario,flwSpd,mean(tsc.basisParams.Data(3,:,:))*180/pi,vhcl.turb1.diameter.Value,Tmax);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor\');
if saveSim == 1
    save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
end
%%  Plot Results
    lap = max(tsc.lapNumS.Data)-1;
    if max(tsc.lapNumS.Data) < 2
        tsc.plotFlightResults(vhcl,env,'plot1Lap',1==0,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    else
        tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    end
%%
% figure(23); 
% [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2-1;
% data = squeeze(tsc.currentPathVar.Data);
% subplot(2,1,1); hold on; grid on;
% plot(data(ran),squeeze(tsc.tanRollDes.Data(:,:,ran)),'r-')
% xlabel('Path Position'); ylabel('Tan Roll Des [deg]');
% subplot(2,1,2); hold on; grid on;
% plot(data(ran),squeeze(tsc.ctrlSurfDeflCmd.Data(ran,1)),'r-')
% xlabel('Path Position'); ylabel('Port Aileron [deg]');
%%
% figure; subplot(1,3,1); hold on; grid on;
% plot(tsc.basisParams.Time,squeeze(tsc.basisParams.Data(3,:,:))*180/pi,'r-'); xlabel('Time [s]'); ylabel('Elevation [deg]');
% plot(tsc.elevationAngle.Time,squeeze(tsc.elevationAngle.Data),'b-'); xlabel('Time [s]'); ylabel('Elevation [deg]');
% legend('Setpoint','Actual','location','northwest')
% subplot(1,3,2); hold on; grid on;
% plot(tsc.tetherLengths.Time,squeeze(tsc.tetherLengths.Data),'b-'); xlabel('Time [s]'); ylabel('Tether Length [m]');
% subplot(1,3,3); hold on; grid on;
% plot(tsc.positionVec.Time,squeeze(tsc.positionVec.Data(3,1,:)),'b-'); xlabel('Time [s]'); ylabel('Altitude [m]');
%%  Animate Simulation
% if simScenario <= 2
%     vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',20,...
%         'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
%         'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'));
% else
%     vhcl.animateSim(tsc,2,'View',[0,0],'Pause',1==0,...
%         'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==0,...
%         'SaveGif',1==1,'GifFile',strrep(filename,'.mat','zoom.gif'));
% end
%%  Compare to old results
% Res = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\Results\Manta 2.0\Rotor\Turb1.0_V-0.300_EL-30.0_D-0.70_AoA-13.98_10-22_12-29.mat');
% Res.tsc.rotPowerSummary(Res.vhcl,Res.env);
% [Idx1,Idx2] = Res.tsc.getLapIdxs(max(Res.tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
% AoA = mean(squeeze(Res.tsc.vhclAngleOfAttack.Data(:,:,ran)));
% airNode = squeeze(sqrt(sum(Res.tsc.airTenVecs.Data.^2,1)))*1e-3;
% gndNode = squeeze(sqrt(sum(Res.tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
% ten = max([max(airNode(ran)) max(gndNode(ran))]);
% fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n',AoA,ten);