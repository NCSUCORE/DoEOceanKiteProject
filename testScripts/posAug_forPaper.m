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
simScenario = [1 1 1 3 1 1==1  0   1==0];


simSavePath = '\\cuifile1.sure.ad.ncsu.edu\cvermil00\Documents\Results\simsForPosAugPaper_Final2\';%Path to Save Data

flwSweep = flwSpd;%Flow speeds to sweep over
thrSweep = thrLen;%Kite Tether Lengths
elevSet=elvSP;
%elevStart=elvSP;
elevStart=39;elvSP+5;


bandGap=0.025*pi/180;
elvFilt=pi/rollFreq;
pathEstimFilt=0.05*pi/rollFreq;
newEstimator=0;
hiGainTime=3000;
ultKite=0;%Use ULK kite gains
betaMax=25*pi/180;
lockTime=0;

slfKd=0;
slfKp=0.1;
slfKi=0;
betaGain=0;

fftSwitch=1;
slfExitTime=0;4*pi/rollFreq; %0
%pathLaps=8;
pathLaps=4;


orientExitTime=slfExitTime+2500;
phaseShift=0;
    zeroYawRoll=90*pi/180;
K_filt=0.01;
azuSweep=0.35;
yawOff=0;

yawP=1.25e5*0.1*1;
yawD=1*yawP*2;
yawI=0.0*yawP;
%Sweep Parameters  

pathLapsYaw=0;
fairedCD=0.18;
intSat=200;
posAug=1;
thetaIGain=-0.003;
thetaPGain=-0.6;



numNodes=8;

yawPhaseSign=1;
yawGain=1/0.75;

yawlessLaps=0;
maxAmp=1;
slfAoA=-5*pi/180;
slfAoA=-7.5*pi/180


constAoA=slfAoA;
maxAoA=8*pi./180;
aoa=maxAoA;

if pathLaps>0

    slfAoA=maxAoA;
end


            if flwSpd<=0.2
                maxAoA=8*pi./180;
                aoa=maxAoA;
            end

if flwSpd>=0.3
    maxAoA=5*pi./180;
    aoa=maxAoA;
end


yawlessTime=1000;
altSweep =sind(5+elvSP).*thrSweep;%Kite Altitudes above seabed (m)
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
    intSat=125;
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

        
%[rollAmp, yawAmp, rollFreq, yawFreq, rollPhase, yawPhase] = getRollYawSetpoints(tscP);
% yawAmp=yawAmp/0.7;
% rollAmp=rollAmp/0.7;
% yawAmp=yawAmp*0.85*0.75;
% rollAmp=rollAmp;%*0.75^2;
% yawAmp=yawAmp*1;
% rollAmp=rollAmp*0.75;
%yawAmp=pi/2;
%rollAmp=25*pi/180;
rollPow=1;
fftLag=0%25.8-5.6-26; 
% 
% rollFreq=rollFreq;
%   yawFreq=rollFreq;

  
% phaseShift=0;
%  rollAmp=50*pi/180;
%  yawAmp=80*pi/180;
% rollPhase=0;yawPhase=0.15;
% rollFreq=0.0259;
% yawFreq=rollFreq;
% 
% rollPhase=1.2474;
% yawPhase=1.4810;
% rollAmp=0.76;
% yawAmp=1.1;

%yawPhase=-0.05;
%[aRoll,bRoll,aYaw,bYaw,FREQ] = getRollYawSetpointsFFT2(tscP);


[aRoll,bRoll,aYaw,bYaw,FREQ] = getRollYawSetpointsFFT2(tscP,25);
   aRoll=aRoll.*0.7;
   bRoll=bRoll.*0.7;
    b2Roll=[0;bRoll];%Make size(a)=size(b) for indexing
    b2Yaw=[0;bYaw];%Make size(a)=size(b) for indexing

    thresh=0;% If the power at the given harmonic is less than thresh, ignore that octave in the fourier series

    aRoll(abs(aRoll)<thresh & abs(b2Roll)<thresh)=0;
     b2Roll(abs(aRoll)<thresh & abs(b2Roll)<thresh)=0;
     bRoll=b2Roll(2:end);
      
     aYaw(abs(aYaw)<thresh & abs(b2Yaw)<thresh)=0;
     b2Yaw(abs(aYaw)<thresh & abs(b2Yaw)<thresh)=0;
     bYaw=b2Yaw(2:end);

constElv=0;
elvDefl=-1.5;



