function [val,varargout] = generateSyntheticFlowData(obj,altitudes,...
    finalTime,stdDev,varargin)
% parse inputs
pp = inputParser;
addParameter(pp,'timeStep',1,@isnumeric);
addParameter(pp,'meanFunc',obj.meanFunction);
addParameter(pp,'spatialLengthScale',obj.spatialLengthScale);
addParameter(pp,'temporalLengthScale',obj.temporalLengthScale);

parse(pp,varargin{:});

% use the gaussian process classdef to calculate the covariances
obj.spatialCovAmp = 1;
obj.spatialLengthScale = pp.Results.spatialLengthScale;
obj.temporalCovAmp = 1;
obj.temporalLengthScale = pp.Results.temporalLengthScale;

% local variables
noiseVar = 0.0001;
timeVals = 0:pp.Results.timeStep:finalTime;

% % IDK why this is here, but Ben has it so I am leaving it
zstep = mean(diff(altitudes));
tstep = pp.Results.timeStep;
altitudes = (altitudes(1)-5*zstep):zstep:(altitudes(end)+5*zstep);
timeVals = (timeVals(1)-5*tstep):tstep:(timeVals(end)+5*tstep);

% altitude covariances
spatialCovMat = obj.makeSpatialCovarianceMatrix(altitudes);
spatialCovMat = spatialCovMat + noiseVar*eye(numel(altitudes));
Lz = chol(spatialCovMat,'lower');

% time covariances
temporalCovMat = obj.makeTemporalCovarianceMatrix(timeVals);
temporalCovMat = temporalCovMat + noiseVar*eye(numel(timeVals));
Lt = chol(temporalCovMat,'lower');

% random sampling
samp = stdDev*(randn(numel(altitudes),numel(timeVals)));

% mean functions
[~,M] = meshgrid(timeVals,pp.Results.meanFunc(altitudes));

% output
filterSamp = (Lz*(Lt*samp')') + M;

% convert time to seconds and output a time series object
timeInSec = timeVals*60;

% select values from 6 to end-5
filterSamp = filterSamp(6:end-5,6:end-5);
filterSamp(filterSamp<0) = 0;
timeInSec  = timeInSec(6:end-5);
altitudes  = altitudes(6:end-5);

% outputs
val = timeseries(filterSamp,timeInSec,'Name','SyntheticFlowData');
varargout{1} = ...
    timeseries(repmat(altitudes(:),1,1,2),[timeInSec(1) timeInSec(end)]);

end

