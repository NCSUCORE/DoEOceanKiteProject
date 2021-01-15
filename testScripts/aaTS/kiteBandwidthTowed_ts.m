%% Test script for John to control the kite model
clear;clc;close all;
Simulink.sdi.clear
%%  Select sim scenario
%   0 = fig8;   1.a = fig8-2rot;   2.a = fig8-winch;   3.a = Steady   4.a = LaR

%%  Set Test Parameters
saveSim = 0;              %   Flag to save results
runLin = 1;                %   Flag to run linearization
thrArray = 20%:10:50;%[200:400:600];%:25:600];
altitudeArray = 10;%[100:200:300];%150:25:300];
flwSpd = 0.5;%[0.1:0.1:.5]; 
towSpdArray = -0.5%[0.5:.25:2.5];
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];
yaw = 0
flowDirPert = 0
time = [0 150 165 180 195 210 215 63300  633000];

angVel = [0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0;...
    %     0 0 0 0 0 0 0 0 0]';
    0 0 yaw/15*pi/180 0 0 0 0 0 0]';
spiral = 0;
flowAngle =[0 0 flowDirPert]; %degrees
flowDir = flowAngle*pi/180; % rotation direction of flow about body z degrees

for j = 1:length(thrArray)
    for k = 1:length(towSpdArray)
        Simulink.sdi.clear
thrLength = thrArray(j);  %altitude = altitudeArray(j);                 %   Initial tether length/operating altitude/elevation angle 
towSpd = towSpdArray(k) ;                                              %   m/s - Flow speed
vel = towSpd*[1 1 1 1 1 1 1 1 1;...
    0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0]';
Tmax = 38;                                                  %   kN - Max tether tension 
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
%%  Load components
fpath = fullfile(fileparts(which('OCTProject.prj')),...
    'vehicleDesign\Tether\Tension\');
maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
el = 30*pi/180;
loadComponent('slCtrl');                 %   Path-following controller with AoA control
loadComponent('prescribedGndStn001')                       %   Ground station controller
loadComponent('oneDoFGSCtrlBasic');                                 %   Ground station
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
loadComponent('constBoothLem');                              %   High level controller
hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
%%  Ground Station Properties
    gndStn.setVelVecTrajectory(vel,time,'m/s');
    gndStn.setAngVelTrajectory(angVel,time,'rad/s');
    gndStn.setInitPosVecGnd([-50 0 0],'m');
    gndStn.setInitEulAng([0 0 0]*pi/180,'rad')
%%  Vehicle Properties
    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.initPosVecGnd.Value,0);
    vhcl.setInitEulAng([0 0 0]*pi/180,'rad');
    vhcl.setInitVelVecBdy([towSpd 0 0],'m/s')
%%  Tethers Properties
load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
thr.tether1.initGndNodePos.setValue(gndStn.thrAttach.posVec.Value(:)+gndStn.initPosVecGnd.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tmax)),'Pa');
thr.tether1.density.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.density',Tmax)),'kg/m^3');
thr.tether1.setDiameter(eval(sprintf('AR8b8.length600.tensionValues%d.outerDiam',Tmax)),'m');
%%  Winches Properties
wnch.setTetherInitLength(vhcl,gndStn.initPosVecGnd.Value',env,thr,env.water.flowVec.Value);
wnch.winch1.LaRspeed.setValue(1,'m/s');
%%  Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,'');
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.initPosVecGnd.Value);
fltCtrl.rudderGain.setValue(0,'')
fltCtrl.elevatorReelInDef.setValue(3,'deg');
fltCtrl.LaRelevationSP.setValue(30,'deg');
vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
vhcl.turb1.setDiameter(.72,'m');     vhcl.turb2.setDiameter(.72,'m')
%%  Set up critical system parameters and run simulation
if runLin == 1
    simParams = SIM.simParams;  simParams.setDuration(2000,'s');  dynamicCalc = '';
    set_param('OCTModel','SimulationMode','accelerator');
    simWithMonitor('OCTModel')
    lo1 = logsout;
    tsc = signalcontainer(lo1);
    plotCtrlDeflections
    cPV = logsout.getElement('eul');
    tsnaps = cPV.Values.Time(end-500)';

    tic
%     io = getlinio('OCTModel');
    io(1) = linio('OCTModel/flightController',1,'output',[],...
        'azimuth');
    io(2) = linio('OCTModel/flightController',1,'output',[],...
        'elevation');
    io(3) = linio('OCTModel/environment',1,'input',[],...
        'velPrim');
    toc
    fprintf('Finding Operation Points')
    tic
    op = findop('OCTModel',tsnaps);
    toc
    % stateorder = {'y';'z';'roll';'pitch';'yaw';'u';'v';'w';'p';'q';'r'}
    options = linearizeOptions('IgnoreDiscreteStates','on');
    opts = bodeoptions('cstprefs');
    opts.PhaseVisible = 'off';
    opts.FreqUnits = 'Hz';
    opts.Grid = 'on';
    opts.Xlim = [0.05,5];
    op = update(op);
    tic
    linsys = linearize('OCTModel',io,op,options);
    toc

