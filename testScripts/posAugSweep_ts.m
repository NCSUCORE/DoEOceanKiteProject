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



flwSpds=0.4:0.05:0.4;
altS=250:50:250;

simSavePath = '\\cuifile1.sure.ad.ncsu.edu\cvermil00\Documents\Results\';%Path to Save Data

R.AoA=zeros(numel(flwSpds),numel(altS));
R.Power=zeros(numel(flwSpds),numel(altS));
R.Tension=zeros(numel(flwSpds),numel(altS));
R.Sideslip=zeros(numel(flwSpds),numel(altS));
R.Vmax=zeros(numel(flwSpds),numel(altS));
R.Vavg=zeros(numel(flwSpds),numel(altS));
R.Altavg=zeros(numel(flwSpds),numel(altS));
R.thrL=zeros(numel(flwSpds),numel(altS));
R.flw=repmat(flwSpds',1,numel(altS));
R.alt=repmat(altS,numel(flwSpds),1);

R.aRoll=cell(numel(flwSpds),numel(altS));
R.bRoll=cell(numel(flwSpds),numel(altS));

R.aYaw=cell(numel(flwSpds),numel(altS));
R.bYaw=cell(numel(flwSpds),numel(altS));

R.freqs=zeros(numel(flwSpds),numel(altS));



for flwI=1:numel(flwSpds)
    for altI=1:numel(altS)

       altSP=altS(altI);

%CHANGE TO 200 700

       if altSP<100 
           thrLen=200;
       else
           thrLen=700;
       end

flwSweep = flwSpds(flwI);%Flow speeds to sweep over
thrSweep = thrLen;%Kite Tether Lengths

elevSet=asind(altSP/thrSweep);
elvSP=elevSet;
elvSet=elvSP;
elevStart=elvSP+5;

newEstimator=0;
hiGainTime=3000;
ultKite=0;%Use ULK kite gains
betaMax=25*pi/180;
lockTime=0;

orientLaps=20;
pathEstimCtrl=0;


pathLaps=99;


azuSweep=0.35;
yawOff=0;

yawP=1.25e5*0.1*1;
yawD=1*yawP*2;
yawI=0.0*yawP;
%Sweep Parameters  

fairedCD=0.18;
intSat=100;
posAug=0;
thetaIGain=-0.01/6;
thetaPGain=-3/6;



numNodes=8;

yawPhaseSign=1;
yawGain=1/0.75;


slfAoA=-7.5*pi/180


constAoA=slfAoA;
maxAoA=8*pi./180;
aoa=maxAoA;
slfExitTime=0;

if pathLaps>0

    slfAoA=maxAoA;
end


yawlessTime=1000;
altSweep =sind(elvSP+5).*thrSweep;%Kite Altitudes above seabed (m)
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

tauRPM = 0;


if newEstimator
    thetaIGain=-0.01;
    thetaPGain=-3;
    intSat=100;
end

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

        

fftLag=0;%25.8-5.6-26; 

  


aRoll=[1 1];bRoll=1;aYaw=[1 1];bYaw=1;FREQ=1;


constElv=0;
elvDefl=-1.5;





fprintf(sprintf('%.2f Percent Complete\n',((i-1)*m*r+(j-1)*r+k)/(n*m*r)*100))
            Simulink.sdi.clear
            %%  Set Test Parameters
            tFinal = 800;      tSwitch = 10000;                        %   s - maximum sim duration
            flwSpd = flwSweep(k);                                              %   m/s - Flow speed
            altitude = altSweep(i);     initAltitude = 100;                     %   m/m - cross-current and initial altitude
            thrLength = thrSweep(j);    initThrLength = 200;
            if flwSpd<=0.3
                tFinal=2000;
            end
            if flwSpd<=0.2
                maxAoA=8*pi./180;
                aoa=maxAoA;
            end

            if flwSpd>=0.3
                maxAoA=10*pi./180;
                aoa=maxAoA;
            end

   

            %                 altitude = thrLength/2;%   m/m - cross-current and initial tether length
            fairing = 100;                          %   mm/m - tether diameter and fairing length
            el = asin(altitude/thrLength);                              %   rad - Initial elevation angle
            if flwSpd > 0.3
                hMeter = 25;
                wMeter = 75;
            else %if flwSpd > 0.25
                hMeter = 25;
                wMeter = 75;


            end


         
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

            filename = sprintf(strcat('V-%.2f_Alt-%d_thr-%d.mat'),flwSpd,0,thrLength);

loadComponent('ultDoeKite')
vhcl2=vhcl;
loadComponent('Manta71522');
VEHICLE='vhclTurbAM';
vhcl.Ma6x6_LE_Fuse.setValue(vhcl.Ma6x6_LE_Fuse.Value.*0,'');
vhcl.Ma6x6_LE.setValue(vhcl.Ma6x6_LE_Fuse.Value.*0,'');

loadComponent('pathFollowWithAoACtrlCoef')

fltCtrlPath=fltCtrl;


vhcl.fuse.CD.setValue([],'');
if ultKite
             loadComponent('ultDoeKite')
             VEHICLE='vhclTurbAM';
%vhcl.buoyFactor.setValue(1.04,'')
end


           loadComponent('LARController');
           LaRCtrl=fltCtrl;


            rotEff=[20	30	40	50	60	70	80	90	100	110	120	170	220	270	320	370; 0.635300000000000	0.702000000000000	0.741700000000000	0.764200000000000	0.797800000000000	0.814200000000000	0.824700000000000	0.844300000000000	0.852200000000000	0.866300000000000	0.861100000000000	0.890500000000000	0.904100000000000	0.899100000000000	0.917400000000000	0.911500000000000]
            vhcl.hStab.rSurfLE_WingLEBdy.setValue(vhcl.hStab.rSurfLE_WingLEBdy.Value-[.19;0;0],'m')

            loadComponent('constBoothLem');                     %   Constant basis parameters
            PATHGEOMETRY = 'lemBoothNew';
            %alt=sind(45)*thrLen;
            hiLvlCtrl.basisParams.setValue([a,b,altitude,0*pi/180,... %   Initialize basis parameters
                thrLength],'[rad rad rad rad m]');


            loadComponent('pathFollowWithAoACtrlCoef');             %   Path-following controller with AoA control
            

            PATHGEOMETRY = 'lemBoothNew';

            switch simScenario(4)                                   %   Tether model
                case 1
                    loadComponent('MantaTether');                       %   Manta Ray tether
                case 2
                    loadComponent('shortTether');                       %   Tether for reeling
                    thr.tether1.setInitTetherLength(initThrLength,'m');     %   Initialize tether length
                case 3
                    loadComponent('MantaTetherReal');                       %   Manta Ray tether
                    thr.numNodes.setValue(8,'');
                    thr.tether1.numNodes.setValue(8,'');
                    thr.tether1.setDensity(1187.1,'kg/m^3')
                case 4
                    loadComponent('fairedNNodeTether');                       %   Manta Ray tether
                    thr.numNodes.setValue(numNodes,'')
                    thr.tether1.numNodes.setValue(numNodes,'');
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
                vhcl.setInitEulAng([0,0,0],'rad')
                vhcl.setInitVelVecBdy([0.01 0 0],'m/s')
            end

            if slfExitTime>0
                vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
                vhcl.setInitEulAng([0,0,0],'rad')
                vhcl.setInitVelVecBdy([0.01 0 0],'m/s')
            
            else
                                    vhcl.setICsOnPath(0.75,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,3*flwSpd)

      
            end

if ultKite==0
    
 vhcl.vStab.alpha.setValue([vhcl.vStab.alpha.Value(1:end-1) 40],'deg')
 vhcl.vStab.CL.setValue([vhcl.vStab.CL.Value(1:end-1) 0.01] ,'')
vhcl.vStab.CD.setValue([vhcl.vStab.CD.Value(1:end-1) 0.04] ,'')

 vhcl.portWing.alpha.setValue([vhcl.portWing.alpha.Value(1:end-1) 40],'deg')
 vhcl.portWing.CL.setValue([vhcl.portWing.CL.Value(1:end-1) 0.4] ,'')
vhcl.portWing.CD.setValue([vhcl.portWing.CD.Value(1:end-1) 0.18] ,'')
 vhcl.stbdWing.alpha.setValue([vhcl.stbdWing.alpha.Value(1:end-1) 40],'deg')
 vhcl.stbdWing.CL.setValue([vhcl.stbdWing.CL.Value(1:end-1) 0.4] ,'')
vhcl.stbdWing.CD.setValue([vhcl.stbdWing.CD.Value(1:end-1) 0.18] ,'')


end

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
FLIGHTCONTROLLER="posAugCoef"
pthCtrl1=fltCtrl;
pthCtrl=fltCtrl;
pathCtrl=fltCtrl;



fltCtrl.Tmax.setValue(18.4,'kN')

           

%  

%WORK GOOD

fltCtrl.rollMoment.kp.setValue(3,fltCtrl.rollMoment.kp.Unit)
fltCtrl.rollMoment.kd.setValue(3,fltCtrl.rollMoment.kd.Unit)
fltCtrl.rollMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)

