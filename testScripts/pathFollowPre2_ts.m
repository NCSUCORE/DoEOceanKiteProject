%clear all;
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
simScenario = [1 1 1 4 1 1==0  0   1==0];


simSavePath = '\\cuifile1.sure.ad.ncsu.edu\cvermil00\Documents\Results\2023-06-14_PathFollowing_CFD_CDfair_0_18\';%Path to Save Data




%Sweep Parameters   
pathLaps=100;
fairedCD=0.18;
intSat=50;
posAug=0;
thetaIGain=-0.01;
thetaPGain=-3;
numNodes=8;
elevSet=30;
elevStart=53.5;
yawlessLaps=0;
slfAoA=5*pi/180;
constAoA=slfAoA;
maxAoA=7.5*pi./180;
aoa=maxAoA;
slfExitTime=1500; 
yawlessTime=1500;
thrSweep = [700];%Kite Tether Lengths
altSweep =350;%Kite Altitudes above seabed (m)
flwSweep = 0.3;%Flow speeds to sweep over
transTime=0;
rho=1000;%Water density
tauLim = 35;%Torque Limit(Nm)

x = meshgrid(thrSweep,altSweep,flwSweep);
[n,m,r] = size(x);
numCase = n*m*r;
powGen = zeros(n,m,r);
pathErr = zeros(n,m,r);
dragRatio = zeros(n,m,r);
Pow = cell(n,m,r);
%%
if ~exist(simSavePath,'dir')
    mkdir(simSavePath)
else
    if simScenario(6)
        fprintf(['These Sims are set to save. Do you want to save even if it may overwrite existing data']);
        str = input('(Y/N): \n','s');
        if isempty(str)
            str = 'Y';
        end
        if ~strcmpi(str,'Y')
            simScenario(6) = (1==0);
        end
    else
    end
end
tauRPM = 0
for i = 1:n
    if i < 1
        continue
    end
    for j = 1:m
        if j < 1
            continue
        end
        for k = 1:r
            if k < 1
                continue
            end


rollAmp=0.7509; yawAmp=1.2673; rollFreq=0.0797*1.25; yawFreq=rollFreq; rollPhase=1.28; yawPhase=1.4631;

fprintf(sprintf('%.2f Percent Complete\n',((i-1)*m*r+(j-1)*r+k)/(n*m*r)*100))
            Simulink.sdi.clear
            %%  Set Test Parameters
            tFinal = 600;      tSwitch = 10000;                        %   s - maximum sim duration
            flwSpd = flwSweep(k);                                              %   m/s - Flow speed
            altitude = altSweep(i);     initAltitude = 100;                     %   m/m - cross-current and initial altitude
            thrLength = thrSweep(j);    initThrLength = 200;
            %                 altitude = thrLength/2;%   m/m - cross-current and initial tether length
            fairing = 100;                          %   mm/m - tether diameter and fairing length
            el = asin(altitude/thrLength);                              %   rad - Initial elevation angle
            if flwSpd > 0.3
                hMeter = 18;
                wMeter = 50;
            elseif flwSpd > 0.25
                hMeter = 20;
                wMeter = 55;
            else
                hMeter = 25;
                wMeter = 75;
            end
                hMeter = 25;
                 wMeter = 75;



            if wMeter > 2*thrLength
                continue
            end
            sC = 0;             subCtrl = 3;                            %   State mac on/off            nd selected flight controller
            a = wMeter;
            b = hMeter;
            if el*180/pi < 10 || el*180/pi > 65
                fprintf('Elevation angle is out of range\n');
                continue
            end
            filename = sprintf(strcat('V-%.2f_Alt-%d_thr-%d.mat'),flwSpd,altitude,thrLength);



loadComponent('Manta71522')
            vhcl.fuse.CD.setValue([],'');


           


            rotEff=[20	30	40	50	60	70	80	90	100	110	120	170	220	270	320	370; 0.635300000000000	0.702000000000000	0.741700000000000	0.764200000000000	0.797800000000000	0.814200000000000	0.824700000000000	0.844300000000000	0.852200000000000	0.866300000000000	0.861100000000000	0.890500000000000	0.904100000000000	0.899100000000000	0.917400000000000	0.911500000000000]

