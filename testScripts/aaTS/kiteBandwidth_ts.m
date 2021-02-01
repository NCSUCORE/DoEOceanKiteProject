%% Test script for John to control the kite model
clear;clc;%close all;
Simulink.sdi.clear
%%  Select sim scenario
%   0 = fig8;   1.a = fig8-2rot;   2.a = fig8-winch;   3.a = Steady   4.a = LaR

%%  Set Test Parameters
saveSim = 0;              %   Flag to save results
runLin = 0;                %   Flag to run linearization
thrArray = 400;%[200:400:600];%:25:600];
altitudeArray = 200;%[100:200:300];%150:25:300];
flwSpdArray = 0.5;%[0.1:0.1:.5]; 
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];
for j = 1:length(thrArray)
    for k = 1:length(flwSpdArray)
thrLength = thrArray(j);  altitude = altitudeArray(j);  elev = atan2(altitude,thrLength);               %   Initial tether length/operating altitude/elevation angle 
flwSpd = flwSpdArray(k) ;                                              %   m/s - Flow speed
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
loadComponent('varAltitudeBooth');                             %   High level controller
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
fltCtrl.firstSpoolLap.setValue(100,'');              fltCtrl.winchSpeedIn.setValue(.1,'m/s');
fltCtrl.elevCtrlMax.upperLimit.setValue(8,'');      fltCtrl.elevCtrlMax.lowerLimit.setValue(0,'');
vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
% fltCtrl.setPerpErrorVal(.0,'rad')
% vhcl.turb1.setDiameter(.72,'m');     vhcl.turb2.setDiameter(.72,'m')
% vhcl.setMa6x6_LE(zeros(6),'')
%%  Set up critical system parameters and run simulation
if runLin == 1
    simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
    set_param('OCTModel','SimulationMode','accelerator');
    simWithMonitor('OCTModel')

    %%
    snaps = 0.025:0.025:0.975;
    cPV = logsout.getElement('closestPathVariable');
    tic
    x = zeros(length(snaps),1);
    for i = 1 : length(snaps)
        x(i) = find(cPV.Values.Data >= snaps(i)-.001 & cPV.Values.Data <= snaps(i)+0.001, 1, 'last');
    end
    toc
    tsnaps = cPV.Values.Time(x)';


    io(1) = linio('OCTModel/flightController',1,'output',[],...
        'betaErr');
    io(2) = linio('OCTModel/flightController',1,'output',[],...
        'centralAngle');
    io(3) = linio('OCTModel/flightController',1,'output',[],...
        'tanRollErr');
    io(4) = linio('OCTModel/flightController',1,'output',[],...
        'velAngleErr');
    io(5) = linio('OCTModel/environment',1,'input',[],...
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
    dispName = cell(length(snaps),1);
    tic
    linsys = linearize('OCTModel',io,op,options);
    toc
    %%tic
    %%
        snaps = 0.025:0.025:0.975;

    for i = 1:length(snaps)
        dispName{i} = sprintf('Path Parameter = %.2f',snaps(i));
    end
    magdb = cell(4,1,length(snaps)); wHz = cell(4,1,length(snaps));
    mag = cell(4,1,length(snaps));
    for i = 1:4
        for ii = 1
            for iii = 1:length(snaps)
                [mag{i,ii,iii},phase,wout] = bode(linsys(i,3*(ii-1)+[1:3],iii,:),{0.001*2*pi 2*pi});
                magdb{i,ii,iii} = 20*log10(mag{i,ii,iii}.*flwSpd);
                wHz{i,ii,iii} = wout/(2*pi);
%                 a(i,ii,iii) = find(mag{i,ii,iii}(:,2,:)==max(mag{i,ii,iii}(:,2,:)));
%                 magPertMat(i,ii,iii) = mag{i,ii,iii}(:,2,a(i,ii,iii))
%                 wHzPertMat(i,ii,iii) = wHz{i,ii,iii}(a(i,ii,iii));
%                 toc
            end
        end
    end
    
    for i = 1:length(a)
%     wHzPert(i) = wHzPertMat(r(i),c(i),:)
    end
    %%
    
    h = figure; hold on;
    clear serNameCell
    ax = gca;
    offset = 0
    numEnt = ceil(length(snaps))
    a=hsv(numEnt);
    colororder(ax,a);
    colormap(ax,jet)
    for i = 1:numEnt
        serName = sprintf('s = %.3f',snaps(i+offset));
        serNameCell(i) = {serName};
        [p{:,i}.pole,z] = pzmap(linsys(:,:,i+offset,:));
        clear z
        scatter(real(p{:,i}.pole),imag(p{:,i}.pole),[],ones(length(p{:,i}.pole),1)*snaps(i),'x')
    end
    h = colorbar;
    ylabel(h, 'Path Parameter','Interpreter','latex')
%     scatter(real(p),imag(p))
    line(xlim(),[0,0],'Color',[.5 .5 .5])
    line([0,0],ylim(),'Color',[.5 .5 .5])
    xlabel('Real Axis [$s^{-1}$]')
    ylabel('Imaginary Axis [$s^{-1}$]')
%     legend(serNameCell,'NumColumns',4','Location','NorthWest')


for i =1:length(snaps)
    pPlot(i) = max(real(p{:,i}.pole));
end
    
h = figure
ax = gca; colormap(ax,jet);
scatter(snaps,pPlot,[],pPlot,'filled')
h = colorbar;

ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
xlabel('Path Position')
ylabel('Real Component of Slowest Pole [$s^{-1}$]')


% figure
% semilogy(snaps,1./pPlot,'kx')
% xlabel('Path Position')
% ylabel('Time Constants of Slowest Pole [s]')

%%
    snaps = 0.025:0.025:0.975;
    titleCellIn = {'Ground X Component','Ground Y Component','Ground Z Component'};
    titleCellOut = {' Side Slip Error [rad]',' Central Angle Error [rad]',...
        ' Tangent Roll Error [rad]',' Velocity Angle Error [rad]'};
    subTitleCellIn = {'Frequency Response: Turbulence Intensity [$\%$]'};;
    yLabelIn = 'Magnitude [dB]';
    xLabelIn = 'Frequency [Hz]';
       
    for i = 1:4
        for ii = 1:1
            h = figure('Units','inches','Position',[1 1 12 8])
            r = 1; c = 3;
            a=lines(5);
            ax1 =subplot(r,c,1); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{1});
            ax2 = subplot(r,c,2); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{2});
            ax3 = subplot(r,c,3); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{3});
            colororder(ax1,a); colororder(ax2,a); colororder(ax3,a);
            ax1.LineStyleOrder = {'-','--',':'}; ax2.LineStyleOrder = {'-','--',':'}; ax3.LineStyleOrder = {'-','--',':'};
            set(ax1,'xscale','log'); set(ax2,'xscale','log');  set(ax3,'xscale','log');
            sgtitle({strcat('Frequency Response: ',subTitleCellIn{ii},' disturbance'),...
                strcat(' to ',titleCellOut{i})})
            for iii = [1:4:18]%:length(snaps)
                    serName = sprintf('s = %.3f',snaps(iii));
                    semilogx(ax1,wHz{i,1,iii},squeeze(magdb{i,1,iii}(:,1,:)));
                    semilogx(ax2,wHz{i,1,iii},squeeze(magdb{i,1,iii}(:,2,:)),'DisplayName',serName);
                    semilogx(ax3,wHz{i,1,iii},squeeze(magdb{i,1,iii}(:,3,:)),'DisplayName',serName);
                legend(ax2,'Location','southwest','NumColumns',2)
                xlabel('Frequency [Hz]')
                ylabel('Magnitude [dB]')
            end
        end
    end
