%% Test script for John to control the kite model
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario
simScenario = 1.3;

%%  Set Test Parameters
% Flag to save results
saveSim = 1;                                              
% Flow speed [m/s]
flwSpd = 6.2:1:20;  
% tether length [m]
thrLength = 400:100:1200;
% elevation angle [rad]
elev = (10:5:40)*pi/180;

% Path width,height, and corresponding basis parameters
w = 28*pi/180;      
h = w/5;      
[a,b] = boothParamConversion(w,h);                     

%%
Pavg = NaN(numel(flwSpd),numel(elev),numel(thrLength));
AoA  = Pavg;    Tmax = Pavg;    Pnet = Pavg;        CL   = Pavg;
CD = Pavg;      Fdrag = Pavg;   Flift = Pavg;       Ffuse = Pavg;
Fthr = Pavg;    Fturb = Pavg;   elevation = Pavg;   altitude = Pavg;
Vavg = Pavg;

tic
for ii = 1:size(Pavg,1)
    for jj = 1:size(Pavg,2)
        for kk = 1:size(Pavg,3)
            eff = .95;
            fpath = fullfile(fileparts(which('OCTProject.prj')),...
                'vehicleDesign\Tether\Tension\');
            altitude(ii,jj,kk) = thrLength(kk)*sin(elev(jj));
            sw = thrLength(kk)*sind(5);
            if altitude(ii,jj,kk) - sw <= 0 || altitude(ii,jj,kk) > 950
                el = NaN;
            else
                el = elev(jj);
            end
            Simulink.sdi.clear
            %%  Load components
            loadComponent('constBoothLem');                             %   High level controller
            hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,...
                thrLength(kk)],'[rad rad rad rad m]')                   %   Lemniscate of Booth
            hiLvlCtrl.maxNumberOfSimulatedLaps.setValue(5,'');
            SPOOLINGCONTROLLER = 'netZeroSpoolingController';
            loadComponent('ayazPathFollowingAirborne');                 %   Path-following controller with AoA control
            loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
            loadComponent('pathFollowingGndStn');                       %   Ground station
            loadComponent('ayazFullScaleOneThrWinch');                  %   Winches
            loadComponent('ayazAirborneThr');                           %   Manta Ray tether
            loadComponent('idealSensors')                               %   Sensors
            loadComponent('idealSensorProcessing')                      %   Sensor processing
            loadComponent('realisticAirborneVhcl');                     %   AWE vehicle
            
            %%  Environment Properties
            loadComponent('ayazAirborneFlow.mat');                      %   Environment
            env.water.flowVec.setValue([flwSpd(ii);0;0],'m/s');         %   m/s - Flow speed vector
            
            %% Ground Station IC's and dependant properties
            gndStn.setPosVec([0 0 0],'m')
            gndStn.initAngPos.setValue(0,'rad');
            gndStn.initAngVel.setValue(0,'rad/s');
            
            %% Set vehicle initial conditions
            vhcl.setICsOnPath(...
                .05,...                                 % Initial path position
                PATHGEOMETRY,...                        % Name of path function
                hiLvlCtrl.basisParams.Value,...         % Geometry parameters
                gndStn.posVec.Value,...                 % Center point of path sphere
                (11/2)*norm(env.water.flowVec.Value))   % Initial speed
            
            %% Tethers IC's and dependant properties
            thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
                +gndStn.posVec.Value(:),'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            
            thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
            thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
            
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            
            %% Winches IC's and dependant properties
            wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
            
            %% path following controller
            fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
                hiLvlCtrl.basisParams.Value,...
                gndStn.posVec.Value);
            
            fltCtrl.elevatorReelInDef.setValue(0,'deg');
            
            %%  print
            fprintf('\nFlow Speed = %.3f m/s;\tElevation = %.2f deg;\t ThrLength = %d m\n',flwSpd(ii),elev(jj)*180/pi,thrLength(kk));
            
            %%  Simulate
            if ~isnan(el)
                try
                    simParams = SIM.simParams;  simParams.setDuration(3600,'s');  dynamicCalc = '';
                    simWithMonitor('OCTModel','timeStep',60)
                    %%  Log Results
                    tsc = signalcontainer(logsout);
                    stats = computeSimLapStats(tsc);
                    dt = datestr(now,'mm-dd_HH-MM');
                    [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  
                    ran = Idx1:Idx2;
                    [CLtot,CDtot] = tsc.getCLCD(vhcl);
                    [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
                    Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
                    Pavg(ii,jj,kk) = stats{2,4};    
                    Pnet(ii,jj,kk) = Pavg(ii,jj,kk)*eff;
                    Vavg(ii,jj,kk) = stats{2,8};
                    AoA(ii,jj,kk) = stats{2,9};
                    airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
                    gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
                    Tmax(ii,jj,kk) = max([max(airNode(ran)) max(gndNode(ran))]);
                    fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN;\t Elevation = %.1f\n',AoA(ii,jj,kk),Tmax(ii,jj,kk),el*180/pi);
                    CL(ii,jj,kk) = mean(CLtot(ran));   CD(ii,jj,kk) = mean(CDtot(ran));
                    Fdrag(ii,jj,kk) = mean(Drag(ran)); Flift(ii,jj,kk) = mean(Lift(ran));
                    Ffuse(ii,jj,kk) = mean(Fuse(ran)); Fthr(ii,jj,kk) = mean(Thr(ran));   Fturb(ii,jj,kk) = mean(Turb(ran));
                    elevation(ii,jj,kk) = el*180/pi;
                    filename = sprintf(strcat('Turb%.1f_V-%.3f_EL-%.2f_Thr-%d.mat'),simScenario,flwSpd(ii),elev(jj)*180/pi,thrLength(kk));
                    fpath = 'D:\Work\Thr-L EL Study\';
                    [status,msg,msgID] = mkdir(fpath);
                    save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','gndStn')
                    
                catch
                    fprintf('Simulation or statistics computation failed.\n');
                end
            else
                    fprintf('Elevation angle condition not met.\n');
            end
        end
    end
end
toc
%%
filename1 = sprintf('ThrEL_Study_Airborne.mat');
fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output\');
save([fpath1,filename1],'Pavg','Pnet','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr',...
    'Fturb','thrLength','elevation','flwSpd','Tmax','altitude','elev','Vavg')

