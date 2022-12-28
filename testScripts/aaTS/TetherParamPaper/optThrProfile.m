%% Test script for John to control the kite model
clear powerNom powerNew;
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
lapMax = 10
load tsrMod.mat 
simScenario = [1 1 1 3 1 1==1 1==0 1==1];
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
                tFinal = 1500;%+200*k;      tSwitch = 10000;                        %   s - maximum sim duration
                flwSpd = flwSweep;%(k);                                              %   m/s - Flow speed
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
                    a = bVec(k);
                else
                    b = 30;
                    a = 120;
                end
                d = 1;
                loadComponent('ultDoeKiteTSR')
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
                thr.tether1.dragCoeff.setValue(.2,'')
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

                fltCtrl.rollMoment.kp.setValue(1e5,fltCtrl.rollMoment.kp.Unit)
                fltCtrl.rollMoment.kd.setValue(1e5,fltCtrl.rollMoment.kd.Unit)

                fltCtrl.pitchMoment.kp.setValue(1e5,fltCtrl.rollMoment.kp.Unit)
                fltCtrl.pitchMoment.kd.setValue(1e5,fltCtrl.rollMoment.kd.Unit)


                turbAng = 0;
                turbAngVec = [cosd(turbAng);0;sind(turbAng)];
                vhcl.turb1.axisUnitVec.setValue(turbAngVec,'')
                vhcl.turb2.axisUnitVec.setValue(-turbAngVec,'')
                vhcl.turb3.axisUnitVec.setValue(turbAngVec,'')
                vhcl.turb4.axisUnitVec.setValue(-turbAngVec,'')
                fltCtrl.yawMoment.kp.setValue(-5e4,fltCtrl.yawMoment.kp.Unit)
                %%  Set up critical system parameters and run simulation
                A = 0;
                B = 0;
                phi = 0;
                beta = [A B phi]';
                FLOWCALCULATION = 'flowColumnSpec';
                thrSwitch = 1
                simParams = SIM.simParams;  simParams.setDuration(1000,'s');  dynamicCalc = '';
                set_param('OCTModel','FastRestart','on')
                lapMax = 5;
                baseSimOut = sim('OCTModel')
                lapMax = 10;
                simIn = Simulink.SimulationInput('OCTModel');
                simIn = setInitialState(simIn,baseSimOut.xFin);
%
                f = @(x)thrDragOpt(simIn,x)
                llim = [0 0 -pi]';
                ulim = [1 1 pi]';
                opts = optimoptions('fminunc','Display','iter','PlotFcn','optimplotfval')
                [betaOut,fVal] = fminunc(f,[0.0;0.0;0],opts)%,[],[],[],[],llim,ulim,[],opts)
                toc
                simOut = sim(simIn);
                tsc2 = signalcontainer(logsout);
                p = tsc.rotPowerSummary(vhcl,env,thr);
%                 
                %%  Log Results

                simParams.setDuration(1000,'s');
% 
% %                 fltCtrl.yawMoment.kp.setValue(-5e4,fltCtrl.yawMoment.kp.Unit)
%                 thrSwitch = 0;
%                 thr.tether1.dragCoeff.setValue(0,'')
%                 thr.numNodes.setValue(2,'');
%                 thr.tether1.numNodes.setValue(2,'');    
%                 SIXDOFDYNAMICS = "sixDoFDynamicsCoupledFossenTurbDynamics";
%                 simWithMonitor('OCTModel','timeStep',2,'minRate',1)
%                 tsc2 = signalcontainer(logsout);
% 
% %                 fltCtrl.yawMoment.kp.setValue(-4e5,fltCtrl.yawMoment.kp.Unit)
%                 SIXDOFDYNAMICS = "fiveDoFDynamicsCoupledFossenTurbDynamics";
%                 simWithMonitor('OCTModel','timeStep',2,'minRate',1)
%                 tsc3 = signalcontainer(logsout);
% 
%                 if simScenario(3) == 1
%                     p = tsc.rotPowerSummary(vhcl,env,thr);
%                     p2 = tsc2.rotPowerSummary(vhcl,env,thr);
%                     p3 = tsc3.rotPowerSummary(vhcl,env,thr);
%                     powerNom(k) = p.turb;
%                     powerNew(k) = p2.turb;
%                     powerNew2(k) = p3.turb;
% %                     [Idx1,Idx2,lapCheck] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
%                 end
            end
            k = k+1;
        end
    end
end
%%

[Idx1,Idx2,lapCheck] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
[Idx1,Idx2,lapCheck] = tsc2.getLapIdxs(max(tsc2.lapNumS.Data)-1);  ran1 = Idx1:Idx2;
[Idx1,Idx2,lapCheck] = tsc3.getLapIdxs(max(tsc3.lapNumS.Data)-1);  ran2 = Idx1:Idx2;


close all
figure
tsc.velocityVec.mag.plot
hold on
tsc2.velocityVec.mag.plot
tsc3.velocityVec.mag.plot
xlabel 'Time [s]'
ylabel 'Velocity Magnitude [m/s]'
legend('6DoF Full Tether','6DoF Tether Regression Model','Location','north')


figure
tL = tiledlayout(3,1);
tL.Title.String = 'Thr Force';
ylab = {'$x_g$ [m]','$y_g$ [m]','$z_g$ [m]'};
for i = 1:3
    nexttile
    hold on
    plotsq(tsc.closestPathVariable.Data(ran),tsc.FThrNetBdy.Data(i,:,ran));
    plotsq(tsc2.closestPathVariable.Data(ran1),tsc2.FThrNetBdy.Data(i,:,ran1))
    plotsq(tsc3.closestPathVariable.Data(ran2),tsc3.FThrNetBdy.Data(i,:,ran2))
    ylabel(ylab{i})
end
xlabel 'Time [s]'
legend('6DoF Full Tether','6DoF Tether Regression Model','5DoF Tether Regression Model','Location','north')


figure
tL = tiledlayout(3,1);
tL.Title.String = 'Thr Force';
ylab = {'$x_g$ [m]','$y_g$ [m]','$z_g$ [m]'};
for i = 1:3
    nexttile
    hold on
    plotsq(tsc.closestPathVariable.Time(ran)-tsc.closestPathVariable.Time(ran(1)),tsc.positionVec.Data(i,:,ran));
    plotsq(tsc2.closestPathVariable.Time(ran1)-tsc2.closestPathVariable.Time(ran1(1)),tsc2.positionVec.Data(i,:,ran1))
    plotsq(tsc3.closestPathVariable.Time(ran2)-tsc3.closestPathVariable.Time(ran2(1)),tsc3.positionVec.Data(i,:,ran2))
    ylabel(ylab{i})
end
xlabel 'Time [s]'
legend('6DoF Full Tether','6DoF Tether Regression Model','5DoF Tether Regression Model','Location','north')

%%
num = 0
figure
scatter(powerNom,powerNew,50,bVec','filled')
xlabel 'Full Tether Power [kW]'
ylabel 'Reduced Tether Power [kW]'
h = colorbar
h.Label.String = 'Path Width [m]'
h.Label.Interpreter = 'latex'