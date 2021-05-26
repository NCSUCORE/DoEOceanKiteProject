%% Test script for pool test simulation of the kite model
clear;clc;close all;
Simulink.sdi.clear
%%  Set Test Parameters
saveSim = 0;               %   Flag to save results
runLin = 0;                %   Flag to run linearization
thrArray = 2.63;%[200:400:600];%:25:600];
altitudeArray = 2.63*sind(40);%[100:200:300];%150:25:300];
flwSpdArray = -0.0001;%[0.1:0.1:.5];
inc = -4%[-6:2:-2];
towArray = ([.524 .651 .801])';%rpm2speed([50 65 80]);%[0.5:.15:.8];
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];

for i = 1:length(inc)
    for j = 1:length(towArray)
        thrLength = 2.63;  altitude = thrLength*sin(40/180*pi);                 %   Initial tether length/operating altitude/elevation angle
        flwSpd = -.0001 ;                                   %   m/s - Flow speed
        Tmax = 38;                                                  %   kN - Max tether tension
        h = 25*pi/180;  w = 100*pi/180;                             %   rad - Path width/height
        [a,b] = boothParamConversion(w,h);                          %   Path basis parameters
        %%  Load components
        fpath = fullfile(fileparts(which('OCTProject.prj')),...
            'vehicleDesign\Tether\Tension\');
        maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
        el = asin(altitude/thrLength);
        loadComponent('exp_slCtrl');
        % loadComponent('pathFollowCtrlExp');                         %   Path-following controller with AoA control
        % FLIGHTCONTROLLER = 'pathFollowingControllerExp';
        loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
        % loadComponent('MantaGndStn');                             %   Ground station
        loadComponent('raftGroundStation');
        
        
        loadComponent('winchManta');                                %   Winches
        loadComponent('MantaTether');                               %   Manta Ray tether
        loadComponent('idealSensors')                               %   Sensors
        loadComponent('idealSensorProcessing')                      %   Sensor processing
        loadComponent('Manta2RotXFoil_AR8_b8_exp_3dPrinted');                %   AR = 8; 8m span
%         SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen12int";
        %%  Environment Properties
        loadComponent('ConstXYZT');                                 %   Environment
        env.water.setflowVec([flwSpd 0 0],'m/s');                   %   m/s - Flow speed vector
        ENVIRONMENT = 'environmentManta2Rot';            %   Two turbines
        %%  Set basis parameters for high level controller
        
        loadComponent('constBoothLem');        %   High level controller
        % PATHGEOMETRY = 'lemOfBoothInv'
        % hiLvlCtrl.elevationLookup.setValue(maxT.R.EL,'deg');
        %
        % hiLvlCtrl.ELctrl.setValue(1,'');
        % hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
        % hiLvlCtrl.ThrCtrl.setValue(1,'');
        
        hiLvlCtrl.basisParams.setValue([a,b,-el,180*pi/180,thrLength-.1],'[rad rad rad rad m]') % Lemniscate of Booth
        %%  Ground Station Properties
        %% Set up pool raft parameters
        theta = 30*pi/180;
        T_tether = 100; %N
        phi_max = 30*pi/180;
        omega_kite = 2*pi/5; %rad/s
        m_raft = 50; %kg
        J_raft = 30;
        tow_length = 16;
        tow_speed = towArray(j);
        end_time = tow_length/tow_speed;
        x_init = 4;
        y_init = 0;
        y_dot_init = 0;
        psi_init = 0;
        psi_dot_init = 0;
        initGndStnPos = [x_init;y_init;3];
        
        thrAttachInit = initGndStnPos;
        %%  Vehicle Properties
        % vhcl.setICsOnPath(.85,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,6.5*abs(flwSpd)*norm([1;0;0]))
        vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,0);
%         vhcl.setInitEulAng([180 0 180]*pi/180,'rad');
        vhcl.setInitEulAng([0 0 0]*pi/180,'rad');
        vhcl.setInitVelVecBdy([-0.01 0 0],'m/s');
        %%  Tethers Properties
        load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
        thr.tether1.initGndNodePos.setValue(thrAttachInit,'m');
        thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
            +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
        thr.tether1.initGndNodeVel.setValue([-tow_speed 0 0]','m/s');
        thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
        thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
        thr.tether1.youngsMod.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tmax))/5*100,'Pa');
        thr.tether1.density.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.density',Tmax)),'kg/m^3');
        thr.tether1.setDiameter(.0012,'m');
