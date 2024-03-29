% clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(1000,'s');
dynamicCalc = '';
distFreq = 0;distAmp = 0;pertVec = [0 1 0];flwSpd = -2
%% Load components
% Flight Controller
% loadComponent('pathFollowingCtrlAddedMass');
loadComponent('pathFollowingCtrlForILC');
% FLIGHTCONTROLLER = 'pathFollowingCtrlAoATurb';
% fltCtrl.rudderGain.setValue(-1,'')
% SPOOLINGCONTROLLER = 'netZeroSpoolingControllerEllipsePath';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';
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
VEHICLE = 'vehicleLEBand'
% loadComponent('pathFollowingVhclForComp')
% loadComponent('sensitivityAnalysis');              %   Load vehicle
% Environment
% loadComponent('CNAPsNoTurbJosh');
% loadComponent('CNAPsTurbJames');
% loadComponent('CNAPsTurbMitchell');
loadComponent('ConstXYZT');
ENVIRONMENT = 'environmentDOELinearize'
SIXDOFDYNAMICS = 'sixDoFDynamicsCoupledFossen12int'
%% Environment IC's and dependant properties
env.water.setflowVec([-2 0 0],'m/s')
%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([1.4,2.2,-.3,180*pi/180,125],'[rad rad rad rad m]') % Lemniscate of Booth
%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 200],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    .05,... % Initial path position
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
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
%% Winches IC's and dependant properties
% wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.initLength.setValue(1.240302277935769e+02,'m')
%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% vhcl.addedMass.setValue(zeros(3,3),'kg')
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);
fltCtrl.elevatorReelInDef.setValue(0,'deg')
%% Run Simulation
% vhcl.setFlowGradientDist(.01,'m')
% simWithMonitor('OCTModel')
% tsc = signalcontainer(logsout);
 turbAmp = .3;
 turbPer = .33;
set_param('OCTModel','SimulationMode','accelerator');
simWithMonitor('OCTModel')
cPV = logsout.getElement('closestPathVariable');
lapNumS = logsout.getElement('lapNumS');
tsc = signalcontainer(logsout);
%%
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
x
tsnaps = reshape(cPV.Values.Time(x),1,numel(x));

%%
    io(1) = linio('OCTModel/flightController',1,'output',[],...
        'err');
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
                [mag{i,ii,iii},phase,wout] = bode(linsys(i,3*(ii-1)+[1:3],iii,:),{0.001*2*pi 20*pi});
                magdb{i,ii,iii} = 20*log10(mag{i,ii,iii}.*flwSpd);
                wHz{i,ii,iii} = wout/(2*pi);
            end
        end
    end
    
    titleCellIn = {'Ground X Component','Ground Y Component','Ground Z Component'};
    titleCellOut = {' Central Angle Error [rad]',' Velocity Angle Error [rad]',...
        ' Tangent Roll Error [rad]',' Side Slip Error [rad]'};
    subTitleCellIn = {'Frequency Response: Turbulence Intensity [$\%$]'};
    yLabelIn = 'Magnitude [dB]';
    xLabelIn = 'Frequency [Hz]';
       
    for i = 1:4
        for ii = 1:1
            h = figure('Units','inches','Position',[1 1 12 8])
            r = 1; c = 3;
            a=lines(5);
            ax1 = subplot(r,c,1); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{1});
            ax2 = subplot(r,c,2); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{2});
            ax3 = subplot(r,c,3); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{3});
            colororder(ax1,a); colororder(ax2,a); colororder(ax3,a);
            ax1.LineStyleOrder = {'-','--',':'}; ax2.LineStyleOrder = {'-','--',':'}; ax3.LineStyleOrder = {'-','--',':'};
            set(ax1,'xscale','log','ylim',[-60 10]); set(ax2,'xscale','log','ylim',[-60 10]);
            set(ax3,'xscale','log','ylim',[-60 10]);
            sgtitle({strcat('Frequency Response: ',subTitleCellIn{ii},' disturbance'),...
                strcat(' to ',titleCellOut{i})})
            for iii = 1:1:length(snaps)
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
figure; hold on;
clear serNameCell
ax = gca;
offset = 0
numEnt = numel(x)
a=hsv(numEnt/numLap);
colororder(ax,a);
colormap(ax,jet)
for i = 1:numEnt
    if rem(i,length(snaps)) == 0
        serName = sprintf('s = %.3f',snaps(end));
    else
        serName = sprintf('s = %.3f',snaps(rem(i,length(snaps))));
    end
    serNameCell(i) = {serName};
    [p{:,i}.pole,z] = pzmap(linsys(:,:,i,:));
    clear z
    if rem(i,length(snaps)) == 0
        scatter(real(p{:,i}.pole),imag(p{:,i}.pole),[],ones(length(p{:,i}.pole),1)*rem(snaps(end),1),'x')
    else
        scatter(real(p{:,i}.pole),imag(p{:,i}.pole),[],ones(length(p{:,i}.pole),1)*rem(snaps(rem(i,length(snaps))),1),'x')
    end
    
