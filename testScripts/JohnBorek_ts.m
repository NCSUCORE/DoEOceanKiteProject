%% Test script for John to control the kite model
clear; %clc;
Simulink.sdi.clear
%% Simulation Setup
% 1 - choose vehicle design:        1 = AR8b8, 2 = AR9b9, 3 = AR9b10, 4 = DOE
% 2 - choose high level controller: 1 = const basis, 2 = variable alt, 3 = const basis/state flow
% 3 - choose flight controller:     1 = pathFlow, 2 = full cycle, 3 = steady, 4 = reel-in
% 4 - choose tether:                1 = Manta, 2 = Reel-in, 3 = Manta multi-node
% 5 - choose environment:           1 = const flow, 2 = variable flow.
% 6 - save simulation results     
% 7 - animate    
% 8 - plotting 
%%             1 2 3 4 5  6    7     8
simScenario = [1 3 2 2 1 false false false];
thrLength = 450;  altitude = 200;                           %   m/m - Initial tether length/operating altitude
flwSpd = .25;                                               %   m/s - Flow speed
Tmax = 20;        Tdiam = 12.5;                             %   kN/mm - Max tether tension/tether diameter 
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
subCtrl = 1;    sC = 1;
TD = 1;
for ii = 1:numel(TD)
%%  Load components
switch simScenario(1)                                   %   Vehicle 
    case 1
        loadComponent('Manta2RotXFoil_AR8_b8');             %   AR = 8; 8m span
    case 2
        loadComponent('Manta2RotXFoil_AR9_b9');             %   AR = 9; 9m span
    case 3
        loadComponent('Manta2RotXFoil_AR9_b10');            %   AR = 9; 10m span
    case 4
        loadComponent('fullScale1thr');                     %   DOE kite
end
vhcl.turb1.setDiameter(TD(ii),'m'); vhcl.turb2.setDiameter(TD(ii),'m');
switch simScenario(2)                                   %   Flight Controller 
    case 1
        loadComponent('constBoothLem');                     %   Constant basis parameters
        el = asin(altitude/thrLength);                      %   rad - Initial elevation angle 
        hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,... %   Initialize basis parameters 
            thrLength],'[rad rad rad rad m]');
    case 2
        loadComponent('varAltitudeBooth');                  %   Variable altitude controller
        el = asin(altitude/thrLength);                      %   rad - Initial elevation angle 
        hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,... %   Initialize basis parameters 
            thrLength],'[rad rad rad rad m]');
        hiLvlCtrl.ELctrl.setValue(1,'');
        hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
        hiLvlCtrl.ThrCtrl.setValue(1,'');
    case 3
        loadComponent('mantaFSHiLvl');                     %   Constant basis parameters
        el = asin(altitude/thrLength);                      %   rad - Initial elevation angle 
        hiLvlCtrl.stateCtrl.setValue(sC,'');
        hiLvlCtrl.stateConst.setValue(subCtrl,'');
        hiLvlCtrl.preXelevation.setValue(max(el-h,5*pi/180),'rad')
        hiLvlCtrl.initXelevation.setValue(max(el-h/2,5*pi/180),'rad')
        hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,... %   Initialize basis parameters 
            thrLength],'[rad rad rad rad m]');
end
switch simScenario(3)                                   %   Flight Controller 
    case 1
        loadComponent('pathFollowWithAoACtrl');             %   Path-following controller with AoA control
    case 2
        loadComponent('pathFollowWithAoACtrl');             %   Path-following controller with AoA control
        pthCtrl1 = fltCtrl;   
        pthCtrl1.fcnName.setValue('lemOfBooth','');       
        pthCtrl2 = fltCtrl;
%         pthCtrl2.fcnName.setValue('ellipse','');       
        loadComponent('LaRController');                     %   Launch and recovery controller
        slfCtrl = fltCtrl;
        loadComponent('MantaFSController');                 %   Path-following controller with AoA control
    case 3
%         loadComponent('LaRController');                     %   Launch and recovery controller
        loadComponent('SteadyController');                  %   Steady-flight controller
    case 4
        loadComponent('LaRController');                     %   Launch and recovery controller
end
switch simScenario(4)                                   %   Tether model 
    case 1
        loadComponent('MantaTether');                       %   Manta Ray tether
    case 3
        loadComponent('MantaTetherReal');                       %   Manta Ray tether
    otherwise
        loadComponent('shortTether');                       %   Tether for reeling
        thr.tether1.setInitTetherLength(thrLength,'m');     %   Initialize tether length 
