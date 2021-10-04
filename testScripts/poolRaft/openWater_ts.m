%% Test script for pool test simulation of the kite model
clear;clc;close all;

clc
Simulink.sdi.clear
clear all
% close all
distFreq = 0;distAmp = 0;pertVec = [0 1 0];
%%  Set Test Parameters
saveSim = 0;               %   Flag to save results
runLin = 0;                %   Flag to run l    inearization
inc =-5.5;
elevArray = 20*pi/180%[40 15]*pi/180;
towArray = [0.78];
rCM = 1 
lengthArray = 2.63;     
thrLength = 2.63%2.63
flwSpd = -1e-9;
cdArray = [1.2 1.8];    
shareArray = 0;1:-.2:0
for q = 3           
    for i = 1:length(shareArray)
            for k = 1:numel(rCM)
                tic
                Simulink.sdi.clear
                h = 30*pi/180;  w = 100*pi/180;                             %   rad - Path width/height
                [a,b] = boothParamConversion(w,h);                          %   Path basis parameters

                %%  Load components
                el = 35*pi/180;
                if q ~= 3
                    %             loadComponent('exp_slCtrl');
                    loadComponent('periodicCtrlExp');
                    %             fltCtrl.ctrlOff.setValue(0,'')
                    FLIGHTCONTROLLER = 'periodicCtrlExpAllocate';
                else%
                    loadComponent('pathFollowCtrlExp');                         %   Path-following controller with AoA control
                    FLIGHTCONTROLLER = 'pathFollowingControllerExp';
                end
                loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller                           %   Ground station
                  loadComponent('raftGroundStation');
                GROUNDSTATION = 'boatGroundStation'
                loadComponent('oneDOFWnch');                                %   Winches
                loadComponent('poolTether');                                      %   Manta Ray tether
%                 thr.tether1.numNodes.setValue(2,'')
%                 thr.numNodes.setValue(2,'')
                loadComponent('idealSensors');                             %   Sensors
                loadComponent('lasPosEst')
                loadComponent('lineAngleSensor');
                loadComponent('idealSensorProcessing');                      %   Sensor processing
                loadComponent('poolScaleKiteAbney');                %   AR = 8; 8m span
                SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen12int";
                %%  Environment Properties
                loadComponent('ConstXYZT');                                 %   Environment
                %                 loadComponent('CNAPsTurbJames');
                env.water.setflowVec([flwSpd 0 0],'m/s');                   %   m/s - Flow speed vector
                ENVIRONMENT = 'env2turbLinearize';            %   Two turbines
                %%  Set basis parameters for high level controller
               
                loadComponent('constBoothLem');        %   High level controller
