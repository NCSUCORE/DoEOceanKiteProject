%% Test script for John to control the kite model
% clear all% powerNom powerNew;
clc
close all;
Simulink.sdi.clear
%% Simulation Setup
% 1 - Vehicle Model:         1 = AR8b8, 2 = AR9b9, 3 = AR9b10
% 2 - High-level Controller: 1 = const basis, 2 = const basis/stategit  flow
% 3 - Flight controller:     1 = pathFlow, 2 = full cycle
% 4 - Tether Model:          1 = Single link, 2 = Reel-in, 3 = Multi-node, 4 = Multi-node faired
% 5 - Environment:           1 = const flow, 2 = variable flow
% 6 - Save Results
% 7 - Animate
% 8 - Plotting
%%             1 2 3 4 5 6     7     8
A = 0
B = 0
phi = 0
lapMax = 1000
load tsrMod.mat
simScenario = [1 4 1 3 1 1==1 1==0 1==1];
thrSweep = 2000;
altSweep = 1;
flwSweep = 1;%[.7:.1:2]
x = meshgrid(thrSweep,altSweep,flwSweep);
[n,m,r] = size(x);
numCase = n*m*r;
powGen = zeros(n,m,r);
pathErr = zeros(n,m,r);
dragRatio = zeros(n,m,r);
Pow = cell(n,m,r);
laps2opt = 40;
for i = 1:n
    if i < 1
        continue
    end
    for j = 1:m
        if j < 1
            continue
        end
        k = 1;
        bVec = 80%[40:5:50];
        for k = 1:numel(bVec)
            for ii = 1
                fprintf(sprintf('%.2f Percent Complete\n',((i-1)*m*r+(j-1)*r+k)/(n*m*r)*100))
                Simulink.sdi.clear
                %  Set Test Parameters
                tFinal = 15000;%+200*k;      tSwitch = 10000;                        %   s - maximum sim duration
                flwSpd = flwSweep;%(k);                                              %   m/s - Flow speed
                altitude = thrSweep(j)/2;                   %   m/m - cross-current and initial altitude

                thrLength = thrSweep(j);
                el = asin(altitude/thrLength);                              %   rad - Initial elevation angle
                height = 0:25:2200;

                hNom = altitude;
                v = [0.25 1]*flwSpd;
                z = [hNom-600 hNom];
                flow = flowDist(height,z,v);

                if ii == 1
                    b = 20;
                    a = bVec(k);
                else
                    b = 30;
                    a = 120;
                end
                d = 1;
                loadComponent('ultDoeKiteTSR')
                VEHICLE = 'vhcl4turb';
                
                vhcl.turb1.diameter.setValue(0.75,'m')
                vhcl.turb2.diameter.setValue(0.75,'m')
                vhcl.turb3.diameter.setValue(0.75,'m')
                vhcl.turb4.diameter.setValue(0.75,'m');
                loadComponent('seILC');
                %                 HILVLCONTROLLER = 'ilcPathOptThrTen'
                hiLvlCtrl.initBasisParams.setValue([a,b,altitude,0*pi/180,... %   Initialize basis parameters
                    thrLength],'');
                
                loadComponent('pathFollowWithAoACtrlDOE');             %   Path-following controller with AoA control
                loadComponent('pathFollowingTether');                       %   Manta Ray tether
                loadComponent('ConstXYZT');                         %   Constant flow
                ENVIRONMENT = 'env4turb';                           %   Two turbines
                env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
                loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
                loadComponent('oneThrGndStn000');
                GROUNDSTATION = 'GroundStation000';%   Ground station
                loadComponent('oneWnch');
                WINCH = 'constThr';%   Winches
                loadComponent('idealSensors')                               %   Sensors
                loadComponent('idealSensorProcessing')                      %   Sensor processing
                %             SENSORS = 'deadRecPos'
                %%  Vehicle Initial Conditions
                %   Constant basis parameters
                PATHGEOMETRY = 'lemBoothNew';
                FLIGHTCONTROLLER = 'pathFollowingControllerManta'
                if simScenario(3) == 1
                    if simScenario(2) == 4
                        vhcl.setICsOnPath(0.875,PATHGEOMETRY,hiLvlCtrl.initBasisParams.Value,gndStn.posVec.Value,2*flwSpd)
                    else
                        vhcl.setICsOnPath(0.875,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,2*flwSpd)
                    end
                else
                    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
                    vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
                end
                %%  Tethers Properties
                %   kN - candidate tether tension limits
                fltCtrl.Tmax.setValue(55,'kN');
                %                 TETHERS = 'tetherFaired'
                thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
                thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
                thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
                thr.tether1.initAirNodeVel.setValue(rotation_sequence(vhcl.initEulAng.Value)*vhcl.initVelVecBdy.Value(:),'m/s');
                thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
                %Choose Tether
                %                                 thr.tether1.dragCoeff.setValue(0.3,'')
                %                 thr.numNodes.setValue(2,'');
                %                 thr.tether1.numNodes.setValue(2,'');
                thr.tether1.dragCoeff.setValue(1.2,'')
                thr.numNodes.setValue(10,'');
                thr.tether1.numNodes.setValue(10,'');
                thr.tether1.setDensity(1000,'kg/m^3');
                thr.tether1.diameter.setValue(0.022,'m');
                %%  Winches Properties
                wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
                %             wnch.winch1.LaRspeed.setValue(1,'m/s');
                %%  Controller User Def. Parameters and dependant properties
                fltCtrl.setFcnName(PATHGEOMETRY,'');
                if simScenario(2) == 4
                    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.initBasisParams.Value,gndStn.posVec.Value);
                else
                    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
                end
                %                                 fltCtrl.rollMoment.kp.setValue(1e6,fltCtrl.rollMoment.kp.Unit)
                %                 fltCtrl.pitchMoment.kp.setValue(240000,fltCtrl.pitchMoment.kp.Unit)
                %             fltCtrl.pitchMoment.ki.setValue(5000,fltCtrl.pitchMoment.ki.Unit)
                fltCtrl.AoAConst.setValue(15*pi/180,'deg')
                fltCtrl.perpErrorVal.setValue(0.025,'rad')

                fltCtrl.rollMoment.kp.setValue(1e6,fltCtrl.rollMoment.kp.Unit)
                fltCtrl.rollMoment.kd.setValue(1e6,fltCtrl.rollMoment.kd.Unit)
