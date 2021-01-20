function [jVal,varargout] = altOptCostFn(sKp1_Kp1,sigKp1_Kp1,zTraj,...
   zDiscrete,Amat,Qmat,Hmat,R,Ks,Ks12,covAmp,altScale,tradeOffCons,...
   powerLawParams)

% calculate prediction mean and variance over z trajectory
[predMean,postVar] = altitudeOptMPC_FlowPredictions(sKp1_Kp1,...
    sigKp1_Kp1,zTraj,zDiscrete,Amat,Qmat,Hmat,R,Ks,Ks12,covAmp,altScale,...
    powerLawParams);

% calculate acquisition function
jVal = sum(predMean(:)) + (2^tradeOffCons)*sum(postVar(:));
jVal = -jVal;
% other outputs
varargout{1} = predMean(:);
varargout{2} = postVar(:);

end

