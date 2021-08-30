clear
clc
% close all
cd(fileparts(mfilename('fullpath')));

%% load common paramters
% load parameters that are common for all simulations
commonSimParameters;
simParams.setDuration(150,'s');

%% sim sweep
maxElev = 50;
minElev = fltCtrl.pathHeight_deg/2;

zRange = 100:25:400;
flowSpeedRange = 0.5:0.25:2;
minThrLen = round(min(zRange)/sind(maxElev),-1);
minThrLen = minThrLen - mod(minThrLen,50) + 50;
thrLengthRange = minThrLen:100:600;

zRange = 100:400:400;
flowSpeedRange = 1:1:2;
thrLengthRange = minThrLen:100:2*minThrLen;


nZ  = numel(zRange);
nTL = numel(thrLengthRange);
nFS = numel(flowSpeedRange);
nSim = nZ*nTL*nFS;

% pre allocate
thrDragKN           = nan(nZ,nTL,nFS);
thrTensionKN        = thrDragKN;
winchPowerKW        = thrDragKN;
turbPowerKW         = thrDragKN;
turbEnergyKJ        = thrDragKN;
kiteSpeedMPS        = thrDragKN;
lapTimeS            = thrDragKN;
kiteAoADEG          = thrDragKN;
maxTanRollDEG       = thrDragKN;
maxTanRollDesDEG    = thrDragKN;
maxTurnAngleDEG     = thrDragKN;
vAppxMPS            = thrDragKN;
lapNumUL            = thrDragKN;
disTraveledM        = thrDragKN;
meanAltM            = thrDragKN;
vAppByvFlowUL       = thrDragKN;
vKiteByvFlowUL      = thrDragKN;
EL                  = thrDragKN;
Z                   = thrDragKN;
TL                  = thrDragKN;
FS                  = thrDragKN;