end
switch simScenario(5)                                   %   Environment 
    case 1
        loadComponent('ConstXYZT');                         %   Constant flow 
        ENVIRONMENT = 'environmentManta2Rot';               %   Two turbines
        env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
    case 2
        loadComponent('ConstYZTvarX');                      %   Variable X
        ENVIRONMENT = 'environmentManta2Rot';               %   Two turbines
        env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
end
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
loadComponent('MantaGndStn');                               %   Ground station
loadComponent('winchManta');                                %   Winches
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
%%  Vehicle Initial Conditions 
if simScenario(3) == 1 
    vhcl.setICsOnPath(0.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,6.5*flwSpd)
else
    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
    vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
end
%%  Tethers Properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(3.7e10,'Pa');
thr.tether1.density.setValue(2226,'kg/m^3');
thr.tether1.setDiameter(Tdiam*1e-3,'m');
%%  Winches Properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.LaRspeed.setValue(1,'m/s');
%%  Controller User Def. Parameters and dependant properties
switch simScenario(3)
    case 1
        fltCtrl.setFcnName(PATHGEOMETRY,'');
        fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
        fltCtrl.AoASP.setValue(1,'');                           fltCtrl.AoAConst.setValue(vhcl.optAlpha.Value*pi/180,'deg');
        fltCtrl.AoACtrl.setValue(1,'');                         fltCtrl.Tmax.setValue(Tmax-0.5,'kN');
        fltCtrl.alphaCtrl.kp.setValue(.2,'(rad)/(kN)');         fltCtrl.alphaCtrl.ki.setValue(.08,'(rad)/(kN*s)');         
        fltCtrl.elevCtrl.kp.setValue(125,'(deg)/(rad)');        fltCtrl.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
        fltCtrl.rollCtrl.kp.setValue(150,'(deg)/(rad)');        fltCtrl.rollCtrl.ki.setValue(1,'(deg)/(rad*s)');
        fltCtrl.rollCtrl.kd.setValue(150,'(deg)/(rad/s)');      fltCtrl.rollCtrl.tau.setValue(0.001,'s');
    case 2
        fltCtrl.maxTL.setValue(thrLength,'m');
        pthCtrl1.setFcnName(PATHGEOMETRY,'');
        pthCtrl1.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
        pthCtrl1.AoASP.setValue(1,'');                           pthCtrl1.AoAConst.setValue(vhcl.optAlpha.Value*pi/180,'deg');
        pthCtrl1.AoACtrl.setValue(1,'');                         pthCtrl1.Tmax.setValue(Tmax-.5,'kN');
        pthCtrl1.alphaCtrl.kp.setValue(.2,'(rad)/(kN)');         pthCtrl1.alphaCtrl.ki.setValue(.08,'(rad)/(kN*s)');         
        pthCtrl1.elevCtrl.kp.setValue(125,'(deg)/(rad)');        pthCtrl1.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
        pthCtrl1.rollCtrl.kp.setValue(200,'(deg)/(rad)');        pthCtrl1.rollCtrl.ki.setValue(0,'(deg)/(rad*s)');
        pthCtrl1.rollCtrl.kd.setValue(150,'(deg)/(rad/s)');      pthCtrl1.rollCtrl.tau.setValue(0.001,'s');
        pthCtrl2.setFcnName(PATHGEOMETRY,'');
        pthCtrl2.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
        pthCtrl2.AoASP.setValue(1,'');                           pthCtrl2.AoAConst.setValue(vhcl.optAlpha.Value*pi/180,'deg');
        pthCtrl2.AoACtrl.setValue(1,'');                         pthCtrl2.Tmax.setValue(Tmax-.5,'kN');
        pthCtrl2.alphaCtrl.kp.setValue(.2,'(rad)/(kN)');         pthCtrl2.alphaCtrl.ki.setValue(.08,'(rad)/(kN*s)');         
        pthCtrl2.elevCtrl.kp.setValue(125,'(deg)/(rad)');        pthCtrl2.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
        pthCtrl2.rollCtrl.kp.setValue(200,'(deg)/(rad)');        pthCtrl2.rollCtrl.ki.setValue(0,'(deg)/(rad*s)');
        pthCtrl2.rollCtrl.kd.setValue(150,'(deg)/(rad/s)');      pthCtrl2.rollCtrl.tau.setValue(0.001,'s');
        slfCtrl.LaRelevationSP.setValue(el*180/pi,'deg');        slfCtrl.pitchCtrl.setValue(2,''); slfCtrl.pitchConst.setValue(0,'deg');
        slfCtrl.pitchAngleMax.upperLimit.setValue(20,'');        slfCtrl.pitchAngleMax.lowerLimit.setValue(-20,'')
    case 3
        fltCtrl.LaRelevationSP.setValue(45,'deg');
        fltCtrl.pitchCtrl.setValue(2,'');                   fltCtrl.pitchConst.setValue(-10,'deg');
        elevatorCtrl = 1;   tRef = 0:500:2000;    elevCommand = -2:2;
    case 4
        fltCtrl.LaRelevationSP.setValue(60,'deg');          fltCtrl.setNomSpoolSpeed(.0,'m/s');