vhcl.hStab.rSurfLE_WingLEBdy.setValue(vhcl.hStab.rSurfLE_WingLEBdy.Value-[.19;0;0],'m')


            loadComponent('constBoothLem');                     %   Constant basis parameters
            PATHGEOMETRY = 'lemBoothNew';
            hiLvlCtrl.basisParams.setValue([a,b,altitude,0*pi/180,... %   Initialize basis parameters
                thrLength],'[rad rad rad rad m]');


            loadComponent('pathFollowWithAoACtrlCoef');             %   Path-following controller with AoA control
            
            loadComponent('pathFollowWithAoACtrl');    

            PATHGEOMETRY = 'lemBoothNew';

            switch simScenario(4)                                   %   Tether model
                case 1
                    loadComponent('MantaTether');                       %   Manta Ray tether
                case 2
                    loadComponent('shortTether');                       %   Tether for reeling
                    thr.tether1.setInitTetherLength(initThrLength,'m');     %   Initialize tether length
                case 3
                    loadComponent('MantaTetherReal');                       %   Manta Ray tether
                    thr.numNodes.setValue(6,'');
                    thr.tether1.numNodes.setValue(6,'');
                    thr.tether1.setDensity(1187.1,'kg/m^3')
                case 4
                    loadComponent('fairedNNodeTether');                       %   Manta Ray tether
                    thr.numNodes.setValue(6,'')
                    thr.tether1.numNodes.setValue(6,'');
                    thr.tether1.fairedLinks.setValue(2,'');
                    thr.tether1.setDiameter(0.018,'m');
            end
            switch simScenario(5)                                   %   Environment
                case 1
                    loadComponent('ConstXYZT');                         %   Constant flow
                    ENVIRONMENT = 'env4turb';                           %   Two turbines
                    env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
                case 2
                    loadComponent('ConstYZTvarX');                      %   Variable X
                    ENVIRONMENT = 'env4turb';                           %   Two turbines
                    env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
            end
            loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
            loadComponent('MantaGndStn');                               %   Ground station
            loadComponent('winchManta');                                %   Winches
            loadComponent('idealSensors')                               %   Sensors
            loadComponent('idealSensorProcessing')                      %   Sensor processing
            %%  Vehicle Initial Conditions
            if simScenario(3) == 1
                if simScenario(2) == 4
                    vhcl.setICsOnPath(0.75,PATHGEOMETRY,hiLvlCtrl.initBasisParams.Value,gndStn.posVec.Value,3*flwSpd)
                else
                    vhcl.setICsOnPath(0.5,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,3*flwSpd)
                end
            else
                vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
                vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
                vhcl.setInitVelVecBdy([0.01 0 0],'m/s')
            end

   
                 %   vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,1.5*flwSpd)



%                 vhcl.setInitEulAng([rollAmp*sin(rollPhase),10*pi/180,yawAmp*sin(yawPhase)],'rad')
% 
%                vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
%                 vhcl.setInitEulAng([0,2,0]*pi/180,'rad')
%                 vhcl.setInitVelVecBdy([0.25 0 0],'m/s')
            %%  Tethers Properties
            %   kN - candidate tether tension limits
            thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
            thr.tether1.initAirNodeVel.setValue(rotation_sequence(vhcl.initEulAng.Value)*vhcl.initVelVecBdy.Value(:),'m/s');
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            if simScenario(4) == 4
                thr.tether1.fairedLength.setValue(fairing,'m');
                            thr.tether1.fairedDragCoeff.setValue(fairedCD,'');

            end
            %%  Winches Properties
            wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
            wnch.winch1.LaRspeed.setValue(1,'m/s');
            %%  Controller User Def. Parameters and dependant properties
            fltCtrl.setFcnName(PATHGEOMETRY,'');
            fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
           
            fairedCD    
FLIGHTCONTROLLER="posAug"


mult=flwSpd^2;


fltCtrl.yawMoment.kp.setValue(mult*1.5*12500,fltCtrl.yawMoment.kp.Unit);
fltCtrl.yawMoment.kd.setValue(mult*2*25000,fltCtrl.yawMoment.kd.Unit);
fltCtrl.yawMoment.ki.setValue(mult*0,fltCtrl.yawMoment.ki.Unit);
fltCtrl.AoAConst.setValue(aoa,fltCtrl.AoAConst.Unit)


 fltCtrl.pitchMoment.kp.setValue(mult*2*1*2.5e4,fltCtrl.yawMoment.kp.Unit);
 fltCtrl.pitchMoment.kd.setValue(mult*2.5*1.5*0.75e4,fltCtrl.yawMoment.kd.Unit);
 fltCtrl.pitchMoment.ki.setValue(mult*1.5*1*0.5e4,fltCtrl.yawMoment.ki.Unit);
  
 
 fltCtrl.pitchMoment.kp.setValue(0.2*2*mult*1*2.5e4,fltCtrl.yawMoment.kp.Unit);
 fltCtrl.pitchMoment.kd.setValue(6*mult*1.5*0.75e4,fltCtrl.yawMoment.kd.Unit);
 fltCtrl.pitchMoment.ki.setValue(0.5*mult*1*0.5e4,fltCtrl.yawMoment.ki.Unit);
 

fltCtrl.rollMoment.kp.setValue(mult*5e5,fltCtrl.rollMoment.kp.Unit)
fltCtrl.rollMoment.kd.setValue(mult*5e5,fltCtrl.rollMoment.kd.Unit)
fltCtrl.rollMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)


%[ 0.7509    1.2673    0.0797    0.0797    1.2800    1.4631];


fltCtrl.Tmax.setValue(18.4,'kN')

            %%  Set up critical system parameters and run simulation
            simParams = SIM.simParams;  simParams.setDuration(tFinal,'s');  dynamicCalc = '';
            progress = sprintf('%d Thr %.1f Altitude %.2f Flow Speed\n',...
                thrLength,altitude,flwSpd);
            fprintf(progress)
            simWithMonitor('OCTModel','timeStep',2,'minRate',1)
            %%  Log Results
            tscP = signalcontainer(logsout);
%            lap = max(tsc.lapNumS.Data)-1;
            if simScenario(3) == 1
              %  Pow{i,j,k} = tsc.rotPowerSummary(vhcl,env,thr);
%                 [Idx1,Idx2,lapCheck] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
%                 AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
%                 airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
%                 gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
%                 ten = max([max(airNode(ran)) max(gndNode(ran))]);
             %   fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);
            end
            filename = sprintf(strcat('V-%.2f_Alt-%d_thr-%d.mat'),flwSpd,altitude,thrLength);
            if simScenario(6)
                save(strcat(simSavePath,filename),'tscP','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
            end
        end
    end
end

[rollAmp, yawAmp, rollFreq, yawFreq, rollPhase, yawPhase] = getRollYawSetpoints(tscP)