%% make directory
foldName            = 'resFilesDir';
[status,msg,msgID]  = mkdir([cd,'\',foldName]);

%% test parameters

simCt = 1;
ResCt = 1;
failCt = 1;
failRes = zeros(1,4);
for FSct = 1:nFS
    for TLct = 1:nTL
        for Zct = 1:nZ
            
            
            Z(Zct,TLct,FSct)  = zRange(Zct);
            TL(Zct,TLct,FSct) = thrLengthRange(TLct);
            FS(Zct,TLct,FSct) = flowSpeedRange(FSct);
            
            fprintf('Simulation %d of %d. Altitude = %.2f m, Tether length = %.2f m, Flow = %.2f m/s.\n',...
                [simCt, nFS*nTL*nZ,Z(Zct,TLct,FSct),TL(Zct,TLct,FSct),FS(Zct,TLct,FSct)]);
            simCt = simCt + 1;
            
            
            fName = [cd,'\',foldName,'\',sprintf('F,%.1f,TL,%.1f,Z,%.1f',[FS(Zct,TLct,FSct),TL(Zct,TLct,FSct),Z(Zct,TLct,FSct)])];
            
            aSinTerm = Z(Zct,TLct,FSct)/TL(Zct,TLct,FSct);
            lowestAlt = (sind(-fltCtrl.pathHeight_deg/2) + aSinTerm)*thrLengthRange(TLct);
            
            if aSinTerm <= sind(maxElev) && Z(Zct,TLct,FSct) > lowestAlt
                
                
                EL(Zct,TLct,FSct) = asind(aSinTerm);
                
                pathElev = EL(Zct,TLct,FSct);
                tLength  = TL(Zct,TLct,FSct);
                fSpeed   = FS(Zct,TLct,FSct);
                altVal   = Z(Zct,TLct,FSct);
                
                % simulation sweep parameters
                fltCtrl.pathElevation_deg	= pathElev;
                
                % Environment IC's and dependant properties
                env.water.setflowVec([fSpeed 0 0],'m/s')
                
                % Set vehicle initial conditions
                init_speed = 4*norm(env.water.flowVec.Value);
                [init_O_rKite,init_Euler,init_O_vKite,init_OwB,init_Az,init_El,init_OcB] = ...
                    getInitConditions(fltCtrl.initPathParameter,fltCtrl.pathWidth_deg,...
                    fltCtrl.pathHeight_deg,fltCtrl.pathElevation_deg,tLength,init_speed);
                vhcl.setInitPosVecGnd(init_O_rKite,'m');
                initVel = calcBcO(init_Euler)*init_O_vKite;
                vhcl.setInitVelVecBdy(initVel,'m/s');
                vhcl.setInitEulAng(init_Euler,'rad')
                % Initial angular velocity is zero
                vhcl.setInitAngVelVec(init_OwB,'rad/s');
                
                % wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
                wnch.winch1.initLength.setValue(norm(vhcl.initPosVecGnd.Value),'m')
                thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
                
                                
                try
                    % simulate
                    Simulink.sdi.clear;
                    simWithMonitor('OCTModel')
                    tsc = signalcontainer(logsout);
                                        
                    %%
                    % all results
                    close all
                    figure('WindowState','maximized');
                    plotResults(tsc);
                    
                    % lap results
                    lapStats = tsc.plotAndComputeLapStats(true);
                    
                    save([fName,'.mat'],'lapStats','pathElev','tLength','fSpeed','altVal');
                    exportgraphics(gcf,[fName,'.png'],'Resolution',200);
                    
                    figure;
                    plotDome;
                    pathCords = pathCoordEqn(fltCtrl.pathWidth_deg,...
                        fltCtrl.pathHeight_deg,fltCtrl.pathElevation_deg,1);
                    plot3(pathCords(1,:),pathCords(2,:),pathCords(3,:),'k-');
                    normPos = squeeze(tsc.positionVec.Data./...
                        vecnorm(tsc.positionVec.Data));
                    plot3(normPos(1,:),normPos(2,:),normPos(3,:),'r-');
                    hold on; grid on; axis equal; view(110,20);
                    xlabel('Norm. X'); ylabel('Norm. Y'); zlabel('Norm. Z');
                    exportgraphics(gcf,[fName,'-traj.png'],'Resolution',200);
                    
%                     % animations
%                     cIn = maneuverabilityAdvanced;
%                     cIn.pathWidth = fltCtrl.pathWidth_deg;
%                     cIn.pathHeight = fltCtrl.pathHeight_deg;
%                     cIn.meanElevationInRadians = fltCtrl.pathElevation_deg*pi/180;
%                     cIn.tetherLength = norm(init_O_rKite);
%                     
%                     figure; dynamicFigureLocations;
%                     tsc1 = tsc.resample(0.1);
%                     animateRes(tsc1,cIn);
                    
                    %% post process                    
                    % store results
                    thrDragKN           (Zct,TLct,FSct) = lapStats.thrDragKN;
                    thrTensionKN        (Zct,TLct,FSct) = lapStats.thrTensionKN;
                    winchPowerKW        (Zct,TLct,FSct) = lapStats.winchPowerKW;
                    turbPowerKW         (Zct,TLct,FSct) = lapStats.turbPowerKW;
                    turbEnergyKJ        (Zct,TLct,FSct) = lapStats.turbEnergyKJ;
                    kiteSpeedMPS        (Zct,TLct,FSct) = lapStats.kiteSpeedMPS;
                    lapTimeS            (Zct,TLct,FSct) = lapStats.lapTimeS;
                    kiteAoADEG          (Zct,TLct,FSct) = lapStats.kiteAoADEG;
                    maxTanRollDEG       (Zct,TLct,FSct) = lapStats.maxTanRollDEG;
                    maxTanRollDesDEG    (Zct,TLct,FSct) = lapStats.maxTanRollDesDEG;
                    maxTurnAngleDEG     (Zct,TLct,FSct) = lapStats.maxTurnAngleDEG;
                    vAppxMPS            (Zct,TLct,FSct) = lapStats.vAppxMPS;
                    lapNumUL            (Zct,TLct,FSct) = lapStats.lapNumUL;
                    disTraveledM        (Zct,TLct,FSct) = lapStats.disTraveledM;
                    meanAltM            (Zct,TLct,FSct) = lapStats.meanAltM;
                    vAppByvFlowUL       (Zct,TLct,FSct) = lapStats.vAppByvFlowUL;
                    vKiteByvFlowUL      (Zct,TLct,FSct) = lapStats.vKiteByvFlowUL;
                    
                    ResCt = ResCt + 1;
                    
                catch
                    failRes(failCt,:) = [pathElev,tLength,fSpeed,altVal];
                    failCt = failCt+1;
                    warning('Simulation or post-processing failed at Elevation = %.2f deg, Tether length = %.2f m, Flow = %.2f m/s, Altitude = %.1f m.\n',...
                        pathElev,tLength,fSpeed,altVal)
                end
                
            end
            
        end
    end
end

%% save all results
RES.thrDragKN           = thrDragKN;
RES.thrTensionKN        = thrTensionKN;
RES.winchPowerKW        = winchPowerKW;
RES.turbPowerKW         = turbPowerKW;
RES.turbEnergyKJ        = turbEnergyKJ;
RES.kiteSpeedMPS        = kiteSpeedMPS;
RES.lapTimeS            = lapTimeS;
RES.kiteAoADEG          = kiteAoADEG;
RES.maxTanRollDEG       = maxTanRollDEG;
RES.maxTanRollDesDEG    = maxTanRollDesDEG;
RES.maxTurnAngleDEG     = maxTurnAngleDEG;
RES.vAppxMPS            = vAppxMPS;
RES.lapNumUL            = lapNumUL;
RES.disTraveledM        = disTraveledM;
RES.meanAltM            = meanAltM;
RES.vAppByvFlowUL       = vAppByvFlowUL;
RES.vKiteByvFlowUL      = vKiteByvFlowUL;
RES.EL                  = EL;
RES.Z                   = Z;
RES.TL                  = TL;
RES.FS                  = FS;

failRes = table(failRes(:,1),failRes(:,2),failRes(:,3),failRes(:,4),...
    'VariableNames',{'Elevation [deg]','Tether length [m]',...
    'Flow speed [m/s]','Altitude [m]'});