fprintf(sprintf('%.2f Percent Complete\n',((i-1)*m*r+(j-1)*r+k)/(n*m*r)*100))
            Simulink.sdi.clear
            %%  Set Test Parameters
           tFinal = 20000;      tSwitch = 10000;                        %   s - maximum sim duration
          % tFinal = 600;      tSwitch = 10000;                        %   s - maximum sim duration           
            flwSpd = flwSweep(k);                                              %   m/s - Flow speed
            altitude = altSweep(i);     initAltitude = 100;                     %   m/m - cross-current and initial altitude
            thrLength = thrSweep(j);    initThrLength = 200;
            %                 altitude = thrLength/2;%   m/m - cross-current and initial tether length
            fairing = 100;                          %   mm/m - tether diameter and fairing length
            el = asin(altitude/thrLength);                              %   rad - Initial elevation angle
   
            if flwSpd > 0.3
                hMeter = 25;
                wMeter = 75;
            else %if flwSpd > 0.25
                hMeter = 25;
                wMeter = 75;
% 
%             else
%                 hMeter = 30;
%                 wMeter = 90;
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

            filename = sprintf(strcat('V-%.2f_Alt-%d_thr-%d.mat'),flwSpd,0,thrLength);

loadComponent('ultDoeKite')
vhcl2=vhcl;
loadComponent('Manta71522');
VEHICLE='vhclTurbAM';


loadComponent('pathFollowWithAoACtrlCoef')

fltCtrlPath=fltCtrl;

vhcl.fuse.CD.setValue([],'');

if ultKite
             loadComponent('ultDoeKite')
             VEHICLE='vhclTurbAM';
end


           loadComponent('LARController');
           LaRCtrl=fltCtrl;


            rotEff=[20	30	40	50	60	70	80	90	100	110	120	170	220	270	320	370; 0.635300000000000	0.702000000000000	0.741700000000000	0.764200000000000	0.797800000000000	0.814200000000000	0.824700000000000	0.844300000000000	0.852200000000000	0.866300000000000	0.861100000000000	0.890500000000000	0.904100000000000	0.899100000000000	0.917400000000000	0.911500000000000]

vhcl.hStab.rSurfLE_WingLEBdy.setValue(vhcl.hStab.rSurfLE_WingLEBdy.Value-[.19;0;0],'m')

            loadComponent('constBoothLem');                     %   Constant basis parameters
            PATHGEOMETRY = 'lemBoothNew';
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
                    thr.numNodes.setValue(6,'');
                    thr.tether1.numNodes.setValue(6,'');
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



fltCtrl.Tmax.setValue(9999,'kN')

           
% 
% 
% 
% mult=flwSpd^2;
% %Baseline
% fltCtrl.yawMoment.kp.setValue(1.5*mult*1.5*12500,fltCtrl.yawMoment.kp.Unit);
% fltCtrl.yawMoment.kd.setValue(1.5*mult*2*25000,fltCtrl.yawMoment.kd.Unit);
% fltCtrl.yawMoment.ki.setValue(mult*0,fltCtrl.yawMoment.ki.Unit);
% 
% %retune
% fltCtrl.yawMoment.kp.setValue(6*1.5*mult*1.5*12500,fltCtrl.yawMoment.kp.Unit);
% fltCtrl.yawMoment.kd.setValue(6*1.5*mult*2*25000,fltCtrl.yawMoment.kd.Unit);
% fltCtrl.yawMoment.ki.setValue(mult*0,fltCtrl.yawMoment.ki.Unit);
% 
% 
% fltCtrl.AoAConst.setValue(aoa,fltCtrl.AoAConst.Unit)
% 
% 
%  fltCtrl.pitchMoment.kp.setValue(mult*1*2.5e4,fltCtrl.yawMoment.kp.Unit);
%  fltCtrl.pitchMoment.kd.setValue(mult*1.5*0.75e4,fltCtrl.yawMoment.kd.Unit);
%  fltCtrl.pitchMoment.ki.setValue(mult*1*0.5e4,fltCtrl.yawMoment.ki.Unit);
%  


