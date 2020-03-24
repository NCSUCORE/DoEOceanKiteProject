if ~exist('CL','var')
    TLs=[50 40 30 100:-10:60 100:-10:60 100:-10:60];
    FlowSpeeds=[ones(1,8)*.5 ones(1,5) ones(1,5)*2];
    alphaLocal=cell(length(TLs),1);
    CL=cell(length(TLs),1);
    CD=cell(length(TLs),1);
    vAppLclBdy=cell(length(TLs),1);
    pos=cell(length(TLs),1);
    times=cell(length(TLs),1);
    tscs=cell(length(TLs),1);
end

% %% Script to run ILC path optimization
% clear;clc;close all
for i = 1:8
simParams = SIM.simParams;
simParams.setDuration(1000,'s');
dynamicCalc = '';

%% Load components
% Flight Controller
loadComponent('pathFollowingCtrlForILC');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('constBoothLem')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('constXYZT');

%% Environment IC's and dependant properties
env.water.setflowVec([FlowSpeeds(i) 0 0],'m/s')

%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([1,1.4,0.36,0*pi/180,TLs(i)],'') % Lemniscate of Booth
%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... % Center point of path sphere
    (11/2)*norm([ 1 0 0 ])) % Initial speed

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
%% Winches IC's and dependant properties
% wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,[ 1 0 0]);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
vhcl.addedMass.setValue(zeros(3,3),'kg')
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);
simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);
plotTetherLengths
title(i)

    alphaLocal{i}=tsc.alphaLocal.Data;
    CL{i}=tsc.CL.Data;
    CD{i}=tsc.CD.Data;
    vAppLclBdy{i}=tsc.vAppLclBdy.Data;
    posMat=zeros(3,5,length(tsc.positionVec.Time));

    for ii=1:length(tsc.positionVec.Time)
        cmpos=tsc.positionVec.Data(:,:,ii);
        posMat(:,:,ii)= repmat(cmpos(:),1,5) +...
                        rotation_sequence(tsc.eulerAngles.getsampleusingtime(tsc.positionVec.Time(ii)).Data(:))*...
                        [vhcl.portWing.aeroCentPosVec.Value(:) vhcl.stbdWing.aeroCentPosVec.Value(:)...
                        vhcl.hStab.aeroCentPosVec.Value(:) vhcl.vStab.aeroCentPosVec.Value(:) zeros(3,1)];

    end
    pos{i}=posMat;
    times{i}=tsc.CL.Time;
    save(sprintf("kelseyAllVar%g.mat",i))

end

% %%
% vhcl.animateSim(tsc,1,...
%     'PathFunc',fltCtrl.fcnName.Value,...
%     'PlotTracer',true,...
%     'FontSize',24,...
%     'PowerBar',false,...
%     'PlotAxes',false,...
%     'TracerDuration',10,...
%     'SaveGif',false)