%         thr.setNumNodes(20,'');
        thr.tether1.setDragCoeff(1.288,'');
        %%  Winches Properties
        wnch.setTetherInitLength(vhcl,thrAttachInit,env,thr,env.water.flowVec.Value);
        wnch.winch1.LaRspeed.setValue(1,'m/s');
        %%  Controller User Def. Parameters and dependant properties
        fltCtrl.setFcnName(PATHGEOMETRY,'');
        fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,thrAttachInit);
        fltCtrl.setPerpErrorVal(.25,'rad')
        fltCtrl.rudderGain.setValue(0,'')
        fltCtrl.rollMoment.kp.setValue(50,'(N*m)/(rad)')
        fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
        fltCtrl.rollMoment.kd.setValue(25,'(N*m)/(rad/s)')
        fltCtrl.tanRoll.kp.setValue(.45,'(rad)/(rad)')
        thr.tether1.dragEnable.setValue(1,'')
        vhcl.hStab.setIncidence(inc(i),'deg');
        
        
%         vhcl.stbdWing.setCL(zeros(length(vhcl.stbdWing.CL.Value),1),'');
%         vhcl.stbdWing.setCD(zeros(length(vhcl.stbdWing.CD.Value),1),'');
%         vhcl.portWing.setCL(zeros(length(vhcl.portWing.CL.Value),1),'');
%         vhcl.portWing.setCD(zeros(length(vhcl.portWing.CD.Value),1),'');
%         vhcl.vStab.setCL(zeros(length(vhcl.vStab.CL.Value),1),'');
%         vhcl.vStab.setCD(zeros(length(vhcl.vStab.CD.Value),1),'');
%         vhcl.hStab.setCL(zeros(length(vhcl.hStab.CL.Value),1),'');
%         vhcl.hStab.setCD(zeros(length(vhcl.hStab.CD.Value),1),'');
%         vhcl.portWing.setGainCL(0,'1/deg');
%         vhcl.portWing.setGainCD(0,'1/deg');
%         vhcl.stbdWing.setGainCL(0,'1/deg');
%         vhcl.stbdWing.setGainCD(0,'1/deg');
%         vhcl.vStab.setGainCL(0,'1/deg');
%         vhcl.vStab.setGainCD(0,'1/deg');
%         vhcl.hStab.setGainCL(0,'1/deg');
%         vhcl.hStab.setGainCD(0,'1/deg');
%         vhcl.fuse.setEndDragCoeff(0,'');
%         vhcl.fuse.setSideDragCoeff(0,'');
%         vhcl.setBuoyFactor(1,'');
%         vhcl.setVolume(.01,'m^3');
%         vhcl.setRBridle_LE([0,0,0],'m');
%         vhcl.setRCM_LE([0,0,0],'m');
%         vhcl.setRCentOfBuoy_LE([0,0,0],'m');
%         vhcl.setMa6x6_LE(zeros(6),'')
        
        %%  Set up critical system parameters and run simulation
        simParams = SIM.simParams;  simParams.setDuration(end_time,'s');  dynamicCalc = '';
            open_system('OCTModel')
            set_param('OCTModel','SimulationMode','accelerator');
        simWithMonitor('OCTModel')
        tsc1{i,j} = signalcontainer(logsout);
        %
%         totalDrag = sum(squeeze(sum(tsc1{i,j}.thrDragVecs.Data,2)).^2,1).^.5;
        
    end
end


%% Process Test Data
selPath = uigetdir;
listing = dir(selPath);