%%
    [mag,phase,wout] = bode(linsys,{0.001*2*pi 2*pi});
    magdb{j,k} = 20*log10(mag.*flwSpd);
    wHz{j,k} = wout/(2*pi);
    [p{j,k},z{j,k}] = pzmap(linsys);
end
    end
end
%%
h = figure; hold on;
    clear serNameCell
    ax = gca;
    offset = 0
    numEnt = size(magdb)
    a=hsv(numEnt(2));
    colororder(ax,a);
    colormap(ax,jet)
    markers = {'x','s','*','+'}
    for i = 1:numEnt(1)
        serName = sprintf('Tether Length = %d [m]',thrArray(i));
        for ii = 1:numEnt(2)
            serNameCell(i) = {serName};
            scatter(real(p{i,ii}),imag(p{i,ii}),[],ones(length(p{i,ii}),...
                1)*towSpdArray(ii),markers{i})

        end
    end

    h = colorbar;
    ylabel(h, 'Tow Speed [m]','Interpreter','latex')
%     scatter(real(p),imag(p))
    line(xlim(),[0,0],'Color',[.5 .5 .5])
    line([0,0],ylim(),'Color',[.5 .5 .5])
    xlabel('Real Axis [$s^{-1}$]')
    ylabel('Imaginary Axis [$s^{-1}$]')
        legend(serNameCell,'Location','northwest')
%     legend(serNameCell,'NumColumns',4','Location','NorthWest')



    
% h = figure
% ax = gca; colormap(ax,jet);
% scatter(snaps,pPlot,[],pPlot,'filled')
% h = colorbar;
% ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
% xlabel('Path Position')
% ylabel('Real Component of Slowest Pole [$s^{-1}$]')


% figure
% semilogy(snaps,1./pPlot,'kx')
% xlabel('Path Position')
% ylabel('Time Constants of Slowest Pole [s]')


    
    titleCellIn = {'Ground X Component','Ground Y Component','Ground Z Component'};
    titleCellOut = {' Position Angle [rad]'};
    subTitleCellIn = {'Frequency Response: Turbulence Intensity [$\%$]'};
    yLabelIn = 'Magnitude [dB]';
    xLabelIn = 'Frequency [Hz]';
   
   
    for i = 1:1%numEnt(1)
        h = figure('Units','inches','Position',[1 1 12 8])
        for q = 1:2 
        r = 1; c = 3;
        a=jet(9);
        ax1 = subplot(r,c,1); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{1});
        ax2 = subplot(r,c,2); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{2});
        ax3 = subplot(r,c,3); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{3});
        colororder(ax1,a); colororder(ax2,a); colororder(ax3,a);
        ax1.LineStyleOrder = {'-','--',':','-.'}; ax2.LineStyleOrder = {'-','--',':','-.'}; ax3.LineStyleOrder = {'-','--',':','-.'};
        set(ax1,'xscale','log'); set(ax2,'xscale','log');  set(ax3,'xscale','log');
        sgtitle({strcat(subTitleCellIn{1},' to ',titleCellOut{1},': Tether Length = 20 [m]'),'Solid Lines - Azimuth, Dashed Lines - Elevation'})
        for ii = 1:numEnt(2)
            serName = sprintf('$v_{tow}$= %.2f [m/s]',-towSpdArray(ii));
            serNameCell{ii} = serName;
            semilogx(ax1,wHz{i,ii},squeeze(magdb{i,ii}(q,1,:)),'DisplayName',serName);
            semilogx(ax2,wHz{i,ii},squeeze(magdb{i,ii}(q,2,:)),'DisplayName',serName);
            semilogx(ax3,wHz{i,ii},squeeze(magdb{i,ii}(q,3,:)),'DisplayName',serName);
            xlabel('Frequency [Hz]')
            ylabel('Magnitude [dB]')
        end
        legend(ax3,serNameCell,'Location','east','NumColumns',1)
    end
end  