% 
% 
% %Hi-Gain Working
% fltCtrl.rollMoment.kp.setValue(mult*5e5,fltCtrl.rollMoment.kp.Unit)
% fltCtrl.rollMoment.kd.setValue(mult*5e5,fltCtrl.rollMoment.kd.Unit)
% fltCtrl.rollMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)
% 
% %Lo-gain
% fltCtrl.rollMoment.kp.setValue(mult*1e5,fltCtrl.rollMoment.kp.Unit)
% fltCtrl.rollMoment.kd.setValue(mult*1e5,fltCtrl.rollMoment.kd.Unit)
% fltCtrl.rollMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)
% 
% 
% 
% %Baseline
%  fltCtrl.pitchMoment.kp.setValue(mult*1*2.5e4,fltCtrl.yawMoment.kp.Unit);
%  fltCtrl.pitchMoment.kd.setValue(mult*1.5*0.75e4,fltCtrl.yawMoment.kd.Unit);
%  fltCtrl.pitchMoment.ki.setValue(mult*1*0.5e4,fltCtrl.yawMoment.ki.Unit);
%  
%  mult=mult*0.5
% 
% 
% %Re-tune
%  fltCtrl.pitchMoment.kp.setValue(4*mult*1*2.5e4,fltCtrl.yawMoment.kp.Unit);
%  fltCtrl.pitchMoment.kd.setValue(4*mult*1.5*0.75e4,fltCtrl.yawMoment.kd.Unit);
%  fltCtrl.pitchMoment.ki.setValue(1*mult*1*0.5e4,fltCtrl.yawMoment.ki.Unit);
%  
% %Re-tune Scheduled
% 
%  fltCtrl.pitchMoment.kp.setValue(2*mult*1*2.5e4,fltCtrl.yawMoment.kp.Unit);
%  fltCtrl.pitchMoment.kd.setValue(6*mult*1.5*0.75e4,fltCtrl.yawMoment.kd.Unit);
%  fltCtrl.pitchMoment.ki.setValue(0.5*mult*1*0.5e4,fltCtrl.yawMoment.ki.Unit);
%  
% 
%  fltCtrl.pitchMoment.kp.setValue(1.5*mult*1*2.5e4,fltCtrl.yawMoment.kp.Unit);
%  fltCtrl.pitchMoment.kd.setValue(8*mult*1.5*0.75e4,fltCtrl.yawMoment.kd.Unit);
%  fltCtrl.pitchMoment.ki.setValue(0.5*mult*1*0.5e4,fltCtrl.yawMoment.ki.Unit);
% %  
% 
% 



 LaRCtrl.pitchMoment.kp.setValue(slfKp,LaRCtrl.yawMoment.kp.Unit);
  LaRCtrl.pitchMoment.kd.setValue(slfKd*1.5*0.75e4,LaRCtrl.yawMoment.kd.Unit);
  LaRCtrl.pitchMoment.ki.setValue(slfKi*1*0.5e4,LaRCtrl.yawMoment.ki.Unit);
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



% fltCtrl.rollMoment.kp.setValue(3,fltCtrl.rollMoment.kp.Unit)
% fltCtrl.rollMoment.kd.setValue(3,fltCtrl.rollMoment.kd.Unit)
% fltCtrl.rollMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)

% fltCtrl.yawMoment.kp.setValue((1/3).*3,fltCtrl.rollMoment.kp.Unit)
% fltCtrl.yawMoment.kd.setValue((1/3).*6,fltCtrl.rollMoment.kd.Unit)
% fltCtrl.yawMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)
% % % 
%  fltCtrl.pitchMoment.kp.setValue(0.5*3.5,fltCtrl.rollMoment.kp.Unit)
%  fltCtrl.pitchMoment.kd.setValue(0.5*1.75,fltCtrl.rollMoment.kd.Unit)


% 
% 
 fltCtrl.yawMoment.kp.setValue(1*(3/3).*3,fltCtrl.rollMoment.kp.Unit)
 fltCtrl.yawMoment.kd.setValue(1*(3/3).*6,fltCtrl.rollMoment.kd.Unit)
 fltCtrl.yawMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)

% fltCtrl.pitchMoment.kp.setValue(3/6*3.5,fltCtrl.rollMoment.kp.Unit)
% fltCtrl.pitchMoment.kd.setValue(3/6*1.75,fltCtrl.rollMoment.kd.Unit)
% fltCtrl.pitchMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)
% 
% % % 
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
% 
% fltCtrl.rollMoment.kp.setValue(8,fltCtrl.rollMoment.kp.Unit)
% fltCtrl.rollMoment.kd.setValue(8,fltCtrl.rollMoment.kd.Unit)
% fltCtrl.rollMoment.ki.setValue(0,fltCtrl.rollMoment.ki.Unit)
% 
% 

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
            tsc = signalcontainer(logsout);
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
            filename = sprintf(strcat('5degAOA__PosAug_V-%.2f_AltSP-%d_thr-%d.mat'),flwSpd,altSP,thrLength);
                   end
    end
end

%%
period=2*pi/FREQ;
%Calc Loyd Power
[CL,CD]=vhcl.getCLCD(thr,thrLength)
alphas=vhcl.portWing.alpha.Value;