end

%%  Log Results
distAmp = 0;
distFreq = 0;
pertVec = [1 0 0];
simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);
% distAmp = .25;
% distFreq = .1866;
% pertVec = [1 0 0];
% simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
% simWithMonitor('OCTModel')
% tsc1 = signalcontainer(logsout);  
% 
% distAmp = .1;
% distFreq = .12;
% pertVec = [0 1 0];
% simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
% simWithMonitor('OCTModel')
% tsc2 = signalcontainer(logsout);  

% distAmp = .25;
% distFreq = .18662;
% pertVec = [0 0 1];
% simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
% simWithMonitor('OCTModel')
% tsc2 = signalcontainer(logsout);    
%%
lap = max(tsc.lapNumS.Data)-1;
tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    [Idx1,Idx2] = getLapIdxs(tsc,lap);
    ran = Idx1:Idx2-1;
    for i = 1:1000-2
        ind(i)=find(tsc.closestPathVariable.Data(ran) > i/1000,1);
    end
        tanRoll = squeeze(tsc.tanRollDes.Data(Idx1+ind));
    tanRollErrBase = squeeze(tsc.tanRollError.Data(Idx1+ind));
    cenAngleErrBase = squeeze(tsc.centralAngle.Data(Idx1+ind));
    betaErrBase = squeeze(tsc.betaErr.Data(Idx1+ind));
    velAngErrBase = squeeze(tsc.velAngleError.Data(Idx1+ind));
    pathVar = tsc.closestPathVariable.Data(Idx1+ind);
    figure
    plot(pathVar,tanRoll*180/pi)
 


    lap = max(tsc2.lapNumS.Data)-2;
    [Idx1,Idx2] = getLapIdxs(tsc2,lap);
    ran = Idx1:Idx2-1;
    for i = 1:1000-2
        ind(i)=find(tsc2.closestPathVariable.Data(ran) > i/1000,1);
    end
    tanRollErr = squeeze(tsc2.tanRollError.Data(Idx1+ind));
    cenAngleErr = squeeze(tsc2.centralAngle.Data(Idx1+ind));
    betaErr = squeeze(tsc2.betaErr.Data(Idx1+ind));
    velAngErr = squeeze(tsc2.velAngleError.Data(Idx1+ind));
