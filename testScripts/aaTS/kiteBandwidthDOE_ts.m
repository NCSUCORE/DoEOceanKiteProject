clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(1050,'s');
dynamicCalc = '';
Simulink.sdi.clear
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];
<<<<<<< Updated upstream
<<<<<<< Updated upstream
flwSpd = -1
=======
flwSpd = .7
>>>>>>> Stashed changes
=======
flwSpd = 1
>>>>>>> Stashed changes
%% Load components
% Flight Controller
% loadComponent('pathFollowingCtrlAddedMass');
loadComponent('pathFollowingCtrlForILC');
fltCtrl.rudderGain.setValue(-1,'')
% SPOOLINGCONTROLLER = 'netZeroSpoolingControllerEllipsePath';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';
fltCtrl.firstSpoolLap.setValue(100,'')
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
% loadComponent('constEllipse');
loadComponent('constBoothLem');
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Sensors
loadComponent('idealSensors')
% Sensor processing
loadComponent('idealSensorProcessing')
% Vehicle
loadComponent('fullScale1thr');
VEHICLE = "vhcl2turbLinearize";
PLANT = "plant2turb";
WINCH = "constThr"
% loadComponent('pathFollowingVhclForComp')
% loadComponent('sensitivityAnalysis');              %   Load vehicle

% Environment
% loadComponent('CNAPsNoTurbJosh');
% loadComponent('CNAPsTurbJames');
% loadComponent('CNAPsTurbMitchell');
loadComponent('ConstXYZT');

%% Environment IC's and dependant properties
env.water.setflowVec([flwSpd 0 0],'m/s')
<<<<<<< Updated upstream
% w = 100*pi/180; h = 30*pi/180;
% [a,b] = boothParamConversion(w,h)
%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([1,1.4,30*pi/180,0,125],'[rad rad rad rad m]') % Lemniscate of Booth
% hiLvlCtrl.basisParams.setValue([a,b,-30*pi/180,180*pi/180,150],'[rad rad rad rad m]') % Lemniscate of Booth
=======
w = 40*pi/180; h = 20*pi/180;
PATHGEOMETRY = 'lemBoothNew'
w = 40*pi/180*150;
h = h*150;
% [w,h] = boothParamConversion(w,h)  
%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
% hiLvlCtrl.basisParams.setValue([1,1.4,-30*pi/180,180*pi/180,150],'[rad rad rad rad m]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([w,h,30*pi/180,0,150],'[rad rad rad rad m]') % Lemniscate of Booth
>>>>>>> Stashed changes
%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0.05,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... % Center point of path sphere
    (11/2)*norm([ 1 0 0 ])) % Initial speed

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
% thr.tether1.setYoungsMod(20e10,'Pa')
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
% thr.setNumNodes(8,'')
%% Winches IC's and dependant properties
% wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.initLength.setValue(1.240302277935769e+02,'m')
%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% vhcl.addedMass.setValue(zeros(3,3),'kg')
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);
% fltCtrl.rollMoment.setKp(.2,'(rad)/(rad)')
% fltCtrl.rollMoment.setTau(.1,'s')

fltCtrl.firstSpoolLap.setValue(100,'')
fltCtrl.elevatorReelInDef.setValue(0,'deg')
<<<<<<< Updated upstream
%
% fltCtrl.rollMoment.kp.setValue(5000,'(N*m)/(rad)');
=======
fltCtrl.searchSize.setValue(0.25,'')
% 
% fltCtrl.rollMoment.kp.setValue(5000,'(N*m)/(rad)');    
>>>>>>> Stashed changes
% fltCtrl.rollMoment.ki.setValue(00,'(N*m)/(rad*s)');
% fltCtrl.rollMoment.kd.setValue(20000,'(N*m)/(rad/s)');
% fltCtrl.rollMoment.tau.setValue(0.001,'s');
%
% fltCtrl.tanRoll.kp.setValue(0.2,'(rad)/(rad)');
% fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
% fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
% fltCtrl.tanRoll.tau.setValue(10,'s');

