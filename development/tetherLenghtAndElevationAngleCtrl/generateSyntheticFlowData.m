function [flow,alts] = generateSyntheticFlowData(tempKernel,altitudes,...
    finalTime,timeStep,altScale,covAmp,timeScale,stdDev,powerLawParams,...
    minFlowValue,rngSeed)
% change rng Seed
rng(rngSeed);

% local variables
noiseVar = 0.0001;
timeVals = 0:timeStep:finalTime;

% % IDK why this is here, but Ben has it so I am leaving it
zstep = mean(diff(altitudes));
altitudes = (altitudes(1)-5*zstep):zstep:(altitudes(end)+5*zstep);
timeVals = (timeVals(1)-5*timeStep):timeStep:(timeVals(end)+5*timeStep);

% altitude covariances
spatialCovMat = spatialCovariance(altitudes,altitudes,covAmp,altScale);
spatialCovMat = spatialCovMat + noiseVar*eye(numel(altitudes));
Lz = chol(spatialCovMat,'lower');

% time covariances
switch lower(tempKernel)
    case 'exponential'
        temporalCovMat = exp(-(abs(timeVals-timeVals'))./timeScale);
    case 'squaredexponential'
        temporalCovMat = spatialCovariance(timeVals,timeVals,1,timeScale);
end
temporalCovMat = temporalCovMat + noiseVar*eye(numel(timeVals));
Lt = chol(temporalCovMat,'lower');

% random sampling
samp = stdDev*(randn(numel(altitudes),numel(timeVals)));

% mean functions
[~,M] = meshgrid(timeVals,powerLaw(altitudes,powerLawParams(1),...
    powerLawParams(2)));

% output
filterSamp = (Lz*(Lt*samp')') + M;

% select values from 6 to end-5
filterSamp = filterSamp(6:end-5,6:end-5);
filterSamp(filterSamp<minFlowValue) = minFlowValue;
timeVals  = timeVals(6:end-5);
altitudes  = altitudes(6:end-5);

% outputs
flow = timeseries(filterSamp,timeVals,'Name','SyntheticFlowVals');
alts = timeseries(repmat(altitudes(:),1,1,2),...
    [timeVals(1) timeVals(end)],'Name','SyntheticFlowAlts');

end