%%  Log Results
distAmp = 0;
distFreq = 0;
pertVec = [1 0 0];
simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);
    Idx1 = find(tsc.azimuthAngle.Time > 6000,1,'first')
    Idx2 = find(tsc.azimuthAngle.Time > 6200,1,'first')
    ran = Idx1:Idx2-1;
    for i = 1:200-1
        ind(i)=find(tsc.elevationAngle.Time(ran) > 5999+i,1);
    end
    azBase = squeeze(tsc.azimuthAngle.Data(Idx1+ind));
    elBase = squeeze(tsc.elevationAngle.Data(Idx1+ind));
    timePlot = tsc.azimuthAngle.Time(Idx1+ind);
    figure
%     plot(pathVar,tanRollErrBase)
 
% distAmp = .1;
% distFreq = wHzPert;
% pertVec = [1 0 0];
% simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
% simWithMonitor('OCTModel')
% tsc1 = signalcontainer(logsout);  
% 
% distAmp = .1;
% distFreq = wHzPert;
% pertVec = [0 1 0];
% simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
% simWithMonitor('OCTModel')
% tsc2 = signalcontainer(logsout);  

distAmp = .1;
distFreq = .1;
pertVec = [0 0 1];
simParams = SIM.simParams;  simParams.setDuration(6500,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')
tsc2 = signalcontainer(logsout);    

    Idx1 = find(tsc2.azimuthAngle.Time > 6000,1,'first')
    Idx2 = find(tsc2.azimuthAngle.Time > 6200,1,'first')
    ran = Idx1:Idx2-1;
     for i = 1:200-1
        ind(i)=find(tsc2.elevationAngle.Time(ran) > 6000+i,1);
    end
    azErr = squeeze(tsc2.azimuthAngle.Data(Idx1+ind));
    elErr = squeeze(tsc2.elevationAngle.Data(Idx1+ind));
for ii = 1:2
    for i = 1:length(tsnaps)
        x(ii,i)=find(wHz{1,1} > distFreq,1);
        wHzPlot(ii,i)=wHz{1,1}(x(ii,i));
        magPlot(ii,i) = mag(ii,3,x(ii,i))*180/pi;
    end
end



figure; hold on;
plot(timePlot,elErr-elBase,'k--')
line(xlim(),[magPlot(2)*distAmp*flwSpd magPlot(2)*distAmp*flwSpd],'Color','r')
line(xlim(),-[magPlot(2)*distAmp*flwSpd magPlot(2)*distAmp*flwSpd],'Color','r')
xlabel('Time [s]')
ylabel('Residual Elevation Error [deg]')
legend('Residual Error','Predicted Error')

figure; hold on;
plot(timePlot,azErr-azBase,'k--')
ax = gca; colormap(ax,jet);
line(xlim(),[magPlot(1)*distAmp*flwSpd magPlot(1)*distAmp*flwSpd],'Color','r')
line(xlim(),-[magPlot(1)*distAmp*flwSpd magPlot(1)*distAmp*flwSpd],'Color','r')
xlabel('Time [s]')
ylabel('Residual Azimuth Angle [deg]')
legend('Residual Error','Predicted Error')

figure; hold on


subplot (2,1,1); hold on;
plot(timePlot,elErr)
plot(timePlot,elBase,'k')
ylabel('Error [rad]'); title('Elevation Angle [deg]')

subplot (2,1,2); hold on;
plot(timePlot,azErr)
plot(timePlot,azBase,'k')
ylabel('Error [rad]'); title('Elevation Angle [deg]'); xlabel('Time [s]')
% 
%     Pow = tsc.rotPowerSummary(vhcl,env);
%     [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
%     AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
%     airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
%     gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
%     ten = max([max(airNode(ran)) max(gndNode(ran))]);
%     fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);
% 
% dt = datestr(now,'mm-dd_HH-MM');


% simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
% simWithMonitor('OCTModel');
% tsc = signalcontainer(logsout);   
% lap = max(tsc.lapNumS.Data)-1;
% tsc.plotFlightError(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    filename = sprintf(strcat('V-%.3f_EL-%.1f_THR-%d.mat'),flwSpd,el*180/pi,thrLength);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'output','Manta\');
if saveSim == 1
    if max(tsc.lapNumS.Data) > 1
    save(strcat(fpath,filename),'vhcl','thr','fltCtrl','env','linsys','simParams','LIBRARY','gndStn','tsc','tsc1','tsc2','tsc3')
    end
end
%%  Plot Results
    lap = max(tsc.lapNumS.Data)-1;
    if max(tsc.lapNumS.Data) < 2
        tsc.plotFlightResults(vhcl,env,'plot1Lap',1==0,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    else
        tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
        tsc.plotFlightError(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
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
    vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',20,...
        'GifTimeStep',.00001,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
        'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'),...
        'startTime',5000);
% else
    vhcl.animateSim(tsc,2,'View',[90,0],'Pause',1==0,...
        'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==0);
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