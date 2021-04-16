function [altSPTraj,elevSPTraj,thrSPTraj] = ...
    calculateOmniAltitudeSPTraj(synAlt,synFlow,hiLvlCtrl,...
    initVal,simTime)


options = optimoptions('fmincon','algorithm','sqp','display','notify');

%% use fminc to solve for best trajectory
% constraints
duMax = hiLvlCtrl.maxStepChange;
nP  = hiLvlCtrl.predictionHorz;
Astep = zeros(nP-1,nP);
bstep = duMax*ones(2*(nP-1),1);
for ii = 1:nP-1
    for jj = 1:nP
        if ii == jj
            Astep(ii,jj) = -1;
            Astep(ii,jj+1) = 1;
        end
        
    end
end
Astep = [Astep;-Astep];
% bounds on first step
fsBoundsA = zeros(2,nP);
fsBoundsA(1,1) = 1;
fsBoundsA(2,1) = -1;
A = [fsBoundsA;Astep];
% upper and lower bounds
lb      = hiLvlCtrl.minVal*ones(1,nP);
ub      = hiLvlCtrl.maxVal*ones(1,nP);

tVals = 0:hiLvlCtrl.mpckfgpTimeStep:simTime/60;
optAlt = 0*tVals;
optEl  = 0*tVals;
optThr  = 0*tVals;

for ii = 1:numel(tVals)
    if ii == 1
        optAlt(ii) = initVal(1);
        optEl(ii)  = initVal(2);
        optThr(ii) = initVal(3);
    else
        fsBoundsB(1,1) = optAlt(ii-1) + duMax;
        fsBoundsB(2,1) = -(optAlt(ii-1) - duMax);
        b = [fsBoundsB;bstep];
        
        % optimize
        [optTraj,~] = ...
            fmincon(@(u) -calcObjectiveForOmniscientAlt(u,tVals(ii),...
            synFlow,synAlt,hiLvlCtrl),optAlt(ii-1)*ones(nP,1),A,b,[],[]...
            ,lb,ub,[],options);
        
        optAlt(ii) = optTraj(1);
        
        [~,elTraj,thrTraj] = calcObjectiveForOmniscientAlt(optTraj,tVals(ii),...
            synFlow,synAlt,hiLvlCtrl);
        
        optEl(ii)  = elTraj(1);
        optThr(ii) = thrTraj(1);
    end
    
end

altSPTraj  = timeseries(optAlt,tVals*60);
elevSPTraj = timeseries(optEl,tVals*60);
thrSPTraj  = timeseries(optThr,tVals*60);

end