%% Test script for John to control the kite model
% clear all;
% clc
% close all;
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
simScenario = [1 1 1 3 1 1==0  1==0 1==1];
yawlessLaps=0;
pathLaps=8;
thrSweep = 500%:1000:4000;
altSweep = 1;
flwSweep = 1;%0.5:0.25:2;
flowMult = 0.1%:0.1:1;
x = meshgrid(thrSweep,altSweep,flowMult);
intSat=25;
posAug=1;
thetaIGain=-0.01;
thetaPGain=-3;
numNodes=8;
elevSet=37.5;
elevStart=47;
yawP=1.25e5*0.1*1;
yawD=1*yawP*2;
yawI=0.0*yawP;

[n,m,r] = size(x);
numCase = n*m*r;
powGen = zeros(n,m,r);
pathErr = zeros(n,m,r);
dragRatio = zeros(n,m,r);
Pow = cell(n,m,r);
fpath = ['C:\Users\jbfine\OneDrive - North Carolina State University\PosAug\DoEOceanKiteProject-master\DoEOceanKiteProject-master\posAugResults\'];

for i = 1:n
    if i < 1
        continue
    end
    for j = 1:m
        if j < 1
            continue
        end
        k = 1;
        while k == 1%200*k<=thrSweep(j)/2
            for ii = 1
                fprintf(sprintf('%.2f Percent Complete\n',((i-1)*m*r+(j-1)*r+k)/(n*m*r)*100))
                Simulink.sdi.clear
                %  Set Test Parameters
                tFinal = 10000;      tSwitch = 10000;                        %   s - maximum sim duration
                flwSpd = flwSweep;                                              %   m/s - Flow speed
                altitude = thrSweep(j)/2;                   %   m/m - cross-current and initial altitude

                thrLength = thrSweep(j);
                el = asin(altitude/thrLength);                              %   rad - Initial elevation angle
                if el*180/pi >= 50
                    continue
                end

                height = 0:25:2200;
                hNom = altitude;
                v = [0.25 1]*flwSpd;
                z = [hNom-200*k hNom];
                flow = flowDist(height,z,v);

                if ii == 1
                    b = 20;
                    a = 60;
                else
                    b = 30;
                    a = 120;
                end
                d = 1;
%                 loadComponent('ultDoeKite')
%                 VEHICLE = 'vhcl4turb';

                loadComponent('Manta71522')
                VEHICLE = 'vhcl4turb';


            vhcl.fuse.CD.setValue([],'');



            rotEff=[20	30	40	50	60	70	80	90	100	110	120	170	220	270	320	370; 0.635300000000000	0.702000000000000	0.741700000000000	0.764200000000000	0.797800000000000	0.814200000000000	0.824700000000000	0.844300000000000	0.852200000000000	0.866300000000000	0.861100000000000	0.890500000000000	0.904100000000000	0.899100000000000	0.917400000000000	0.911500000000000];

            vhcl.hStab.rSurfLE_WingLEBdy.setValue(vhcl.hStab.rSurfLE_WingLEBdy.Value-[.19;0;0],'m')




                loadComponent('constBoothLem');
                hiLvlCtrl.basisParams.setValue([a,b,altitude,0*pi/180,... %   Initialize basis parameters
                    thrLength],'[rad rad rad rad m]');

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
%                 
%                 vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
% vhcl.setInitVelVecBdy([0,0,0],'m/s')

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


thr.tether1.dragCoeff.setValue(1.2,'')
thr.numNodes.setValue(numNodes,'');
thr.tether1.numNodes.setValue(numNodes,'');
thr.tether1.dampingRatio.setValue(.1,'')
                thr.tether1.setDensity(1000,'kg/m^3');
                thr.tether1.diameter.setValue(0.022,'m');

                fltCtrl.Tmax.setValue(100,'kN');
%                 TETHERS = 'tetherFaired'
% % 
%                     loadComponent('fairedNNodeTether');                       %   Manta Ray tether
%                     thr.numNodes.setValue(6,'')
%                     thr.tether1.numNodes.setValue(6,'');
%                     thr.tether1.fairedLinks.setValue(2,'');
%                     thr.tether1.setDensity(1187.1,'kg/m^3');
%                     thr.tether1.setDiameter(0.018,'m');
% 
%                 thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
%                 thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
%                     +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
%                 thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
%                 thr.tether1.initAirNodeVel.setValue(rotation_sequence(vhcl.initEulAng.Value)*vhcl.initVelVecBdy.Value(:),'m/s');
%                 thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
% %Choose Tether
% 
% 
% thr.tether1.dragCoeff.setValue(1.3,'')
% thr.tether1.fairedLength.setValue(100,'m');
% thr.tether1.fairedDragCoeff.setValue(0.18,'');
% thr.tether1.dampingRatio.setValue(.1,'')

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
                fltCtrl.pitchMoment.kp.setValue(60000,fltCtrl.pitchMoment.kp.Unit)
                %             fltCtrl.pitchMoment.ki.setValue(5000,fltCtrl.pitchMoment.ki.Unit)
                fltCtrl.AoAConst.setValue(10*pi/180,'deg')
                fltCtrl.perpErrorVal.setValue(0.4,'rad')

fltCtrl.yawMoment.kp.setValue(yawP,fltCtrl.yawMoment.kp.Unit);
fltCtrl.yawMoment.kd.setValue(yawD,fltCtrl.yawMoment.kd.Unit);
fltCtrl.yawMoment.ki.setValue(yawI,fltCtrl.yawMoment.ki.Unit);

 fltCtrl.pitchMoment.kp.setValue(2.5e4,fltCtrl.yawMoment.kp.Unit);
 fltCtrl.pitchMoment.kd.setValue(0.75e4,fltCtrl.yawMoment.kd.Unit);
 fltCtrl.pitchMoment.ki.setValue(0.5e4,fltCtrl.yawMoment.ki.Unit);

                turbAng = 0;
                turbAngVec = [cosd(turbAng);0;sind(turbAng)];
                vhcl.turb1.axisUnitVec.setValue(turbAngVec,'')
                vhcl.turb2.axisUnitVec.setValue(-turbAngVec,'')
               % vhcl.turb3.axisUnitVec.setValue(turbAngVec,'')
              %  vhcl.turb4.axisUnitVec.setValue(-turbAngVec,'')
                %%  Set up critical system parameters and run simulation
                                 FLOWCALCULATION = 'flowColumnSpec';
                                                 FLIGHTCONTROLLER="posAug";

                simParams = SIM.simParams;  simParams.setDuration(tFinal,'s');  dynamicCalc = '';
                progress = sprintf('%d Thr %.1f Altitude %.2f Flow Speed %d m Shear Layer Path %d\n',...
                    thrLength,altitude,flwSpd,k*200,ii);
                fprintf(progress)

                simWithMonitor('OCTModel','timeStep',2,'minRate',1)
                %%  Log Results
                tsc = signalcontainer(logsout);
                %             tsc = tsc.resample(0:0.1:tsc.positionVec.Time(end));
                %             plotRotorInfo
                % %             lap = max(tsc.lapNumS.Data)-1;
                %             tsc.plotFlightResults(vhcl,env,thr,fltCtrl,'plot1Lap',1==1,'plotS',1==0,'lapNum',lap,'dragChar',1==0,'cross',1==0)
                if simScenario(3) == 1
                    Pow{i,j,k} = tsc.rotPowerSummary(vhcl,env,thr);
                    [Idx1,Idx2,lapCheck] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;

                    %                 fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);
                end
                    fString = 'Sensitivity';
                if ii == 2
                    fString = ['BP' fString];
                end
                filename = sprintf(strcat(fString,'_V-0.75_shearLayer-%d_Alt-%d_thr-%d.mat'),200*k,altitude,thrLength);

                if simScenario(6)
                    save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
                end
            end
            k = k+1;
        end
    end
