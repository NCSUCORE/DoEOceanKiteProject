function [predMean,postVar] = altitudeOptMPC_FlowPredictions(sKp1_Kp1,...
    sigKp1_Kp1,zTraj,zDiscrete,Amat,Qmat,Hmat,R,Ks,Ks12,covAmp,altScale,...
    powerLawParams)

% prediction horizon
nP = numel(zTraj);
% number of altitudes
nZ = numel(zDiscrete);
% preallocate output matrices
predMean = zeros(nP,1);
postVar  = zeros(nP,1);
% loop over z trajectory
for ii = 1:nP
    if ii == 1
        sk_k = sKp1_Kp1;
        ck_k = sigKp1_Kp1;
    else
        sk_k = skp1_kp1;
        ck_k = ckp1_kp1;
    end
    % kalman state update
    skp1_k = Amat*sk_k;
    % error covaraince update
    ckp1_k = Amat*ck_k*Amat' + Qmat;
    % Cmatrix
    Ik = calculateIndicatorMat(zTraj(ii),zDiscrete);
    Cmat = Ik*Ks12*Hmat;
    % kalman gain
    Lk = calculateKalmanGain(Cmat,ckp1_k,R);
    % kalman corrected state update
    skp1_kp1 = skp1_k;
    % kalman correct error covariance
    ckp1_kp1 = ckp1_k - Lk*Cmat*ckp1_k;
    
    % regression over measurement space
    fk = Ks12*Hmat*skp1_kp1;
    sigFk = Ks12*Hmat*ckp1_kp1*Hmat'*Ks12;
    
    % calculate relevant spatial covariaces
    kxM_xstar = spatialCovariance(zDiscrete(:),zTraj(ii),...
        covAmp,altScale);
    kxstar_xstar = spatialCovariance(zTraj(ii),zTraj(ii),...
        covAmp,altScale);
    
    % regression over zTraj
    kInvK = kxM_xstar'/Ks;
    mX    = powerLaw(zTraj(ii),powerLawParams(1),powerLawParams(2));
    predMean(ii) = mX - kInvK*fk;
    postVar(ii) = kxstar_xstar - diag(kInvK*(eye(nZ)*kxM_xstar -...
        sigFk*kInvK'));
    
end

end