end
vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
%%  Set up critical system parameters and run simulation
simParams = SIM.simParams;  simParams.setDuration(3000,'s');  dynamicCalc = '';
% if altitude >= 0.7071*thrLength || altitude <= 0.1736*thrLength
%     error('Elevation angle is out of range')
% end
simWithMonitor('OCTModel')
%%  Log Results
tsc = signalcontainer(logsout);
if simScenario(3) == 1
    Pow = tsc.rotPowerSummary(vhcl,env);
    [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
    AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
    airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
    gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
    ten = max([max(airNode(ran)) max(gndNode(ran))]);
    fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);
end
Pow = tsc.rotPowerSummary(vhcl,env);
[Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
Turb = squeeze(tsc.FTurbBdy.Data(1,1,:));
[Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
Fdrag = mean(Drag(ran));    Fthr = mean(Thr(ran));    Fturb = mean(Turb(ran));
fprintf('Pow = %.3f kW;\t Drag = %.2f N;\t Thr = %.2f N;\t Turb = %.2f N\n\n',Pow.avg,Fdrag,Fthr,Fturb);
switch simScenario(3)
    case 1
        filename = sprintf(strcat('Turb_V-%.3f_Alt-%d_thr-%d_Tmax-%d.mat'),flwSpd,altitude,thrLength,Tmax);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor\');
    case 2
        filename = sprintf(strcat('FS1_V-%.3f_Alt-%d_thr-%d_Tmax-%d.mat'),flwSpd,altitude,thrLength,Tmax);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','FS\');
    case 3
        filename = sprintf(strcat('Steady_EL-%.1f_kp-%.2f_ki-%.2f.mat'),el*180/pi,fltCtrl.elevCmd.kp.Value,fltCtrl.elevCmd.ki.Value);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Steady\');
    case 4
        filename = sprintf(strcat('LaR_V-%.3f_EL-%.1f_SP-%.1f_Wnch-%.1f.mat'),flwSpd,el*180/pi,fltCtrl.LaRelevationSP.Value,fltCtrl.nomSpoolSpeed.Value);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','LaR\');
end
if simScenario(6)
    save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
end
end
%%  Plot Results
if simScenario(8)
    switch simScenario(3)
        case 1
            lap = max(tsc.lapNumS.Data)-1;
            if max(tsc.lapNumS.Data) < 2
                tsc.plotFlightResults(vhcl,env,'plot1Lap',1==0,'plotS',1==0,'lapNum',lap,'dragChar',1==0,'cross',1==0)
            else
                tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',1==0,'lapNum',lap,'dragChar',1==0,'cross',1==0)
            end
        case 2
            tsc.plotFSslf(fltCtrl,'Steady',true);
        case 3
            tsc.plotLaR(fltCtrl,'Steady',true);
        case 4
            tsc.plotLaR(fltCtrl,'Steady',true);
    end
end
% set(gcf,'OuterPosition',[-773.4000   34.6000  780.8000  830.4000]);
%%  Animate Simulation
if simScenario(7)
    if simScenario(3) == 1
        vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',20,...
            'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',1==1,...
            'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'));
    elseif simScenario(3) == 2
        vhcl.animateSim(tsc,2,'PathFunc',pthCtrl2.fcnName.Value,'TracerDuration',20,...
            'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
            'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'));
    else
        vhcl.animateSim(tsc,2,'View',[0,0],'Pause',1==0,...
            'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==0,...
            'SaveGif',1==1,'GifFile',strrep(filename,'.mat','zoom.gif'));
    end
end
