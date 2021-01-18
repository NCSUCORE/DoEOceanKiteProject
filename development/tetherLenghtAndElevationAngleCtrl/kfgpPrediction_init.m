% number of discretized altitudes
nAlt = length(xMeasure);
% make spatial covariance matrix
Ks = zeros(nAlt);
for ii = 1:nAlt
    for jj = ii:nAlt
        Ks(ii,jj) = SquaredExponentialKernel(xMeasure(ii),xMeasure(jj),...
            [covAmp,spatialScale]);
    end
end
Ks = Ks + triu(Ks,1)';
Ks12 = sqrtm(Ks);

% formulate discrete time state matrices for kalman filtering step of KFGP
switch lower(hTau)
    case 'exponential'
        F = exp(-gpkfTimeStep/timeScale);
        G = 1;
        H = sqrt(2/timeScale);
        Q = 0.5*timeScale*(1 - exp(-2*gpkfTimeStep/timeScale));
        R = noiseVar;
    case 'squaredexponential'
        
end
% make the matrices
Amat     = kron(eye(nAlt),F);
Qmat     = kron(eye(nAlt),Q);
Hmat     = kron(eye(nAlt),H);
KsTimesH = Ks12*Hmat;
Rmat     = R;
sigma0   = kron(eye(nAlt),lyap(F,G*G'));
s0       = zeros(length(sigma0),1);