fltCtrl.yawMoment.kp.setValue((1.5/3).*3,fltCtrl.rollMoment.kp.Unit)
fltCtrl.yawMoment.kd.setValue((1.5/3).*6,fltCtrl.rollMoment.kd.Unit)
fltCtrl.yawMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)
% 
fltCtrl.pitchMoment.kp.setValue(0.5*3.5,fltCtrl.rollMoment.kp.Unit)
fltCtrl.pitchMoment.kd.setValue(0.5*1.75,fltCtrl.rollMoment.kd.Unit)
fltCtrl.pitchMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)



%% %Testing



% 
 fltCtrl.yawMoment.kp.setValue(1*(3/3).*3,fltCtrl.rollMoment.kp.Unit)
 fltCtrl.yawMoment.kd.setValue(1*(3/3).*6,fltCtrl.rollMoment.kd.Unit)
 fltCtrl.yawMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)

 
fltCtrl.rollMoment.kp.setValue(8,fltCtrl.rollMoment.kp.Unit)
fltCtrl.rollMoment.kd.setValue(8,fltCtrl.rollMoment.kd.Unit)
fltCtrl.rollMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)

fltCtrl.pitchMoment.kp.setValue(1*3.5,fltCtrl.rollMoment.kp.Unit)
fltCtrl.pitchMoment.kd.setValue(1*1.75,fltCtrl.rollMoment.kd.Unit)
fltCtrl.pitchMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)