end
%%
pathMeanPower=mean(tsc.netPower.Data(tsc.lapNumS.Data==max(tsc.lapNumS.Data)-3))

rollSPs=tsc.rollSP.Data;
count=0;

for i=2:numel(rollSPs)

    if tsc.lapNumS.Data(i)==max(tsc.lapNumS.Data) && ( rollSPs(i-1)>0 && rollSPs(i)<0)

        count=count+1;
        
        if count==19

            startI=i;
        end

       if count==20

            endI=i;
            break
        end
    end

end



orientMeanPower=mean(tsc.netPower.Data(startI:endI))

count=0;

for i=2:numel(rollSPs)

    if tsc.elvSP.Data(i)==elevSet   && ( rollSPs(i-1)>0 && rollSPs(i)<0)

        count=count+1;
        
        if count==19

            startI2=i;
        end

       if count==20

           endI2=i;
            break
        end
    end

end

posAugMeanPower=mean(tsc.netPower.Data(startI2:endI2))




orientFrac=orientMeanPower/pathMeanPower

posAugFrac=posAugMeanPower/pathMeanPower
%%

tsc.elvSP.Data(tsc.thetaTerm.Data==0)=NaN;
tsc.elvSP.Data(tsc.lapNumS.Data<11)=30;

figure;
tsc.elevationAngle.plot;
hold on;
grid on;
tsc.elvSP.plot('--','lineWidth',1);
xlabel('Time (s)')
ylabel('Elevation Angle (deg)')