% fltCtrl.yawMoment.kp.setValue(,'(N*m)/(rad)');
%% Run Simulation
% vhcl.setFlowGradientDist(.01,'m')
% simWithMonitor('OCTModel')
% tsc = signalcontainer(logsout);
% fltCtrl.yawMoment.kp.setValue(100,'(N*m)/(rad)')
ENVIRONMENT = "env2turbLinearize";
SIXDOFDYNAMICS = 'sixDoFDynamicsCoupledFossen12Int';
set_param('OCTModel','SimulationMode','accelerator');
simWithMonitor('OCTModel')
cPV = logsout.getElement('closestPathVariable');
lapNumS = logsout.getElement('lapNumS');
tsc = signalcontainer(logsout);
plotCtrlDeflections

figure;plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,1)/max(tsc.desiredMoment.Data(:,1)))
hold on
plotsq(tsc.desiredMoment.Time,tsc.velAngleError.Data)
%%
lin = 1
if lin ~= 1
    snaps = 0:0.025:.99;
    cPV = logsout.getElement('currentPathVar');
    cPVData = mod(cPV.Values.Data,1);
    % lapNumS = logsout.getElement('lapNumS');
    numLap = 1
    x = zeros(length(snaps),numLap);
    limLap = max(tsc.lapNumS.Data)
    for j = 1:numLap;
        
        [Idx1,Idx2] = getLapIdxs(tsc,limLap-numLap-2+j);
        ran = Idx1:Idx2-1;
        tic
        
        for i = 1 : length(snaps)
            x(i,j) = find(cPVData(ran) >= snaps(i)-.0025 & cPVData(ran) <= snaps(i)+0.0025, 1, 'last')+ran(1);
        end
        toc
        
    end
    
    tsnaps = reshape(cPV.Values.Time(x),1,numel(x));
    
    %%
    io(1) = linio('OCTModel/flightController',1,'output',[],...
        'ctrlError');
    io(2) = linio('OCTModel/environment',1,'input',[],...
        'velPrim');
    toc
    fprintf('Finding Operation Points')
    tic
    op = findop('OCTModel',tsnaps);
    toc
    
    tic
    options = linearizeOptions('IgnoreDiscreteStates','on');
    linsys = linearize('OCTModel',io,op);
    toc
    %%
    for i = 1:length(snaps)
        dispName{i} = sprintf('Path Parameter = %.2f',snaps(i));
    end
    magdb = cell(4,1,length(snaps)); wHz = cell(4,1,length(snaps));
    mag = cell(4,1,length(snaps));
    for i = 1:4
        for ii = 1
            for iii = 1:length(snaps)
                [mag{i,ii,iii},phase,wout] = bode(linsys(i,3*(ii-1)+[1:3],iii,:),2*pi*logspace(-3,1,1200));
                magdb{i,ii,iii} = 20*log10(mag{i,ii,iii}.*flwSpd);
                wHz{i,ii,iii} = wout/(2*pi);
            end
        end
    end
    %%
    titleCellIn = {'Ground X Component','Ground Y Component','Ground Z Component'};
    titleCellOut = {' Central Angle Error [rad]',' Velocity Angle Error [rad]',...
        ' Tangent Roll Error [rad]',' Side Slip Error [rad]'};
    subTitleCellIn = {'Frequency Response: Turbulence Intensity [$\%$]'};;
    yLabelIn = 'Magnitude [dB]';
    xLabelIn = 'Frequency [Hz]';
    
    for i = 1:4
        for ii = 1:1
            
            h = figure('Units','inches','Position',[1 1 12 8])
            r = 3; c = 1;
            a=lines(5);
            ax1 = subplot(r,c,1); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{1});
            ax2 = subplot(r,c,2); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{2});
            ax3 = subplot(r,c,3); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{3});
            colororder(ax1,a); colororder(ax2,a); colororder(ax3,a);
            ax1.LineStyleOrder = {'-','--',':'}; ax2.LineStyleOrder = {'-','--',':'}; ax3.LineStyleOrder = {'-','--',':'};
            xlimit = [10^-2 1]
            set(ax1,'xscale','log','ylim',[-80 10],'xlim',xlimit);
            set(ax2,'xscale','log','ylim',[-80 10],'xlim',xlimit);
            set(ax3,'xscale','log','ylim',[-80 10],'xlim',xlimit);
            sgtitle({strcat('Frequency Response: ',subTitleCellIn{ii},' disturbance'),...
                strcat(' to ',titleCellOut{i})})
            for iii = 1:1:length(snaps)/2
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
    %%
    % Plot single axis bode plot
    fpath = fullfile(fileparts(which('OCTProject.prj')),'output\turbPaper\');
    titleCellOut = {'centralAngleBode','velAngleBode','tanRollBode','betaBode'};
    for i = 1:4
        for ii = 1:1
            a=lines(5);
            h = figure
            ax2 = gca; hold on; 
            colororder(ax2,a); 
            ax2.LineStyleOrder = {'-','--',':','-.'};
            xlimit = [10^-2 10]            
            set(ax2,'xscale','log','ylim',[-80 10],'xlim',xlimit);
            for iii = 1:2:length(snaps)/2
                serName = sprintf('s = %.3f',snaps(iii));
                semilogx(ax2,wHz{i,1,iii},squeeze(magdb{i,1,iii}(:,2,:)),'DisplayName',serName);
                legend(ax2,'Location','northeast','NumColumns',2)
                xlabel('Disurbance Frequency [Hz]')
                ylabel('Magnitude [dB]')
                set(gca,'FontSize',14)
            end
        end
        saveas(gcf,[fpath titleCellOut{i}],'fig')
        saveas(gcf,[fpath titleCellOut{i}],'png')
    end    
    %%
    fpath = fullfile(fileparts(which('OCTProject.prj')),'output\turbPaper\');
    
    figure; hold on;
    clear serNameCell
    ax = gca;
    offset = 0
    numEnt = numel(x)
    a=parula(numEnt/numLap);
    colororder(ax,a);
    colormap(ax,jet)
    for i = 1:numEnt/2

        if rem(i,length(snaps)) == 0
            serName = sprintf('s = %.3f',snaps(end));
        else
            serName = sprintf('s = %.3f',snaps(rem(i,length(snaps))));
        end
        serNameCell(i) = {serName};
        [p{:,i}.pole,z] = pzmap(linsys(:,:,i,:));
        clear z
        for j = 12:13
        if rem(i,length(snaps)) == 0
            scatter(real(p{:,i}.pole(j)),imag(p{:,i}.pole(j)),[],ones(length(p{:,i}.pole(j)),1)*rem(snaps(end),1),'o','SizeData',15,'MarkerFaceColor','flat')
        else
            scatter(real(p{:,i}.pole(j)),imag(p{:,i}.pole(j)),[],ones(length(p{:,i}.pole(j)),1)*rem(snaps(rem(i,length(snaps))),1),'o','SizeData',15,'MarkerFaceColor','flat')
        end
        end
    end
    h = colorbar;
    ylabel(h, 'Path Parameter','Interpreter','latex')
    %     scatter(real(p),imag(p))
    line(xlim(),[0,0],'Color',[.5 .5 .5])
    line([0,0],ylim(),'Color',[.5 .5 .5])
    xlabel('Real Axis [$s^{-1}$]')
    ylabel('Imaginary Axis [$s^{-1}$]')
    set(gca,'FontSize',15)
    %     legend(serNameCell,'NumColumns',4','Location','NorthWest')
        saveas(gcf,[fpath 'zoom'],'fig')
        saveas(gcf,[fpath 'zoom'],'png')
    %%
    for i =1:numEnt
        pPlot(i) = max(real(p{:,i}.pole));
    end
    
    h = figure
    ax = gca; colormap(ax,jet);
    snaps1 = repmat(snaps',numLap,1)
    scatter(snaps1,pPlot,[],pPlot,'filled')
    
    xlabel('Path Position')
    ylabel('Real Component of Slowest Pole [$s^{-1}$]')
end
% %%
% distAmp = 0;
% distFreq = 0;
% pertVec = [1 0 0];
% set_param('OCTModel','SimulationMode','accelerator');
% simParams = SIM.simParams;  simParams.setDuration(1000,'s');  dynamicCalc = '';
% simWithMonitor('OCTModel')
% tsc = signalcontainer(logsout);
% % distAmp = .25;
% % distFreq = .1866;
% % pertVec = [1 0 0];
% % simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
% % simWithMonitor('OCTModel')
% % tsc1 = signalcontainer(logsout);
% %
% % distAmp = .25;
% % distFreq = .1866;
% % pertVec = [0 1 0];
% % simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
% % simWithMonitor('OCTModel')
% % tsc2 = signalcontainer(logsout);
% 
% distAmp = .1;
% distFreq = 1;
% pertVec = [0 1 0];
% simParams = SIM.simParams;  simParams.setDuration(1000,'s');  dynamicCalc = '';
% simWithMonitor('OCTModel')
% tsc2 = signalcontainer(logsout);
<<<<<<< Updated upstream

distAmp = .1;
distFreq = 1;
pertVec = [0 1 0];
simParams = SIM.simParams;  simParams.setDuration(1000,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')
tsc2 = signalcontainer(logsout);
%%
runLin = 1
lap = max(tsc.lapNumS.Data)-2;
[Idx1,Idx2] = getLapIdxs(tsc,lap);
ran = Idx1:Idx2-1;
for i = 1:1000-3
    ind(i)=find(tsc.closestPathVariable.Data(ran) > i/1000,1);
end
tanRollErrBase = squeeze(tsc.tanRollError.Data(Idx1+ind));
cenAngleErrBase = squeeze(tsc.centralAngle.Data(Idx1+ind));
betaErrBase = squeeze(tsc.betaErr.Data(Idx1+ind));
velAngErrBase = squeeze(mod(tsc.velAngleError.Data(Idx1+ind)-pi,2*pi)-pi)
pathVar = tsc.closestPathVariable.Data(Idx1+ind);

lap = max(tsc2.lapNumS.Data)-2;
[Idx1,Idx2] = getLapIdxs(tsc2,lap);
ran = Idx1:Idx2-1;
for i = 1:1000-3
    
    ind(i)=find(tsc2.closestPathVariable.Data(ran) > i/1000,1);
end
tanRollErr = squeeze(tsc2.tanRollError.Data(Idx1+ind));
cenAngleErr = squeeze(tsc2.centralAngle.Data(Idx1+ind));
betaErr = squeeze(tsc2.betaErr.Data(Idx1+ind));
velAngErr = squeeze(mod(tsc2.velAngleError.Data(Idx1+ind)-pi,2*pi)-pi);

clear xx
for ii = 1:4
    for i = 1:length(snaps)
        xx(ii,i)=find(wHz{ii,1,i} > distFreq,1);
        wHzPlot(ii,i) = wHz{ii,1,i}(xx(ii,i));
        magPlot(ii,i,:) = mag{ii,1,i}(1,:,xx(ii,i));
    end
end

fSize = 14
figure; hold on;
ax = gca;
plotsq(pathVar,betaErr-betaErrBase,'k')
if runLin == 1
    ax = gca; colormap(ax,jet);
    scatter(snaps,magPlot(4,:,2)*distAmp*flwSpd,'r','filled')
    scatter(snaps,-magPlot(4,:,2)*distAmp*flwSpd,'r','filled')
    %     h = colorbar;
    %     ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
end
xlabel('Path Position')
ylabel('Side Slip Error [rad]')
legend('Simulation','Predicted Error','Location','southeast')
set(gca,'FontSize',fSize)
saveas(gcf,[fpath 'betaErr'],'fig')
saveas(gcf,[fpath 'betaErr'],'png')


figure; hold on;
plotsq(pathVar,cenAngleErr-cenAngleErrBase,'k')
if runLin == 1
    ax = gca; colormap(ax,jet);
    scatter(snaps,magPlot(1,:,2)*distAmp*flwSpd,'r','filled')
    scatter(snaps,-magPlot(1,:,2)*distAmp*flwSpd,'r','filled')
    %     h = colorbar;
    %     ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
end
xlabel('Path Position')
ylabel('Central Angle Error [rad]')
legend('Simulation','Predicted Error','Location','southeast')
set(gca,'FontSize',fSize)
saveas(gcf,[fpath 'centAngErr'],'fig')
saveas(gcf,[fpath 'centAngErr'],'png')

figure; hold on;
plotsq(pathVar,tanRollErr-tanRollErrBase,'k')
if runLin == 1
    ax = gca; colormap(ax,jet);
    scatter(snaps,magPlot(3,:,2)*distAmp*flwSpd,'r','filled')
    scatter(snaps,-magPlot(3,:,2)*distAmp*flwSpd,'r','filled')
    %     h = colorbar;
    %     ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
end
xlabel('Path Position')
ylabel('Tangent Roll Error [rad]')
legend('Simulation','Predicted Error','Location','southeast')
set(gca,'FontSize',fSize)
saveas(gcf,[fpath 'tanRollErr'],'fig')
saveas(gcf,[fpath 'tanRollErr'],'png')

figure; hold on
plotsq(pathVar,velAngErr-velAngErrBase,'k')
if runLin == 1
    ax = gca; colormap(ax,jet);
    scatter(snaps,magPlot(2,:,2)*distAmp*flwSpd,'r','filled')%,[],pPlot,'filled')
    scatter(snaps,-magPlot(2,:,2)*distAmp*flwSpd,'r','filled')%,[],pPlot,'filled')
    %     h = colorbar;
    %     ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
end
xlabel('Path Position')
ylabel('Velocity Angle Error [rad]')
legend('Simulation','Predicted Error','Location','southeast')
set(gca,'FontSize',fSize)
saveas(gcf,[fpath 'velAngErr'],'fig')
saveas(gcf,[fpath 'velAngErr'],'png')

figure; hold on;
subplot (2,2,1); hold on;
plotsq(pathVar,betaErr)
plotsq(pathVar,betaErrBase,'k')
ylabel('Error [rad]'); title('Side Slip Error')

subplot (2,2,2); hold on;
plotsq(pathVar,cenAngleErr)
plotsq(pathVar,cenAngleErrBase,'k')
ylabel('Error [rad]'); title('Central Angle Error')

subplot (2,2,3); hold on;
plotsq(pathVar,tanRollErr)
plotsq(pathVar,tanRollErrBase,'k')
ylabel('Error [rad]'); title('Tangent Roll Angle Error'); xlabel('Path Position')

subplot (2,2,4); hold on;
plotsq(pathVar,velAngErr)
plotsq(pathVar,velAngErrBase,'k')
ylabel('Error [rad]'); title('Velocity Angle Error'); xlabel('Path Position')
legend('Perturbed Flow','Base Case')
%%
% tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',true,'plotBeta',false,'lapNum',max(tsc.lapNumS.Data)-1)

figure
plot(tsc.thrAttchPtAirBus.posVec.Time,squeeze(sqrt(dot(tsc.thrAttchPtAirBus.posVec.Data,tsc.thrAttchPtAirBus.posVec.Data)))-squeeze(tsc.tetherLengths.Data))
xlabel('Time [s]')
ylabel('Tether Stretch [m]')
%     x =  squeeze(tsc1.tc.Data);
%     y = squeeze(tsc1.wd.Data);
%     hist2d(y,x)
%     title('2.0 M/S Flow Speed')
%     zlabel('Occurences')
%     xlabel('Drum Velocity (rad/s)')
%     ylabel('Torque (Nm)')
%     set(gca,'FontSize',15);

%     fprintf("Mean central angle = %g deg\n",180/pi*mean(tsc.centralAngle.Data))
%     disp(hiLvlCtrl.basisParams.Value)
%     %[y, Fs] = audioread('Ding-sound-effect.mp3'); %https://www.freesoundslibrary.com/ding-sound-effect/
%     %sound(y*.2, Fs, 16)
%     fprintf("min Z = %4.2f\n",min(tsc.positionVec.Data(3,1,:)))
<<<<<<< Updated upstream
%
vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',20,...
    'GifTimeStep',.00001,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
    'ZoomIn',1==0,'SaveGif',1==1,'GifFile','really.gif')
=======
% 
    vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',20,...
        'GifTimeStep',.00001,'PlotTracer',true,'FontSize',12,'Pause',1==0)
>>>>>>> Stashed changes
=======
% %%
% runLin = 1
% lap = max(tsc.lapNumS.Data)-2;
% [Idx1,Idx2] = getLapIdxs(tsc,lap);
% ran = Idx1:Idx2-1;
% for i = 1:1000-3
%     ind(i)=find(tsc.closestPathVariable.Data(ran) > i/1000,1);
% end
% tanRollErrBase = squeeze(tsc.tanRollError.Data(Idx1+ind));
% cenAngleErrBase = squeeze(tsc.centralAngle.Data(Idx1+ind));
% betaErrBase = squeeze(tsc.betaErr.Data(Idx1+ind));
% velAngErrBase = squeeze(mod(tsc.velAngleError.Data(Idx1+ind)-pi,2*pi)-pi)
% pathVar = tsc.closestPathVariable.Data(Idx1+ind);
% 
% lap = max(tsc2.lapNumS.Data)-2;
% [Idx1,Idx2] = getLapIdxs(tsc2,lap);
% ran = Idx1:Idx2-1;
% for i = 1:1000-3
%     
%     ind(i)=find(tsc2.closestPathVariable.Data(ran) > i/1000,1);
% end
% tanRollErr = squeeze(tsc2.tanRollError.Data(Idx1+ind));
% cenAngleErr = squeeze(tsc2.centralAngle.Data(Idx1+ind));
% betaErr = squeeze(tsc2.betaErr.Data(Idx1+ind));
% velAngErr = squeeze(mod(tsc2.velAngleError.Data(Idx1+ind)-pi,2*pi)-pi);
% 
% clear xx
% for ii = 1:4
%     for i = 1:length(snaps)
%         xx(ii,i)=find(wHz{ii,1,i} > distFreq,1);
%         wHzPlot(ii,i) = wHz{ii,1,i}(xx(ii,i));
%         magPlot(ii,i,:) = mag{ii,1,i}(1,:,xx(ii,i));
%     end
% end
% 
% fSize = 14
% figure; hold on;
% ax = gca;
% plotsq(pathVar,betaErr-betaErrBase,'k')
% if runLin == 1
%     ax = gca; colormap(ax,jet);
%     scatter(snaps,magPlot(4,:,2)*distAmp*flwSpd,'r','filled')
%     scatter(snaps,-magPlot(4,:,2)*distAmp*flwSpd,'r','filled')
%     %     h = colorbar;
%     %     ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
% end
% xlabel('Path Position')
% ylabel('Side Slip Error [rad]')
% legend('Simulation','Predicted Error','Location','southeast')
% set(gca,'FontSize',fSize)
% saveas(gcf,[fpath 'betaErr'],'fig')
% saveas(gcf,[fpath 'betaErr'],'png')
% 
% 
% figure; hold on;
% plotsq(pathVar,cenAngleErr-cenAngleErrBase,'k')
% if runLin == 1
%     ax = gca; colormap(ax,jet);
%     scatter(snaps,magPlot(1,:,2)*distAmp*flwSpd,'r','filled')
%     scatter(snaps,-magPlot(1,:,2)*distAmp*flwSpd,'r','filled')
%     %     h = colorbar;
%     %     ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
% end
% xlabel('Path Position')
% ylabel('Central Angle Error [rad]')
% legend('Simulation','Predicted Error','Location','southeast')
% set(gca,'FontSize',fSize)
% saveas(gcf,[fpath 'centAngErr'],'fig')
% saveas(gcf,[fpath 'centAngErr'],'png')
% 
% figure; hold on;
% plotsq(pathVar,tanRollErr-tanRollErrBase,'k')
% if runLin == 1
%     ax = gca; colormap(ax,jet);
%     scatter(snaps,magPlot(3,:,2)*distAmp*flwSpd,'r','filled')
%     scatter(snaps,-magPlot(3,:,2)*distAmp*flwSpd,'r','filled')
%     %     h = colorbar;
%     %     ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
% end
% xlabel('Path Position')
% ylabel('Tangent Roll Error [rad]')
% legend('Simulation','Predicted Error','Location','southeast')
% set(gca,'FontSize',fSize)
% saveas(gcf,[fpath 'tanRollErr'],'fig')
% saveas(gcf,[fpath 'tanRollErr'],'png')
% 
% figure; hold on
% plotsq(pathVar,velAngErr-velAngErrBase,'k')
% if runLin == 1
%     ax = gca; colormap(ax,jet);
%     scatter(snaps,magPlot(2,:,2)*distAmp*flwSpd,'r','filled')%,[],pPlot,'filled')
%     scatter(snaps,-magPlot(2,:,2)*distAmp*flwSpd,'r','filled')%,[],pPlot,'filled')
%     %     h = colorbar;
%     %     ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
% end
% xlabel('Path Position')
% ylabel('Velocity Angle Error [rad]')
% legend('Simulation','Predicted Error','Location','southeast')
% set(gca,'FontSize',fSize)
% saveas(gcf,[fpath 'velAngErr'],'fig')
% saveas(gcf,[fpath 'velAngErr'],'png')
% 
% figure; hold on;
% subplot (2,2,1); hold on;
% plotsq(pathVar,betaErr)
% plotsq(pathVar,betaErrBase,'k')
% ylabel('Error [rad]'); title('Side Slip Error')
% 
% subplot (2,2,2); hold on;
% plotsq(pathVar,cenAngleErr)
% plotsq(pathVar,cenAngleErrBase,'k')
% ylabel('Error [rad]'); title('Central Angle Error')
% 
% subplot (2,2,3); hold on;
% plotsq(pathVar,tanRollErr)
% plotsq(pathVar,tanRollErrBase,'k')
% ylabel('Error [rad]'); title('Tangent Roll Angle Error'); xlabel('Path Position')
% 
% subplot (2,2,4); hold on;
% plotsq(pathVar,velAngErr)
% plotsq(pathVar,velAngErrBase,'k')
% ylabel('Error [rad]'); title('Velocity Angle Error'); xlabel('Path Position')
% legend('Perturbed Flow','Base Case')
% %%
% % tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',true,'plotBeta',false,'lapNum',max(tsc.lapNumS.Data)-1)
% 
% figure
% plot(tsc.thrAttchPtAirBus.posVec.Time,squeeze(sqrt(dot(tsc.thrAttchPtAirBus.posVec.Data,tsc.thrAttchPtAirBus.posVec.Data)))-squeeze(tsc.tetherLengths.Data))
% xlabel('Time [s]')
% ylabel('Tether Stretch [m]')
% %     x =  squeeze(tsc1.tc.Data);
% %     y = squeeze(tsc1.wd.Data);
% %     hist2d(y,x)
% %     title('2.0 M/S Flow Speed')
% %     zlabel('Occurences')
% %     xlabel('Drum Velocity (rad/s)')
% %     ylabel('Torque (Nm)')
% %     set(gca,'FontSize',15);
% 
% %     fprintf("Mean central angle = %g deg\n",180/pi*mean(tsc.centralAngle.Data))
% %     disp(hiLvlCtrl.basisParams.Value)
% %     %[y, Fs] = audioread('Ding-sound-effect.mp3'); %https://www.freesoundslibrary.com/ding-sound-effect/
% %     %sound(y*.2, Fs, 16)
% %     fprintf("min Z = %4.2f\n",min(tsc.positionVec.Data(3,1,:)))
% %
% vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',20,...
%     'GifTimeStep',.00001,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
%     'ZoomIn',1==0,'SaveGif',1==1,'GifFile','really.gif')
>>>>>>> Stashed changes