if yawOff
        fltCtrl.yawMoment.kp.setValue((0/3).*3,fltCtrl.rollMoment.kp.Unit)
fltCtrl.yawMoment.kd.setValue(0.*6,fltCtrl.rollMoment.kd.Unit)
end

if ultKite
% 
    fltCtrl.yawMoment.kp.setValue((6/3).*3,fltCtrl.rollMoment.kp.Unit)
fltCtrl.yawMoment.kd.setValue((6/3).*6,fltCtrl.rollMoment.kd.Unit)




 fltCtrl.rollMoment.kp.setValue(25,fltCtrl.rollMoment.kp.Unit)
 fltCtrl.rollMoment.kd.setValue(25,fltCtrl.rollMoment.kd.Unit)
% fltCtrl.rollMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)

fltCtrl.pitchMoment.kp.setValue(3*3.5,fltCtrl.rollMoment.kp.Unit)
fltCtrl.pitchMoment.kd.setValue(0.5*1.75,fltCtrl.rollMoment.kd.Unit)
fltCtrl.pitchMoment.ki.setValue(0.1,fltCtrl.rollMoment.ki.Unit)

end

fltCtrl.AoAConst.setValue(aoa,fltCtrl.AoAConst.Unit)

            %%  Set up critical system parameters and run simulation
            simParams = SIM.simParams;  simParams.setDuration(tFinal,'s');  dynamicCalc = '';
            progress = sprintf('%d Thr %.1f Altitude %.2f Flow Speed\n',...
                thrLength,altitude,flwSpd);
            fprintf(progress)
            simWithMonitor('OCTModel','timeStep',2,'minRate',1)
            %%  Log Results
            tscP = signalcontainer(logsout);
            if simScenario(3) == 1
            end
            filename = sprintf(strcat('V-%.2f_Alt-%d_thr-%d.mat'),flwSpd,altitude,thrLength);
            if simScenario(6)
                save(strcat(simSavePath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
            end
        end
    end
end


posAugRunscript_ts;
    end
end