title('Elevation Angle vs Time')
legend({'Elv','SP'})
%%

figure;
hold on; grid on;
tsc.netPower.plot
title('Net Power Generated Vs Time')












% %% Test script for John to control the kite model
% % clear all;
% % clc
% % close all;
% Simulink.sdi.clear
% %% Simulation Setup
% % 1 - Vehicle Model:         1 = AR8b8, 2 = AR9b9, 3 = AR9b10
% % 2 - High-level Controller: 1 = const basis, 2 = const basis/stategit  flow
% % 3 - Flight controller:     1 = pathFlow, 2 = full cycle
% % 4 - Tether Model:          1 = Single link, 2 = Reel-in, 3 = Multi-node, 4 = Multi-node faired
% % 5 - Environment:           1 = const flow, 2 = variable flow
% % 6 - Save Results
% % 7 - Animate
% % 8 - Plotting
% %%             1 2 3 4 5 6     7     8
% simScenario = [1 1 1 3 1 1==0  1==0 1==1];
% thrSweep = 500%:1000:4000;
% altSweep = [250];
% flwSweep = [1];%0.5:0.25:2;
% x = meshgrid(thrSweep,altSweep,flwSweep);
% intSat=25;
% posAug=1;
% thetaIGain=-0.01;
% thetaPGain=-3;
% numNodes=8;
% elevSet=35;
% elevStart=45;
% yawP=1.25e5;
% yawD=1*yawP;
% yawI=0.0*yawP;
% 
% [n,m,r] = size(x);
% numCase = n*m*r;
% powGen = zeros(n,m,r);
% pathErr = zeros(n,m,r);
% dragRatio = zeros(n,m,r);
% Pow = cell(n,m,r);
% fpath = ['\\cuifile1.sure.ad.ncsu.edu\cvermil00\Documents\Results\posAugFS\Data\'];
% 
% for thrI = 1:n
%     if thrI < 1
%         continue
%     end
%     for altI = 1:m
%         if altI < 1
%             continue
%         end
%         flwI = 1;
%         while flwI <= numel(flwSweep)
%             for ii = 1
%                 fprintf(sprintf('%.2f Percent Complete\n',((thrI-1)*m*r+(altI-1)*r+flwI)/(n*m*r)*100))
%                 Simulink.sdi.clear
%                 %  Set Test Parameters
%                 tFinal = 10000;      tSwitch = 10000;                        %   s - maximum sim duration
%                 flwSpd = flwSweep(flwI);                                              %   m/s - Flow speed
%                 altitude =altSweep(altI);                   %   m/m - cross-current and initial altitude
%                 thrLength = thrSweep(thrI);
% 
% 
% 
%                 el = asin(altitude/thrLength);                              %   rad - Initial elevation angle
%                 if el*180/pi >= 50
%                     continue
%                 end
% 
%                 height = 0:25:2200;
%                 hNom = altitude;
%                 v = [0.25 1]*flwSpd;
%                 z = [hNom-200*flwI hNom];
%                 flow = flowDist(height,z,v);
% 
%      
%                     b = 20;
%                     a = 60;
%    
%                 %loadComponent('Manta71522')
%                                 loadComponent('ultDoeKite')
% 
%                 VEHICLE = 'vhcl4turb';
% 
%                 loadComponent('constBoothLem');
%                 hiLvlCtrl.basisParams.setValue([a,b,altitude,0*pi/180,... %   Initialize basis parameters
%                     thrLength],'[rad rad rad rad m]');
% 
%                 loadComponent('pathFollowWithAoACtrlDOE');             %   Path-following controller with AoA control
%                 loadComponent('pathFollowingTether');                       %   Manta Ray tether
%                 loadComponent('ConstXYZT');                         %   Constant flow
%                 ENVIRONMENT = 'env4turb';                           %   Two turbines
%                 env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
%                 loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
%                 loadComponent('oneThrGndStn000');
%                 GROUNDSTATION = 'GroundStation000';%   Ground station
%                 loadComponent('oneWnch');
%                 WINCH = 'constThr';%   Winches
%                 loadComponent('idealSensors')                               %   Sensors
%                 loadComponent('idealSensorProcessing')                      %   Sensor processing
%                 %             SENSORS = 'deadRecPos'
%                 %%  Vehicle Initial Conditions
%                 %   Constant basis parameters
%                 PATHGEOMETRY = 'lemBoothNew';
%                 if simScenario(3) == 1
%                     if simScenario(2) == 4
%                         vhcl.setICsOnPath(0.875,PATHGEOMETRY,hiLvlCtrl.initBasisParams.Value,gndStn.posVec.Value,2*flwSpd)
%                     else
%                         vhcl.setICsOnPath(0.875,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,2*flwSpd)
%                     end
%                 else
%                     vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
%                     vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
%                 end
% 
%                 %%  Tethers Properties
%                 %   kN - candidate tether tension limits
%                 fltCtrl.Tmax.setValue(22,'kN');
% %                 TETHERS = 'tetherFaired'
%                 thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
%                 thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
%                     +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
%                 thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
%                 thr.tether1.initAirNodeVel.setValue(rotation_sequence(vhcl.initEulAng.Value)*vhcl.initVelVecBdy.Value(:),'m/s');
%                 thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
% %Choose Tether
% 
% 
% thr.tether1.dragCoeff.setValue(1.2,'')
% thr.numNodes.setValue(numNodes,'');
% thr.tether1.numNodes.setValue(numNodes,'');
% thr.tether1.dampingRatio.setValue(.1,'')
%                 thr.tether1.setDensity(1000,'kg/m^3');
%                 thr.tether1.diameter.setValue(0.018,'m');
%                 %%  Winches Properties
%                 wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
%                 %             wnch.winch1.LaRspeed.setValue(1,'m/s');
%                 %%  Controller User Def. Parameters and dependant properties
%                 fltCtrl.setFcnName(PATHGEOMETRY,'');
%                 if simScenario(2) == 4
%                     fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.initBasisParams.Value,gndStn.posVec.Value);
%                 else
%                     fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
%                 end
%                 fltCtrl.pitchMoment.kp.setValue(60000,fltCtrl.pitchMoment.kp.Unit)
%                 %             fltCtrl.pitchMoment.ki.setValue(5000,fltCtrl.pitchMoment.ki.Unit)
%                 fltCtrl.AoAConst.setValue(15*pi/180,'deg')
%                 fltCtrl.perpErrorVal.setValue(0.4,'rad')
% 
% fltCtrl.yawMoment.kp.setValue(yawP,fltCtrl.yawMoment.kp.Unit);
% fltCtrl.yawMoment.kd.setValue(yawD,fltCtrl.yawMoment.kd.Unit);
% fltCtrl.yawMoment.ki.setValue(yawI,fltCtrl.yawMoment.ki.Unit);
% 
%                 turbAng = 0;
%                 turbAngVec = [cosd(turbAng);0;sind(turbAng)];
%                 vhcl.turb1.axisUnitVec.setValue(turbAngVec,'')
%                 vhcl.turb2.axisUnitVec.setValue(-turbAngVec,'')
%                 vhcl.turb3.axisUnitVec.setValue(turbAngVec,'')
%                 vhcl.turb4.axisUnitVec.setValue(-turbAngVec,'')
%                 %%  Set up critical system parameters and run simulation
%                                  FLOWCALCULATION = 'flowColumnSpec';
%                                                  FLIGHTCONTROLLER="posAug";
% 
%                 simParams = SIM.simParams;  simParams.setDuration(tFinal,'s');  dynamicCalc = '';
%                 progress = sprintf('%d Thr %.1f Altitude %.2f Flow Speed %d m Shear Layer Path %d\n',...
%                     thrLength,altitude,flwSpd,flwI*200,ii);
%                 fprintf(progress)
% 
%                 simWithMonitor('OCTModel','timeStep',2,'minRate',1)
%                 %%  Log Results
%                 tsc = signalcontainer(logsout);
%                 %             tsc = tsc.resample(0:0.1:tsc.positionVec.Time(end));
%                 %             plotRotorInfo
%                 % %             lap = max(tsc.lapNumS.Data)-1;
%                 %             tsc.plotFlightResults(vhcl,env,thr,fltCtrl,'plot1Lap',1==1,'plotS',1==0,'lapNum',lap,'dragChar',1==0,'cross',1==0)
%                 if simScenario(3) == 1
%                     Pow{thrI,altI,flwI} = tsc.rotPowerSummary(vhcl,env,thr);
%                     [Idx1,Idx2,lapCheck] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
% 
%                     %                 fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);
%                 end
%                     fString = 'Sensitivity';
%                 if ii == 2
%                     fString = ['BP' fString];
%                 end
%                 filename = sprintf(strcat(fString,'_V-0.75_shearLayer-%d_Alt-%d_thr-%d.mat'),200*flwI,altitude,thrLength);
% 
%                 if simScenario(6)
%                     save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
%                 end
%             end
%             flwI = flwI+1;
%         end
%     end
% end
% %%
% pathMeanPower=mean(tsc.netPower.Data(tsc.lapNumS.Data==9))
% 
% rollSPs=tsc.rollSP.Data;
% count=0;
% 
% for thrI=2:numel(rollSPs)
% 
%     if tsc.lapNumS.Data(thrI)==max(tsc.lapNumS.Data) && ( rollSPs(thrI-1)>0 && rollSPs(thrI)<0)
% 
%         count=count+1;
%         
%         if count==19
% 
%             startI=thrI;
%         end
% 
%        if count==20
% 
%             endI=thrI;
%             break
%         end
%     end
% 
% end
% 
% 
% 
% orientMeanPower=mean(tsc.netPower.Data(startI:endI))
% 
% count=0;
% 
% for thrI=2:numel(rollSPs)
% 
%     if tsc.elvSP.Data(thrI)==elevSet   && ( rollSPs(thrI-1)>0 && rollSPs(thrI)<0)
% 
%         count=count+1;
%         
%         if count==19
% 
%             startI2=thrI;
%         end
% 
%        if count==20
% 
%            endI2=thrI;
%             break
%         end
%     end
% 
% end
% 
% posAugMeanPower=mean(tsc.netPower.Data(startI2:endI2))
% 
% %%
% 
% tsc.elvSP.Data(tsc.thetaTerm.Data==0)=NaN;
% tsc.elvSP.Data(tsc.lapNumS.Data<11)=30;
% 
% figure;
% tsc.elevationAngle.plot;
% hold on;
% grid on;
% tsc.elvSP.plot('--','lineWidth',1);
% xlabel('Time (s)')
% ylabel('Elevation Angle (deg)')
% 
% title('Elevation Angle vs Time')
% legend({'Elv','SP'})
% %%
% 
% figure;
% hold on; grid on;
% tsc.netPower.plot
% title('Net Power Generated Vs Time')
% 
