

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


thrSweep = thrLength;%:
altSweep = thrLength/2;%altitude;
flwSweep = [flwSpd];%0.5:0.25:2;
flowMult = 0.1%:0.1:1;
x = meshgrid(thrSweep,altSweep,flowMult);
intSat=25;
slfExitTime=1e6;

posAug=1;
thetaIGain=-0.01;
thetaPGain=-3;
numNodes=8;
elevSet=35;
elevStart=45;
yawP=1.25e5;
yawD=1*yawP;
yawI=0.0*yawP;
transTime=0;
pathLaps=12;
rho=1000;
aoaConst=7.5*pi/180;

rollAmp=pi/2; yawAmp=pi/2; rollFreq=0.1; yawFreq=0.1; rollPhase=0; yawPhase=0;



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
                tFinal = 1000;      tSwitch = 10000;                        %   s - maximum sim duration
                flwSpd = flwSweep;                                              %   m/s - Flow speed
                altitude = altSweep;                   %   m/m - cross-current and initial altitude

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
                loadComponent('Manta71522')
                VEHICLE = 'vhcl4turb';


            vhcl.fuse.CD.setValue([],'');



            rotEff=[20	30	40	50	60	70	80	90	100	110	120	170	220	270	320	370; 0.635300000000000	0.702000000000000	0.741700000000000	0.764200000000000	0.797800000000000	0.814200000000000	0.824700000000000	0.844300000000000	0.852200000000000	0.866300000000000	0.861100000000000	0.890500000000000	0.904100000000000	0.899100000000000	0.917400000000000	0.911500000000000];

            vhcl.hStab.rSurfLE_WingLEBdy.setValue(vhcl.hStab.rSurfLE_WingLEBdy.Value-[.19;0;0],'m')



                loadComponent('constBoothLem');
                hiLvlCtrl.basisParams.setValue([a,b,altitude,0*pi/180,... %   Initialize basis parameters
                    thrLength],'[rad rad rad rad m]');

            loadComponent('pathFollowWithAoACtrlCoef');             %   Path-following controller with AoA control
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
                fltCtrl.Tmax.setValue(22,'kN');
%                 TETHERS = 'tetherFaired'
% 
                    loadComponent('fairedNNodeTether');                       %   Manta Ray tether
                    thr.numNodes.setValue(9,'')
                    thr.tether1.numNodes.setValue(9,'');
                    thr.tether1.fairedLinks.setValue(2,'');
                    thr.tether1.setDensity(1187.1,'kg/m^3');
                    thr.tether1.setDiameter(0.018,'m');

                thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
                thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
                thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
                thr.tether1.initAirNodeVel.setValue(rotation_sequence(vhcl.initEulAng.Value)*vhcl.initVelVecBdy.Value(:),'m/s');
                thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
%Choose Tether


 thr.tether1.dragCoeff.setValue(1.3,'')
% thr.numNodes.setValue(numNodes,'');
% thr.tether1.numNodes.setValue(numNodes,'');


thr.tether1.fairedLength.setValue(100,'m');
            thr.tether1.fairedDragCoeff.setValue(0.18,'');



thr.tether1.dampingRatio.setValue(.1,'')
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
                fltCtrl.AoAConst.setValue(7.5*pi/180,'deg')
                fltCtrl.perpErrorVal.setValue(0.4,'rad')

% fltCtrl.yawMoment.kp.setValue(yawP,fltCtrl.yawMoment.kp.Unit);
% fltCtrl.yawMoment.kd.setValue(yawD,fltCtrl.yawMoment.kd.Unit);
% fltCtrl.yawMoment.ki.setValue(yawI,fltCtrl.yawMoment.ki.Unit);
% 
% 
% 
% fltCtrl.yawMoment.kp.setValue(yawP,fltCtrl.yawMoment.kp.Unit);
% fltCtrl.yawMoment.kd.setValue(yawD,fltCtrl.yawMoment.kd.Unit);
% fltCtrl.yawMoment.ki.setValue(yawI,fltCtrl.yawMoment.ki.Unit);
% fltCtrl.AoAConst.setValue(aoa,fltCtrl.AoAConst.Unit)
% 
%  fltCtrl.pitchMoment.kp.setValue(0.01*2.5e4,fltCtrl.yawMoment.kp.Unit);
%  fltCtrl.pitchMoment.kd.setValue(0.015*0.75e4,fltCtrl.yawMoment.kd.Unit);
%  fltCtrl.pitchMoment.ki.setValue(0.01*0.5e4,fltCtrl.yawMoment.ki.Unit);
% 
% 
% 
% fltCtrl.rollMoment.kp.setValue(5e5,fltCtrl.rollMoment.kp.Unit)
% fltCtrl.rollMoment.kd.setValue(5e5,fltCtrl.rollMoment.kd.Unit)
% fltCtrl.rollMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)

%                 turbAng = 0;
%                 turbAngVec = [cosd(turbAng);0;sind(turbAng)];
%                 vhcl.turb1.axisUnitVec.setValue(turbAngVec,'')
%                 vhcl.turb2.axisUnitVec.setValue(-turbAngVec,'')
%                 vhcl.turb3.axisUnitVec.setValue(turbAngVec,'')
%                 vhcl.turb4.axisUnitVec.setValue(-turbAngVec,'')
%                 %%  Set up critical system parameters and run simulation
                                 FLOWCALCULATION = 'flowColumnSpec';
                                                FLIGHTCONTROLLER="posAug";

                simParams = SIM.simParams;  simParams.setDuration(tFinal,'s');  dynamicCalc = '';
                progress = sprintf('%d Thr %.1f Altitude %.2f Flow Speed %d m Shear Layer Path %d\n',...
                    thrLength,altitude,flwSpd,k*200,ii);
                fprintf(progress)

                simWithMonitor('OCTModel','timeStep',2,'minRate',1)
                %%  Log Results
                tscPrerun = signalcontainer(logsout);

                
            end
            k = k+1;
        end
    end
end


