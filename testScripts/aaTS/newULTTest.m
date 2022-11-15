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
simScenario = [1 1 1 3 1 1==1 1==0 1==1];
thrSweep = 2000;
altSweep = 1;
flwSweep = [.7:.1:2]
x = meshgrid(thrSweep,altSweep,flwSweep);
[n,m,r] = size(x);
numCase = n*m*r;
powGen = zeros(n,m,r);
pathErr = zeros(n,m,r);
dragRatio = zeros(n,m,r);
Pow = cell(n,m,r);

for i = 1:n
    if i < 1
        continue
    end
    for j = 1:m
        if j < 1
            continue
        end
        k = 1;
        for k = 1:r%200*k<=thrSweep(j)/2
            for ii = 1
                fprintf(sprintf('%.2f Percent Complete\n',((i-1)*m*r+(j-1)*r+k)/(n*m*r)*100))
                Simulink.sdi.clear
                %  Set Test Parameters
                tFinal = 1500;%+200*k;      tSwitch = 10000;                        %   s - maximum sim duration
                flwSpd = flwSweep(k);                                              %   m/s - Flow speed
                altitude = thrSweep(j)/2;                   %   m/m - cross-current and initial altitude

                thrLength = thrSweep(j);
                el = asin(altitude/thrLength);                              %   rad - Initial elevation angle
                height = 0:25:2200;

                hNom = altitude;
                v = [0.25 1]*flwSpd;
                z = [hNom-200*1 hNom];
                flow = flowDist(height,z,v);

                if ii == 1
                    b = 20;
                    a = 60;
                else
                    b = 30;
                    a = 120;
                end
                d = 1;
                loadComponent('ultDoeKite')
                VEHICLE = 'vhcl4turb';

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
                fltCtrl.AoAConst.setValue(18*pi/180,'deg')
                fltCtrl.perpErrorVal.setValue(0.4,'rad')

                turbAng = 0;
                turbAngVec = [cosd(turbAng);0;sind(turbAng)];
                vhcl.turb1.axisUnitVec.setValue(turbAngVec,'')
                vhcl.turb2.axisUnitVec.setValue(-turbAngVec,'')
                vhcl.turb3.axisUnitVec.setValue(turbAngVec,'')
                vhcl.turb4.axisUnitVec.setValue(-turbAngVec,'')
                fltCtrl.yawMoment.kp.setValue(-5e4,fltCtrl.yawMoment.kp.Unit)
                %%  Set up critical system parameters and run simulation
                FLOWCALCULATION = 'flowColumnSpec';
                thrSwitch = 1
                simParams = SIM.simParams;  simParams.setDuration(tFinal,'s');  dynamicCalc = '';
                simWithMonitor('OCTModel','timeStep',2,'minRate',1)
                tsc = signalcontainer(logsout);
                %%  Log Results


                fltCtrl.yawMoment.kp.setValue(-4e5,fltCtrl.yawMoment.kp.Unit)
                thrSwitch = 0;
                thr.tether1.dragCoeff.setValue(0,'')
                thr.numNodes.setValue(2,'');
                thr.tether1.numNodes.setValue(2,'');    
%                 SIXDOFDYNAMICS = "fiveDoFDynamicsCoupledFossenTurbDynamics";
                simWithMonitor('OCTModel','timeStep',2,'minRate',1)
                tsc2 = signalcontainer(logsout);

                if simScenario(3) == 1
                    p = tsc.rotPowerSummary(vhcl,env,thr);
                    p2 = tsc2.rotPowerSummary(vhcl,env,thr);
                    powerNom(k) = p.turb;
                    powerNew(k) = p2.turb;
                    [Idx1,Idx2,lapCheck] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
                end
            end
            k = k+1;
        end
    end
end
%%

[Idx1,Idx2,lapCheck] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
[Idx1,Idx2,lapCheck] = tsc2.getLapIdxs(max(tsc2.lapNumS.Data)-1);  ran1 = Idx1:Idx2;


close all
figure
hold on
tsc.velocityVec.mag.plot
tsc2.velocityVec.mag.plot
xlabel 'Time [s]'
ylabel 'Velocity Magnitude [m/s]'
legend('6DoF Full Tether','6DoF Tether Regression Model','Location','north')


figure
tL = tiledlayout(3,1);
tL.Title.String = 'Position';
ylab = {'$x_g$ [m]','$y_g$ [m]','$z_g$ [m]'}
for i = 1:3
    nexttile
    hold on
    plotsq(tsc.positionVec.Time(ran)-tsc.positionVec.Time(ran(1)),tsc.positionVec.Data(i,:,ran));
    plotsq(tsc2.positionVec.Time(ran1)-tsc2.positionVec.Time(ran1(1)),tsc2.positionVec.Data(i,:,ran1))
    ylabel(ylab{i})
end
xlabel 'Time [s]'
legend('6DoF Full Tether','6DoF Tether Regression Model','Location','north')

figure
tL = tiledlayout(3,1);
ylab = {'Roll [deg]','Pitch [deg]','Yaw [deg]'}
for i = 1:3
    tL.Title.String = 'Euler Angles';
    nexttile
    hold on
    plotsq(tsc.positionVec.Time(ran)-tsc.positionVec.Time(ran(1)),tsc.eulerAngles.Data(i,:,ran)*180/pi);
    plotsq(tsc2.positionVec.Time(ran1)-tsc2.positionVec.Time(ran1(1)),tsc2.eulerAngles.Data(i,:,ran1)*180/pi)
    ylabel(ylab{i})
end
xlabel 'Time [s]'
legend('6DoF Full Tether','6DoF Tether Regression Model','Location','north')

figure
tL = tiledlayout(3,1);
tL.Title.String = 'Velocity';
ylab = {'$u$ [m/s]','$v$ [m/s]','$w$ [m/s]'}
for i = 1:3
    nexttile
    hold on
    plotsq(tsc.positionVec.Time(ran)-tsc.positionVec.Time(ran(1)),tsc.velocityVec.Data(i,:,ran));
    plotsq(tsc2.positionVec.Time(ran1)-tsc2.positionVec.Time(ran1(1)),tsc2.velocityVec.Data(i,:,ran1))
    ylabel(ylab{i})
end
xlabel 'Time [s]'
legend('6DoF Full Tether','6DoF Tether Regression Model','Location','north')