%                 PATHGEOMETRY = 'lemOfBoothInv'
                hiLvlCtrl.basisParams.setValue([a,b,el,0,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth

                %             las.tetherLoadDisable;
                %             las.dragDisable;
                %%  Ground Station Properties
                %% Set up pool raft parameters
%                 las.diameter.setValue(.32*.0254,'m')
                theta = 30*pi/180;
                T_tether = 100; %N
                phi_max = 30*pi/180;
                omega_kite = 2*pi/5; %rad/s
                m_raft = 50; %kg
                J_raft = 30;
                tow_length = 16;
                tow_speed = towArray;
                end_time = 30;tow_length/tow_speed;
                x_init = 0;
                y_init = 0;
                y_dot_init = 0;
                psi_init = 0;
                psi_dot_init = 0;
                initGndStnPos = [x_init;0;0];
                thrAttachInit = initGndStnPos;
                %%  Vehicle Properties
                PLANT = 'plant2turb';
                VEHICLE = 'vhclPool';
%                 SENSORS = 'realisticSensors';
                vhcl.stbdWing.setGainCL(vhcl.stbdWing.gainCL.Value/8,'1/deg');
                vhcl.portWing.setGainCL(vhcl.portWing.gainCL.Value/8,'1/deg');
                vhcl.stbdWing.setGainCD(vhcl.stbdWing.gainCD.Value/8,'1/deg');
                vhcl.portWing.setGainCD(vhcl.portWing.gainCD.Value/8,'1/deg');
                vhcl.vStab.setGainCL(vhcl.vStab.gainCL.Value/2,'1/deg');
                vhcl.vStab.setGainCD(vhcl.vStab.gainCD.Value/2,'1/deg');
                if q == 43
                    vhcl.setICsOnPath(.85,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,6.5*abs(flwSpd)*norm([1;0;0]))
                    pos = vhcl.initPosVecGnd.Value;
                    x = pos(1);
                    y = pos(2);
                    z = pos(3);
                    az1 = atan2(y,x);
                    el1 = atan2(z,sqrt(x.^2 + y.^2));
                    las.setThrInitAng([el1 az1],'rad');
                    las.setInitAngVel([-0 0],'rad/s');
                else
                    vhcl.setICsOnPath(0.0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,0);
                    vhcl.setInitEulAng([0 0 0]*pi/180,'rad');
                    %             vhcl.setInitEulAng([180 0 0]*pi/180,'rad');
                    vhcl.setInitVelVecBdy([-towArray 0 0],'m/s');
                    
                    vhcl.initPosVecGnd.setValue([cos(elevArray) 0 sin(elevArray)]*thrLength,'m')
                    pos = vhcl.initPosVecGnd.Value;
                    x = pos(1);
                    y = pos(2);
                    z = pos(3);
                    az1 = atan2(y,x);
                    el1 = atan2(z,sqrt(x.^2 + y.^2));
                    las.setThrInitAng([el1 az1],'rad');
                    las.setInitAngVel([-0 0],'rad/s');
                end
               
                %%  Tethers Properties
                load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
                thr.tether1.initGndNodePos.setValue(thrAttachInit,'m');
                thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
                x = thr.tether1.initGndNodePos.Value(1)-thr.tether1.initAirNodePos.Value(1);
                y = thr.tether1.initGndNodePos.Value(2)-thr.tether1.initAirNodePos.Value(2);
                z = thr.tether1.initGndNodePos.Value(3)-thr.tether1.initAirNodePos.Value(3);
                initThrAng = atan2(z,sqrt(x^2+y^2));
               
                las.setThrInitAng([-initThrAng 0],'rad');
                thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
                thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
                thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
                thr.tether1.youngsMod.setValue(50e9,'Pa');
                thr.tether1.density.setValue(1000,'kg/m^3');
                thr.tether1.setDiameter(.0076,'m');
                thr.setNumNodes(4,'');
                thrDrag =   1.8
                thr.tether1.setDragCoeff(thrDrag,'');
                %%  Winches Properties
                wnch.setTetherInitLength(vhcl,thrAttachInit,env,thr,env.water.flowVec.Value);
%                 wnch.winch1.LaRspeed.setValue(1,'m/s');
                %%  Controller User Def. Parameters and dependant properties
                fltCtrl.setFcnName(PATHGEOMETRY,'');
                fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,thrAttachInit);
                fltCtrl.setPerpErrorVal(.8,'rad')
                fltCtrl.rudderGain.setValue(0,'')
                fltCtrl.rollMoment.kp.setValue(45/3,'(N*m)/(rad)')
                fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
                fltCtrl.rollMoment.kd.setValue(25/3,'(N*m)/(rad/s)')
                fltCtrl.yawMoment.kp.setValue(1,'(N*m)/(rad)')
                fltCtrl.tanRoll.kp.setValue(.1,'(rad)/(rad)')
                thr.tether1.dragEnable.setValue(1,'')
                vhcl.hStab.setIncidence(-6,'deg');
                if q == 3
                    vhcl.hStab.setIncidence(-6,'deg');
                end

                    %                     693
                    fltCtrl.rollAmp.setValue(60,'deg');
                    fltCtrl.yawAmp.setValue(80,'deg');
                    fltCtrl.period.setValue(7.5,'s');
                    fltCtrl.rollPhase.setValue(-pi/2,'rad');
                    fltCtrl.yawPhase.setValue(-pi/2,'rad');
                    if q == 1
                        fltCtrl.startCtrl.setValue(42,'s')
                    else
                        fltCtrl.startCtrl.setValue(0,'s')
                        %                         launchTime = 3.5;
                    end
                   
                   
                    fltCtrl.rollCtrl.kp.setValue(.2143,'(deg)/(deg)');
                    fltCtrl.rollCtrl.ki.setValue(0,'(deg)/(deg*s)');
                    fltCtrl.rollCtrl.kd.setValue(.0555,'(deg)/(deg/s)');
                    fltCtrl.rollCtrl.tau.setValue(0.02,'s');
                   
                   
                   
                   
                    fltCtrl.yawCtrl.kp.setValue(.14,'(deg)/(deg)');
                    fltCtrl.yawCtrl.ki.setValue(0,'(deg)/(deg*s)');
                    fltCtrl.yawCtrl.kd.setValue(.1 ,'(deg)/(deg/s)');
                    fltCtrl.yawCtrl.tau.setValue(0.02,'s');
                   
                    fltCtrl.ccElevator.setValue(0,'deg');
                    fltCtrl.trimElevator.setValue(0,'deg');
                    fltCtrl.searchSize.setValue(0.1,'');
                    share = shareArray(i)
                                 FLIGHTCONTROLLER = 'sharedController';
               fltCtrl.winchSpeedIn.setValue(0,'m/s')
               fltCtrl.firstSpoolLap.setValue(1000,'')
               fluidDensity  = 1000;
                endTime = 25;
                towPer = .1*.33;
                towAmp = 0*.0098;%%  Set up critical system parameters and run simulation
                simParams = SIM.simParams;  simParams.setDuration(end_time,'s');  dynamicCalc = '';
                %                     open_system('OCTModel')
               
                set_param('OCTModel','SimulationMode','accelerator');
                simWithMonitor('OCTModel','minRate',0)
                tsc{i} = signalcontainer(logsout);
                figure;plot(tsc{i}.ctrlSurfDeflCmd);
                figure;plot(tsc{i}.ctrlSurfDefl);
%                 
% vhcl.animateSim(tsc{i},0.5,'endTime',60,'TracerDuration',15,'SaveGif',true)
               
            end
            toc
        end
end
%  tsc=tsc{1}
% figure;plot(tsc.ctrlSurfDeflCmd.Time,tsc.ctrlSurfDeflCmd.Data(:,1))
% vhcl.animateSim(tsc,0.5,'endTime',60,'TracerDuration',15,'SaveGif',true)
% %%
% % figure;
% % plotsq(tsc.desiredMoment.Time,tsc.desiredMoment.Data(1,:,:)/max(tsc.desiredMoment.Data(1,:,10000:end)))
% % hold on
% % plotsq(tsc.velAngleError.Time,tsc.velAngleError.Data)
% % ylim([-2 2])
% % xlabel 'Time [s]'
% % legend('Normalized Desired Roll Moment','Vel Angle Error')
% 
% 
% % bMat = tsc.scaledB
% % figure;
% % hold on;
% % legEnt = {'$\delta M/(\delta_{a}v_{app}^2)$',...
% %     '$\delta M/(\delta_{r}v_{app}^2)$';...
% %     '$\delta L/(\delta_{a}v_{app}^2)$',...
% %     '$\delta L/(\delta_{r}v_{app}^2)$'}
% % color = {'k','r'}
% % lineSpec = {'-','--'}
% % for i = 1:2
% %     for j = 1:2
% %         plotsq(bMat.Time,bMat.Data(i,j,:),'DisplayName',legEnt{i,j},...
% %             'Color',color{j},'LineStyle',lineSpec{i},'LineWidth',1.5)
% %     end
% % end
% % legend('FontSize',15)
% % xlabel 'Time [s]'
% % ylabel 'Control Effectiveness [$\frac{Ns^2}{(deg)m}$]'
% % xlim([5 20])
% % ylim([-.2 .1])
% % set(gca,'FontSize',12)
% % 
% % bMat = tsc.bMatrix
% % figure;
% % hold on;
% % legEnt = {'$\delta M/(\delta_{a})$',...
% %     '$\delta M/(\delta_{r})$';...
% %     '$\delta L/(\delta_{a})$',...
% %     '$\delta L/(\delta_{r})$'}
% % color = {'k','r'}
% % lineSpec = {'-','--'}
% % for i = 1:2
% %     for j = 1:2
% %         plotsq(bMat.Time,bMat.Data(i,j,:),'DisplayName',legEnt{i,j},...
% %             'Color',color{j},'LineStyle',lineSpec{i},'LineWidth',1.5)
% %     end
% % end
% % legend('FontSize',15)
% % xlabel 'Time [s]'
% % ylabel 'Control Effectiveness [$\frac{N-m}{(deg)}$]'
% % % ylim([-.2 .1])
% % xlim([5 20])
% % set(gca,'FontSize',12)
% 
% % figure
% % hold on
% % plot(tsc.yawErr)
% % plot(tsc.rollErr)
% 
% plotVelMags
% 
% figure
% hold on
% plot(tsc.azimuthAngle)
% plot(tsc.elevationAngle)
% legend('az','el')
% 
% % figure
% % tiledlayout(2,2)
% % for i = 1:4
% %     nexttile
% %     plot(tsc.ctrlSurfDefl.Time,tsc.ctrlSurfDefl.Data(:,i))
% %     hold on
% %     plot(tsc.ctrlSurfDeflCmd.Time,tsc.ctrlSurfDeflCmd.Data(:,i))
% %     xlabel 'Time [s]'
% %     ylabel 'Deflection [deg]'
% %     if i  == 1
% %     legend('PID','Path Following')
% %     end
% % end
% 
% % figure
% % plot(tsc.closestPathVariable)
% 
% figure
% plot(tsc.elevationAngle)
% hold on
% plot(tsc.theta*180/pi)
% plot(tsc.lasElevDeg)
% 
% figure
% plot(tsc.azimuthAngle)
% hold on
% plot(tsc.phi*180/pi)
% 
% gndTen = squeeze(tsc.gndNodeTenVecs.Data);
% timeVec = tsc.gndNodeTenVecs.Time;
% gndTenMag = sqrt(dot(gndTen,gndTen));
% figure
% plot(timeVec,gndTenMag)
% xlim([2 inf])
% xlabel 'Time [s]'
% ylabel 'Tension Magnitude [N]'
% 
% pos = squeeze(tsc.positionVec.Data);
% posEst = squeeze(tsc.positionVecEst.Data);
% vel = squeeze(tsc.velocityVec.Data);
% velEst = squeeze(tsc.velocityVecEst.Data);
% %%
% r = thrLength;
% az = tsc.phi.Data;
% el = -tsc.lasElevDeg.Data*pi/180;
% posEstBoom = positionEstimate(r,el,az);
% 
% figure
% tiledlayout(3,1)
% labelCell = {'X-Pos [m]','Y-Pos [m]','Z-Pos [m]'}
% for i = 1:3
%     nexttile
%     plot(timeVec,pos(i,:))
%     hold on
%     plot(timeVec,posEst(i,:))
%     xlabel 'Time [s]'
%     ylabel(labelCell{i})
%     xlim([2 inf])
%     if i == 1
%         legend('Kite Position','LAS Estimate')
%     end
% end
% 
% figure
% tiledlayout(3,1)
% labelCell = {'X-Vel [m/s]','Y-Vel [m/s]','Z-Vel [m/s]'}
% for i = 1:3
%     nexttile
%     plot(timeVec,vel(i,:))
%     hold on
%     plot(timeVec,velEst(i,:))
%     xlabel 'Time [s]'
%     ylabel(labelCell{i})
%     if i == 1
%         legend('Kite Velocity','LAS Predicted')
%     end
%     xlim([2 inf])
% end
% 
% 
% 
% figure
% plot(timeVec,(dot(vel,vel)))
% hold on
% plot(timeVec,(dot(velEst,velEst))*1.15)
% xlim([3 inf])
% xlabel 'Time [s]'
% ylabel '$V_{app}^2$ [$(m/s)^2$]'
% legend('Kite Velocity','1.1$V_{app,LAS}^2$')
%%

fPath = 'C:\Users\adabney\iCloudDrive\NCSU HW Uploads\'

figure('Position',[100 100 800 600])
tiledlayout(2,3)
for i =1:6
    nexttile
    plot(tsc{i}.closestPathVariable)
    title(sprintf('%.1f PID, %.1f Path Following',1-(i-1)*.2,(i-1)*.2))
    if i == 1 || i == 4
        ylabel 's'
    else
        ylabel ''
    end
    if i > 4
        xlabel 'Time [s]'
    else
        xlabel ''
    end
end

fName = 'pathParam'
saveas(gcf,[fPath fName],'png')
saveas(gcf,[fPath fName],'fig')

figure('Position',[100 100 800 600])
tiledlayout(2,3)
for i =1:6
    nexttile
    hold on;
    plotsq(tsc{i}.positionVec.Time,tsc{i}.positionVec.Data(3,1,:))
    plot([0 30],[1 1]*.847/2);
    title(sprintf('%.1f PID, %.1f Path Following',1-(i-1)*.2,(i-1)*.2))
    if i == 1
        legend('CG Location','~Wing out of water')
    end
    if i == 1 || i == 4
        ylabel 'Z-Position [m]'
    else
        ylabel ''
    end
    if i > 4
        xlabel 'Time [s]'
    else
        xlabel ''
    end
end

fName = 'zPosition'
saveas(gcf,[fPath fName],'png')
saveas(gcf,[fPath fName],'fig')

figure('Position',[100 100 800 600])
tiledlayout(2,3)
for i =1:6
    nexttile
    hold on
    plot(tsc{i}.ctrlSurfDeflCmd.Time,tsc{i}.ctrlSurfDeflCmd.Data(:,1))
    plot(tsc{i}.ctrlSurfDeflCmd.Time,tsc{i}.ctrlSurfDefl.Data(:,1))
    plot(tsc{i}.ctrlSurfDeflCmd.Time,tsc{i}.ctrlSurfDeflCmd.Data(:,1)*(i-1)*0.2...
        +tsc{i}.ctrlSurfDefl.Data(:,1)*(1-(i-1)*.2))    
    if i == 1
        legend('Path Following','PID','Shared Control')
    end
    title(sprintf('%.1f PID, %.1f Path Following',1-(i-1)*.2,(i-1)*.2))
    if i == 1 || i == 4
        ylabel 'Aileron Deflection [deg]'
    else
        ylabel ''
    end
    if i > 4
        xlabel 'Time [s]'
    else
        xlabel ''
    end
end


fName = 'aileronDefl'
saveas(gcf,[fPath fName],'png')
saveas(gcf,[fPath fName],'fig')

function est = positionEstimate(r,el,az)
x = r .* cos(el) .* cos(az);
y = r .* cos(el) .* sin(az);
z = r .* sin(el);
est = [x y z]';
end