%                 
                fltCtrl.tanRoll.kp.setValue(.8,fltCtrl.tanRoll.kp.Unit)
                fltCtrl.tanRoll.kd.setValue(.4,fltCtrl.tanRoll.kd.Unit)
                
%                 fltCtrl.yawMoment.kp.setValue(0,fltCtrl.yawMoment.kp.Unit)

                fltCtrl.pitchMoment.kp.setValue(5e5,fltCtrl.rollMoment.kp.Unit)
                fltCtrl.pitchMoment.ki.setValue(.5e4,fltCtrl.rollMoment.ki.Unit)
                fltCtrl.pitchMoment.kd.setValue(2e6,fltCtrl.rollMoment.kd.Unit)
                fltCtrl.searchSize.setValue(.125,'')

                turbAng = 0;
                turbAngVec = [cosd(turbAng);0;sind(turbAng)];
                vhcl.turb1.axisUnitVec.setValue(turbAngVec,'')
                vhcl.turb2.axisUnitVec.setValue(-turbAngVec,'')
                vhcl.turb3.axisUnitVec.setValue(turbAngVec,'')
                vhcl.turb4.axisUnitVec.setValue(-turbAngVec,'')
                fltCtrl.yawMoment.kp.setValue(-5e4,fltCtrl.yawMoment.kp.Unit)
                %%  Set up critical system parameters and run simulation
                FLOWCALCULATION = 'flowColumnSpec';
                thrSwitch = 1;
                simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
                set_param('OCTModel', 'MinimalZcImpactIntegration', 'on')
                hiLvlCtrl.switching.setValue(1,'');
                simWithMonitor('OCTModel','timeStep',2,'minRate',7)             
                tsc = signalcontainer(logsout);
                if sum(hiLvlCtrl.subspaceDims)~=10
                hiLvlCtrl.switching.setValue(0,'');
                simWithMonitor('OCTModel','timeStep',2,'minRate',1)
                tsc2 = signalcontainer(logsout);
                end
                %%
                fpath = 'C:\Users\adabney\iCloudDrive\NCSU HW Uploads\estimationPaper\figs\';
                close all
                if sum(hiLvlCtrl.subspaceDims)==10
                maxLap = tsc.lapNumS.max;
                lapInt = [8 10 15 25 maxLap-1];
                figure('Position',[100 100 600 550]); hold on; grid on;
                j = 1;
                lineorder = {'-','-','-','--',':','-.','-'};
                markerorder = {'none','s','^','none','none','none','none'};
                stairs(0:.1:1,2.88*ones(11,1),'k','LineStyle',lineorder{j},'Marker',markerorder{j},'LineWidth',1.5);
                j = j+1;
                for i = lapInt(1:end-1)
                    iter = i-7;
                [id1,id2] = tsc.getLapIdxs(i); 
                ran = id1:id2;
                stairs(0:.05:.5,[tsc.basisVecIter.Data(iter,1:end) tsc.basisVecIter.Data(iter,end)],'k','LineStyle',lineorder{j},'Marker',markerorder{j},'LineWidth',1.5)
                legEnt{1} = 'Initial Condition';
                hold on;
