function [A,Q,H,R,Ks,Ks12,varargout] = kfgp_init(xMeasure,covAmp,...
    spatialScale,noiseVar,tempKernel,timeStep,timeScale)

% number of discretized altitudes
nAlt = length(xMeasure);
% make spatial covariance matrix
Ks = spatialCovariance(xMeasure(:),xMeasure(:),covAmp,spatialScale);
% root of spatial covariance matrix
Ks12 = sqrtm(Ks);
% noise variance term
R = noiseVar;
% formulate discrete time state matrices for kalman filtering step of KFGP
switch lower(tempKernel)
    case 'exponential'
        F = exp(-timeStep/timeScale);
        G = 1;
        H = sqrt(2/timeScale);
        Q = 0.5*timeScale*(1 - exp(-2*timeStep/timeScale));
        sig0 = lyap(F,G*G');
    case 'squaredexponential'
        [F,Q,H,sig0] = initializeKFGPForSquaredExponentialKernel(timeStep,...
            timeScale);
end
% make the matrices
A      = kron(eye(nAlt),F);
Q      = kron(eye(nAlt),Q);
H      = kron(eye(nAlt),H);
sigma0 = kron(eye(nAlt),sig0);
s0     = zeros(length(sigma0),1);
% variable output
varargout{1} = s0;
varargout{2} = sigma0;

end