end
h = colorbar;
ylabel(h, 'Path Parameter','Interpreter','latex')
%     scatter(real(p),imag(p))
line(xlim(),[0,0],'Color',[.5 .5 .5])
line([0,0],ylim(),'Color',[.5 .5 .5])
xlabel('Real Axis [$s^{-1}$]')
ylabel('Imaginary Axis [$s^{-1}$]')
%     legend(serNameCell,'NumColumns',4','Location','NorthWest')

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


%%
tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',true,'plotBeta',false,'lapNum',max(tsc.lapNumS.Data)-1)

figure
plot(tsc.thrAttchPtAirBus.posVec.Time,squeeze(sqrt(dot(tsc.thrAttchPtAirBus.posVec.Data,tsc.thrAttchPtAirBus.posVec.Data)))-squeeze(tsc.tetherLengths.Data))
xlabel('Time [s]')
ylabel('Tether Stretch [m]')
%%
% tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',true,'plotBeta',false,'lapNum',max(tsc.lapNumS.Data)-1)
%
% sStar = squeeze(mod(tsc.currentPathVar.Data,1));
%
% time1 = [];
% set1 = [];
% roll1 = [];
% pitch1 = [];
% yaw1 = [];
% x1 = [];
% y1 = [];
% z1 = [];
% vx1 = [];
% vy1 = [];
% vz1 = [];
% angx1 = [];
% angy1 = [];
% angz1 = [];
% for ii = 1:length(sStar)
%
%     if (sStar(ii) <.251) && (sStar(ii) > .249) %need to make this logic so it can only happen once per lap
%
%         if (tsc.currentPathVar.Time(ii) - time1(ii-1)) >5 && length(set1)>1
%
%         set1 = [set1;sStar(ii)];
%         time1 = [time1;tsc.currentPathVar.Time(ii)];
%         roll1 = [roll1;tsc.eulerAngles.Data(1,1,ii)];
%         pitch1 = [pitch1;tsc.eulerAngles.Data(2,1,ii)];
%         yaw1 = [yaw1;tsc.eulerAngles.Data(3,1,ii)];
%         x1 = [x1;tsc.positionVec.Data(1,1,ii)];
%         y1 = [y1;tsc.positionVec.Data(2,1,ii)];
%         z1 = [z1;tsc.positionVec.Data(3,1,ii)];
%         vx1 = [vx1;tsc.velocityVec.Data(1,1,ii)];
%         vy1 = [vy1;tsc.velocityVec.Data(2,1,ii)];
%         vz1 = [vz1;tsc.velocityVec.Data(3,1,ii)];
%         angx1 = [angx1;tsc.angularVel.Data(1,1,ii)];
%         angy1 = [angy1;tsc.angularVel.Data(2,1,ii)];
%         angz1 = [angz1;tsc.angularVel.Data(3,1,ii)];
%         end
%     end
%
% end
%
vhcl.animateSim(tsc,1,'PathFunc',fltCtrl.fcnName.Value,...
    'PlotTracer',true,'FontSize',18)