selPath2 = uigetdir;
listing2 = dir(selPath2);
figure; hold on; grid on;
for i = 1:19
    if i<11
        load(strcat(selPath,'\',listing(i+3).name));
        tscData{i} = tsc;
    else
        load(strcat(selPath2,'\',listing2(i-7).name));
        tscData{i} = tsc;
    end
    a = find(tsc.speedCMD1.Data> 1,1);
    speed(i) = tsc.speedCMD1.Data(a);
    tscData{i}.linSpeed = tsc.speedCMD1.Data(a);
    tscData{i}.a = a;
%     plot(tsc.speedCMD1.Time(a:end),tsc.speedCMD1.Data(a:end))
end
desRPM = [0 50 50 50 65 65 65 80 80 80];
figure
plot(speed*30,'x','DisplayName','Commanded RPM')
hold on
plot(desRPM,'o','DisplayName','Test Plan RPM')
xlabel('Test Run')
ylabel('RPM')
legend location southeast




%% Plot Test Data
towArray = [.47 .62 .77]
l = 2.63-.52; %tether arc length @ LAS
CdCyl = 1%:.01:1.2
mCyl = 1.3285 ; %kg mass of cylinder
dCyl = 1.5*.0254; %m diameter of cylinder
rhoCyl = 7850; %kg/m^3 density of 304
lCyl = 4*mCyl/(pi*rhoCyl*dCyl^2)
fCyl = mCyl*9.81-1000*pi*dCyl^2/4*lCyl*9.81
fDragCyl = 0.5*1000*towArray.^2*CdCyl*dCyl*lCyl
denom = 0.5*1000*towArray.^2*0.0076*l
T1 = sqrt(fCyl^2+fDragCyl.^2)
dataSeg = {[2:10],[12:20],[21:29],[30:38]};
figure;
for j = 1%:numel(dataSeg)


        
        q1 = 1; q2 =1; qq1 = 1; qq2 = 1; qqq1 = 1; qqq2 = 1;
        for i = 1:19%dataSeg{j}
            a = tscData{i}.a
            %     rmsCalc = tscData{i}.El_deg.getsampleusingtime...
            %         (tscData{i}.El_deg.Time(a),tscData{i}.El_deg.Time(a)+30)
            %     rmsDeg(i) = rms(rmsCalc.Data);
            %     meanDeg(i) = mean(rmsCalc.Data);
            if tscData{i}.linSpeed > 1.66 && tscData{i}.linSpeed < 1.68
                rmsCalc = tscData{i}.kite_elev.getsampleusingtime...
                    (tscData{i}.kite_elev.Time(a)+15,tscData{i}.kite_elev.Time(a)+30)
                rmsDeg(i) = rms(rmsCalc.Data);
                meanDeg(i) = mean(rmsCalc.Data);
                stdDev(i) = std(rmsCalc.Data)
                cDT(i,:) = (cot(meanDeg(i)*pi/180)-fDragCyl(1)/fCyl)*T1(1)./denom(1)
                subplot(1,3,1); hold on; grid on;
                set(gca,'FontSize',20)
                if i<11
                plot(tscData{i}.kite_elev.Time(tscData{i}.a:end)...
                    -tscData{i}.kite_elev.Time(tscData{i}.a),...
                    tscData{i}.kite_elev.Data(tscData{i}.a:end),...
                    '-','DisplayName',sprintf('Old winch run %d',q1));
                q1 = q1+1
                else
                    plot(tscData{i}.kite_elev.Time(tscData{i}.a:end)...
                    -tscData{i}.kite_elev.Time(tscData{i}.a),...
                    tscData{i}.kite_elev.Data(tscData{i}.a:end),...
                    '--','DisplayName',sprintf('New Winch run %d',q2));
                q2 = q2+1
                end
%                 plot([15 30],[meanDeg(i) meanDeg(i)],'LineStyle','--','DisplayName',sprintf('Mean Elevation Run %d',q))
%                 q = q+1;
                ylim([30,90])
                xlim([0 40])
                xlabel 'Time [s]'
                ylabel 'Elevation Angle [deg]'
                title(sprintf('%.2f m/s',towArray(1)))
                legend('Location','northeast','FontSize',14)
            elseif tscData{i}.linSpeed > 2.16 && tscData{i}.linSpeed < 2.17
                rmsCalc = tscData{i}.kite_elev.getsampleusingtime...
                    (tscData{i}.kite_elev.Time(a)+10,tscData{i}.kite_elev.Time(a)+20)
                rmsDeg(i) = rms(rmsCalc.Data);
                meanDeg(i) = mean(rmsCalc.Data);
                stdDev(i) = std(rmsCalc.Data)
                cDT(i,:) = (cot(meanDeg(i)*pi/180)-fDragCyl(2)/fCyl)*T1(2)./denom(2)
                subplot(1,3,2); hold on; grid on;
                set(gca,'FontSize',20)
                if i < 11
                plot(tscData{i}.kite_elev.Time(tscData{i}.a:end)...
                    -tscData{i}.kite_elev.Time(tscData{i}.a),...
                    tscData{i}.kite_elev.Data(tscData{i}.a:end),...
                    '-','DisplayName',sprintf('Old winch run %d',qq1));
                qq1 = qq1+1
                else
                    plot(tscData{i}.kite_elev.Time(tscData{i}.a:end)...
                    -tscData{i}.kite_elev.Time(tscData{i}.a),...
                    tscData{i}.kite_elev.Data(tscData{i}.a:end),...
                    '--','DisplayName',sprintf('New winch run %d',qq2));
                qq2 = qq2+1
                end
%                 plot([10 20],[meanDeg(i) meanDeg(i)],'LineStyle','--','DisplayName',sprintf('Mean Elevation Run %d',qq))
%                 qq = qq+1;
                ylim([30,90])
                xlim([0 40])
                xlabel 'Time [s]'
                ylabel 'Elevation Angle [deg]'
                title(sprintf('%.2f m/s',towArray(2)))
                legend('Location','northeast','FontSize',14)
            elseif tscData{i}.linSpeed > 2.6 && tscData{i}.linSpeed < 2.7
                subplot(1,3,3); hold on; grid on;
                set(gca,'FontSize',20)
                if i < 11
                plot(tscData{i}.kite_elev.Time(tscData{i}.a:end)...
                    -tscData{i}.kite_elev.Time(tscData{i}.a),...
                    tscData{i}.kite_elev.Data(tscData{i}.a:end),...
                    '-','DisplayName',sprintf('Old winch run %d',qqq1));
                qqq1 = qqq1+1
                else
                    plot(tscData{i}.kite_elev.Time(tscData{i}.a:end)...
                    -tscData{i}.kite_elev.Time(tscData{i}.a),...
                    tscData{i}.kite_elev.Data(tscData{i}.a:end),...
                    '--','DisplayName',sprintf('New winch run %d',qqq2));
                qqq2 = qqq2+1
                end
                rmsCalc = tscData{i}.kite_elev.getsampleusingtime...
                    (tscData{i}.kite_elev.Time(a)+7,tscData{i}.kite_elev.Time(a)+13)
                meanDeg(i) = mean(rmsCalc.Data);
                stdDev(i) = std(rmsCalc.Data)
%                 predElev = acot(l*0.5*1000*towArray(3)^2*2.62*0.0076/T1(3)+fDragCyl(3)/fCyl)*180/pi
%                 plot([5 20],[predElev predElev],'DisplayName','Predicted Elevation')
%                 qqq = qqq+1;
                ylim([30,90])
                xlim([0 40])
                xlabel('Time [s]')
                ylabel 'Elevation Angle [deg]'
                title(sprintf('%.2f m/s',towArray(3)))
                legend('Location','northeast','FontSize',14)
            else
            end
        end
        cdMean = mean([cDT(11:16)])
        cdStd = std([cDT(11:16)])
           predElev = acot(l*0.5*1000*towArray(3)^2*(cdMean)*0.0076/T1(3)+fDragCyl(3)/fCyl)*180/pi
        
           predElevPos = acot(l*0.5*1000*towArray(3)^2*(cdMean+2*cdStd)*0.0076/T1(3)+fDragCyl(3)/fCyl)*180/pi
            predElevNeg = acot(l*0.5*1000*towArray(3)^2*(cdMean-2*cdStd)*0.0076/T1(3)+fDragCyl(3)/fCyl)*180/pi
        subplot(1,3,3); hold on; grid on;
                plot([5 20],[predElevNeg predElevNeg],'LineStyle','--','DisplayName',sprintf('$C_{D}$ = %.2f',cdMean-2*cdStd))
        plot([5 20],[predElev predElev],'LineStyle','--','DisplayName',sprintf('$C_{D}$ = %.2f',cdMean))
        plot([5 20],[predElevPos predElevPos],'LineStyle','--','DisplayName',sprintf('$C_{D}$ = %.2f',cdMean+2*cdStd))
%      
        
        figure
        v = 0:.01:2;
        fDC = 0.5*1000*v.^2*CdCyl*dCyl*lCyl;
        denom = 0.5*1000*v.^2*0.0076*l;
        T1 = sqrt(fCyl^2+fDC.^2);
        predElev = acot(l*0.5*1000*v.^2*1.8*0.0076./T1+fDC/fCyl)*180/pi;
        delevdv = diff(predElev)/.01
        plot(v,predElev,'DisplayName','$\theta$ [deg]')
        hold on
        plot(v(1:end-1),delevdv,'DisplayName','$\frac{\partial \theta}{\partial V_{\infty}}$ [deg-s/m]')
        xlabel('$V_{\infty}$')
        legend
        
%             plot([5 20],[predElevNeg predElevNeg],'LineStyle','--','DisplayName',sprintf('CD = %.2f',cdMean-2*cdStd))

%cdt = cot(

figure
plot(1:10,stdDev(1:10),'x')
hold on; grid on;
plot(11:19,stdDev(11:19),'s')
legend('Old Winch','New Winch')
xlabel 'Run'
ylabel 'Standard Deviation of Elevation Angle [deg]'
end
function [linSpeed] = rpm2speed(rpm)

p1 =    0.008441;  %(-0.01554, 0.03243)
p2 =      0.2241;  %(-1.362, 1.811)

linSpeed = p1*rpm + p2;
end