for ii = 1:4
    for i = 1:length(snaps)
        x(ii,i)=find(wHz{ii,1,i} > distFreq,1);
        wHzPlot(ii,i)=wHz{ii,1,i}(x(ii,i))
        magPlot(ii,i,:) = mag{ii,1,i}(1,:,x(ii,i));
    end
end

figure; hold on;
ax = gca;
plot(pathVar,betaErr-betaErrBase)
if runLin == 1
    ax = gca; colormap(ax,jet);
    scatter(snaps,magPlot(1,:,2)*distAmp*flwSpd,[],pPlot,'filled')
    scatter(snaps,-magPlot(1,:,2)*distAmp*flwSpd,[],pPlot,'filled')
    h = colorbar;
    ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
end
xlabel('Path Position')
ylabel('Residual Side Slip [rad]')
legend('Residual Error','Predicted Error')

figure; hold on;
plot(pathVar,cenAngleErr-cenAngleErrBase)
if runLin == 1
    ax = gca; colormap(ax,jet);
    scatter(snaps,magPlot(2,:,2)*distAmp*flwSpd,[],pPlot,'filled')
    scatter(snaps,-magPlot(2,:,2)*distAmp*flwSpd,[],pPlot,'filled')
    h = colorbar;
    ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
end
xlabel('Path Position')
ylabel('Residual Central Angle Error [rad]')
legend('Residual Error','Predicted Error')

figure; hold on;
plot(pathVar,tanRollErr-tanRollErrBase,'k--')
if runLin == 1
    ax = gca; colormap(ax,jet);
    scatter(snaps,magPlot(3,:,2)*distAmp*flwSpd,[],pPlot,'filled')
    scatter(snaps,-magPlot(3,:,2)*distAmp*flwSpd,[],pPlot,'filled')
    h = colorbar;
    ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
end
xlabel('Path Position')
ylabel('Residual Tangent Roll Error [rad]')
legend('Residual Error','Predicted Error')

figure; hold on

plot(pathVar,velAngErr-velAngErrBase,'k--')
if runLin == 1
    ax = gca; colormap(ax,jet);
    plot(snaps,magPlot(4,:,2)*distAmp*flwSpd,'ob','MarkerFaceColor','b')
    plot(snaps,-magPlot(4,:,2)*distAmp*flwSpd,'ob','MarkerFaceColor','b')
%     h = colorbar;
%     ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
end
xlabel('Path Position')
ylabel('Residual Velocity Angle Error [rad]')
legend('Residual Error','Predicted Error')

figure; hold on;
subplot (2,2,1); hold on;
plot(pathVar,betaErr)
plot(pathVar,betaErrBase,'k')
ylabel('Error [rad]'); title('Side Slip Error')

subplot (2,2,2); hold on;
plot(pathVar,cenAngleErr)
plot(pathVar,cenAngleErrBase,'k')
ylabel('Error [rad]'); title('Central Angle Error')

subplot (2,2,3); hold on;
plot(pathVar,tanRollErr)
plot(pathVar,tanRollErrBase,'k')
ylabel('Error [rad]'); title('Tangent Roll Angle Error'); xlabel('Path Position')

subplot (2,2,4); hold on;
plot(pathVar,velAngErr)
plot(pathVar,velAngErrBase,'k')
ylabel('Error [rad]'); title('Velocity Angle Error'); xlabel('Path Position')
legend('Base Case','Perturbed Flow')
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
%%

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
    vhcl.animateSim(tsc,2,'Pause',1==1,'PathFunc',fltCtrl.fcnName.Value,...
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