%                 plotsq(tsc.closestPathVariable.Data(ran),tsc.TSR.Data(1,4,ran))
                newPow = tsc.netPow1.getsamples(ran);
                lapAvg(j) = newPow.cumtrapz(0).Data(:,:,end)/(newPow.Time(end)-newPow.Time(1));
                if i ~= 41
                    legEnt{j} = sprintf('Iteration %d',iter);%, Lap Averaged Power %.0f kW',i-4,lapAvg(j));
                else
                    legEnt{j} = sprintf('Physical Law');%, Lap Averaged Power %.0f kW',lapAvg(j));
                end
                j = j+1;
                end
                [id1,id2] = tsc.getLapIdxs(lapInt(end));
                ran = id1:id2;
                newPow = tsc.netPow1.getsamples(ran);
                lapAvg(j) = newPow.cumtrapz(0).Data(:,:,end)/(newPow.Time(end)-newPow.Time(1));
                plotsq(tsc.closestPathVariable.Data(ran),tsc.TSR.Data(1,4,ran),'k')
                legEnt{j} = 'Physics Based Law';
                legend(legEnt,'NumColumns',2,'Location','northwest');
                xlabel 'Path Position'
                ylabel 'TSR'
                ylim([2.8 4.2])
                xlim([0 0.5])
                set(gca,'FontSize',14)
                saveas(gcf,[fpath 'rotorProf'],'fig')
                saveas(gcf,[fpath 'rotorProf'],'epsc')
                %%              
                figure('Position',[100 100 600 300]);
                stairs([tsc.iter.Data; tsc.iter.Data(end)+1]-1,[tsc.J.Data; tsc.J.Data(end)],'k','LineWidth',1.5)
                hold on 
                plot([0 30],[lapAvg(end) lapAvg(end)],'--k')
                ylabel 'Lap-Averaged Power [W]'
                xlabel 'Iteration'
                legend('eILC','Physics Based Law','location','southeast')
                set(gca,'FontSize',14)
                xlim([0 30])
                
                grid on
                saveas(gcf,[fpath 'rotorPerf'],'fig')
                saveas(gcf,[fpath 'rotorPerf'],'epsc')
                else
%%
                figure
                perfTSR = tsc.J.Data;
                gradSwitch = tsc.gradSwitch.Data(1:end-1);
                perfWidth = perfTSR;
                perfHeight = perfTSR;
                perfWidth([1==0; gradSwitch ~= 1]) = NaN;
                perfHeight([1==0; gradSwitch ~= 2]) = NaN;
                perfTSR([1==0; gradSwitch ~= 3]) = NaN;
                figure('Position',[100 100 600 300]);
                stairs(tsc.iter.Data-1,perfWidth,'.k','MarkerSize',15)
                hold on
                stairs(tsc.iter.Data-1,perfHeight,'sk')
                stairs(tsc.iter.Data-1,perfTSR,'^k')
                stairs(tsc2.iter.Data-1,tsc2.J.Data,'k')
                grid on
                ylabel 'Lap-Averaged Power [W]'
%                 yyaxis right
%                 plot(tsc.iter.Data,tsc.gradSwitch.Data,'LineWidth',1.5,'--k')
                xlabel 'Iteration'
%                 ylim([3300 3900])
%                 ylabel 'Parameter Subspace'
%                 xlim([0 30])
                legend('Width Move','Height Move','TSR Move','eILC','Location','southeast')
                set(gca,'FontSize',14)
                saveas(gcf,[fpath 'switchingPerf'],'fig')
                saveas(gcf,[fpath 'switchingPerf'],'epsc')

                figure('Position',[100 100 600 300])
                stairs(tsc.iter.Data,tsc.basisVecIter.Data(:,1),'k','LineWidth',1.5)
                hold on
                stairs(tsc.iter.Data,tsc.basisVecIter.Data(:,2),'k','LineWidth',1.5)
                stairs(tsc2.iter.Data,tsc2.basisVecIter.Data(:,1),'k','LineWidth',.5)
                stairs(tsc2.iter.Data,tsc2.basisVecIter.Data(:,2),'k','LineWidth',.5)
                grid on
                xlabel 'Iteration'
                ylabel 'Path Parameters [m]'
                legend('seILC Path Width','seILC Path Height','eILC Path Width','eILC Path Height')
%                 set(gca,'FontSize',14)
%                 saveas(gcf,[fpath 'pathMoves'],'fig')
%                 saveas(gcf,[fpath 'pathMoves'],'epsc')
                end
            end
        end
    end
end
