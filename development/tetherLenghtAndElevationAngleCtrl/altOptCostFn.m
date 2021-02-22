function [jVal,varargout] = altOptCostFn(sKp1_Kp1,sigKp1_Kp1,fHat,sigF,...
    zTraj,zDiscrete,Amat,Qmat,Hmat,R,Ks,Ks12,covAmp,altScale,...
    tradeOffCons,powerLawParams)

% calculate prediction mean and variance over z trajectory
[predMean,postVar] = altitudeOptMPC_FlowPredictions(sKp1_Kp1,...
    sigKp1_Kp1,fHat,sigF,zTraj,zDiscrete,Amat,Qmat,Hmat,R,Ks,Ks12,...
    covAmp,altScale,powerLawParams);

% calculate cost function
jExploit = predMean(:).^3;
jExplore = postVar(:).^(3/2);
jVal = sum(jExploit) + (2^tradeOffCons)*sum(jExplore);
jVal = -jVal;
% other outputs
varargout{1} = jExploit(:);
varargout{2} = jExplore(:);
% [zTraj./1000 predMean postVar]

end