clKite=interp1(alphas,CL,fltCtrl.AoAConst.Value*180/pi);
cdKite=interp1(alphas,CD.kite,fltCtrl.AoAConst.Value*180/pi);
cdKiteTurb=interp1(alphas,CD.sys,fltCtrl.AoAConst.Value*180/pi);
cdKiteThr=interp1(alphas,CD.kiteThr,fltCtrl.AoAConst.Value*180/pi);


Sref=vhcl.fluidRefArea.Value;
pLoyd=(2/27)*Sref*1000*flwSpd^3*(clKite^3/cdKiteThr^2);
tLoyd=(2/9)*Sref*1000*flwSpd^2*(clKite^3/cdKiteThr^2);

%Calculate Path power
powPath=mean(tscP.turbPow.Data(tscP.lapNumS.Data==max(tscP.lapNumS.Data)-1))
tPath=mean(tscP.gndNodeTenVecs.mag.Data(tscP.lapNumS.Data==max(tscP.lapNumS.Data)-1))

%Calculate Orient Power
pOrientI2=find(min(abs(tsc.turbPow.Time-(orientExitTime)))==abs(tsc.turbPow.Time-(orientExitTime)));
pOrientI1=find(min(abs(tsc.turbPow.Time-(orientExitTime-period)))==abs(tsc.turbPow.Time-(orientExitTime-period)));

pOrient=mean(tsc.turbPow.Data(pOrientI1:pOrientI2))
tOrient=mean(tsc.gndNodeTenVecs.mag.Data(pOrientI1:pOrientI2))

%Calculate PosAugPower
pAugIndex=find(min(abs(tsc.turbPow.Time-(tsc.turbPow.Time(end)-period*3)))==abs(tsc.netPower.Time-(tsc.netPower.Time(end)-period*3)));

pPosAug=mean(tsc.turbPow.Data(pAugIndex:end))
tPosAug=mean(tsc.gndNodeTenVecs.mag.Data(pAugIndex:end));
aoaPosAug=mean(tsc.vhclAngleOfAttack.Data(pAugIndex:end));
sideslipPosAug=mean(abs(tsc.vhclSideSlipAngle.Data(pAugIndex:end)));
Vavg=mean(tsc.velocityVec.mag.Data(pAugIndex:end));
Vmax=max(tsc.velocityVec.mag.Data(pAugIndex:end));
altAvg=mean(tsc.positionVec.Data(3,pAugIndex:end));



R.AoA((flwI),(altI))=aoaPosAug;
R.Power((flwI),(altI))=pPosAug
R.Tension((flwI),(altI))=tPosAug;
R.Sideslip((flwI),(altI))=sideslipPosAug;
R.Vmax((flwI),(altI))=Vmax;
R.Vavg((flwI),(altI))=Vavg;
R.Altavg((flwI),(altI))=altAvg;
R.thrL((flwI),(altI))=thrLength;
R.aRoll{flwI,altI}=aRoll;
R.bRoll{flwI,altI}=bRoll;


R.aYaw{flwI,altI}=aYaw;
R.bYaw{flwI,altI}=bYaw;

R.freqs(flwI,altI)=FREQ;

R.pLoyd(flwI,altI)=pLoyd;
R.tLoyd(flwI,altI)=tLoyd;


R.pPath(flwI,altI)=powPath;
R.tPath(flwI,altI)=tPath;


R.pOrient(flwI,altI)=pOrient;
R.tOrient(flwI,altI)=tOrient;

APow=R.Power;
if simScenario(6)
                save(strcat(simSavePath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn','R','tscP')
end
 


% 
% figure(999);
% hold on;
% grid on
% scatter(flwSpd,powPath/pLoyd,'rx')
% scatter(flwSpd,pOrient/pLoyd,'go')
% scatter(flwSpd,pPosAug/pLoyd,'bsquare')
% xlabel('Flow Speed (units)')
% ylabel('Loyd-Normalized Lap-Averaged Power')
% title('Loyd-Normalized Power vs Flow Speed')
% legend({'Path-Following','Orientation','Position Augmented'})
% 
% 
% figure(888);
% hold on;
% grid on
% scatter(flwSpd,tPath/tLoyd,'rx')
% scatter(flwSpd,tOrient/tLoyd,'go')
% scatter(flwSpd,tPosAug/tLoyd,'bsquare')
% xlabel('Flow Speed (units)')
% ylabel('Loyd-Normalized Lap-Averaged Tension')
% title('Loyd-Normalized Tension vs Flow Speed')
% legend({'Path-Following','Orientation','Position Augmented'})

