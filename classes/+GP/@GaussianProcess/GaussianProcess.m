classdef GaussianProcess
    
    % initialization requirements
    properties (SetAccess = protected)
        spatialKernel
        temporalKernel
        meanFunction
    end
    
    % hyper-parameter properties
    properties
        spatialLengthScale
        spatialCovAmp
        temporalLengthScale
        temporalCovAmp
        noiseVariance
    end
    
    % mean function properties
    properties
       meanFnProps 
    end
    
    % class parameters
    properties (SetAccess = protected)
        kernelChoices = {'exponential','squaredExponential','alwaysOne'};
        meanFnChoices = {'constantMean','windPowerLaw'};
    end
    
    %% constructor
    methods
        function obj = GaussianProcess(spatialKernel,...
                temporalKernel,meanFunction)
            
            switch nargin
                case 3
                    % check for valid inputs
                    obj.temporalKernel = temporalKernel;
                    obj.spatialKernel  = spatialKernel;
                    obj.meanFunction   = meanFunction;
                case 2
                    % check for valid inputs
                    obj.temporalKernel = temporalKernel;
                    obj.spatialKernel  = spatialKernel;
                    obj.meanFunction   = 'constantMean';
                otherwise
                    obj.temporalKernel = 'exponential';
                    obj.spatialKernel  = 'squaredExponential';
                    obj.meanFunction   = 'constantMean';
            end
            
        end
        
    end
    %% setters
    methods
        % set spatial kernel
        function obj = set.spatialKernel(obj,value)
            obj.spatialKernel = obj.checkKernelValidity(value);
        end
        
        % set temporal kernel
        function obj = set.temporalKernel(obj,value)
            obj.temporalKernel = obj.checkKernelValidity(value);
        end
        
        % set mean function
        function obj = set.meanFunction(obj,value)
            obj.meanFunction = obj.checkMeanFnValidity(value);
        end
        
        % set spatial length scale
        function obj = set.spatialLengthScale(obj,value)
            obj.spatialLengthScale = value(:);
        end
        
        
    end
    
    %% getters
    methods
        
    end
    
    %% private methods. input checks and stuff
    methods (Access = protected)
        % check kernel choice validity
        function val = checkKernelValidity(obj,ipKernel)
            if ismember(lower(ipKernel),lower(obj.kernelChoices))
                val = ipKernel;
            else
                error(['Only ',repmat('%s, ',1,numel(obj.kernelChoices)-1),...
                    'and %s are valid entries for kernels.',...
                    ' You entered %s.'],obj.kernelChoices{:},ipKernel);
            end
            % set values
            switch lower(ipKernel)
                case 'exponential'
                    val = @ExponentialKernel;
                case 'squaredexponential'
                    val = @SquaredExponentialKernel;
                case 'alwaysone'
                    val = @alwaysOneCovarianceKernel;
            end
        end
        
        % check mean function choice validity
        function val = checkMeanFnValidity(obj,ipMeanFn)
            if ismember(ipMeanFn,obj.meanFnChoices)
                val = ipMeanFn;
            else
                error(['Only ',repmat('%s, ',1,numel(obj.meanFnChoices)-1),...
                    'and %s are valid entries for kernels.',...
                    ' You entered %s.'],obj.meanFnChoices{:},ipMeanFn);
            end
            % set values
            switch ipMeanFn
                case 'constantMean'
                    val = @constantMeanFn;
                case 'windPowerLaw'
                    val = @windPowerLawMeanFn;
            end
        end
        
    end
    
    %%  methods related to covariance calculations
    methods
        % calculate spatial covariance
        function val = calcSpatialCovariance(obj,x1,x2)
            val = obj.spatialKernel(x1,x2,[obj.spatialCovAmp;...
                obj.spatialLengthScale]);
        end
        
        % calculate temporal covariance
        function val = calcTemporalCovariance(obj,t1,t2)
            val = obj.temporalKernel(t1,t2,[obj.temporalCovAmp;...
                obj.temporalLengthScale]);
        end
        
        % calculate total covariance
        function val = calcTotalCovariance(obj,x1,x2,t1,t2)
            val = obj.calcSpatialCovariance(x1,x2)*...
                obj.calcTemporalCovariance(t1,t2);
        end
        
        % make spatial covariance matrix
        function val = makeSpatialCovarianceMatrix(obj,X)
            % local variables
            nPOints = size(X,2);
            % preallocate
            val = zeros(nPOints);
            % loop throught each point and make lower triu matrix
            for ii = 1:nPOints
                for jj = 1:ii
                    val(ii,jj) = obj.calcSpatialCovariance(X(:,ii),X(:,jj));
                end
            end
            % make the total matrix
            val = val + tril(val,-1)';
        end
        
        % make temporal covariance matrix
        function val = makeTemporalCovarianceMatrix(obj,T)
            % local variables
            nPoints = size(T,2);
            % preallocate
            val = zeros(nPoints);
            % loop throught each point and make lower triu matrix
            for ii = 1:nPoints
                for jj = 1:ii
                    val(ii,jj) = obj.calcTemporalCovariance(T(:,ii),T(:,jj));
                end
            end
            % make the total matrix
            val = val + tril(val,-1)';
        end
        
        % make total covariance matrix
        function val = makeTotalCovarianceMatrix(obj,XT)
            % local variables
            nPoints = size(XT,2);
            % preallocate
            val = zeros(nPoints);
            % loop throught each point and make lower triu matrix
            for ii = 1:nPoints
                for jj = 1:ii
                    val(ii,jj) = obj.calcTotalCovariance(XT(1:end-1,ii),...
                        XT(1:end-1,jj),XT(end,ii),XT(end,jj));
                end
            end
            % make the total matrix
            val = val + tril(val,-1)';
        end
    end
    
    %% methods to caclualate various marginal likelihoods
    methods (Access = protected)
        % calculate spatial marginal likelihood.
        function val = calcSpatialMarginalLikelihood(obj,X,y,hyp)
            % update the object hyper-parameters
            obj.spatialCovAmp = hyp(1);
            obj.spatialLengthScale = hyp(2:end);
            % local variables
            noiseVar = obj.noiseVariance;
            nPoints  = numel(y);
            Kf = obj.makeSpatialCovarianceMatrix(X);
            Ky = Kf + eye(nPoints)*noiseVar;
            % log likelihood equation. Source: Rasmussen pg. 113
            dataFitPenalty      = -0.5*y'*(Ky\y);
            complexityPenalty   = -0.5*log(det(Ky));
            normalizingConstant = -0.5*nPoints*log(2*pi);
            val = dataFitPenalty + complexityPenalty + normalizingConstant;
        end
        
        % calculate temporal marginal likelihood
        function val = calcTemporalMarginalLikelihood(obj,T,y,hyp)
            % update the object hyper-parameters
            obj.temporalCovAmp = hyp(1);
            obj.temporalLengthScale = hyp(2);
            % local variables
            noiseVar = obj.noiseVariance;
            nPoints  = numel(y);
            Kf = obj.makeTemporalCovarianceMatrix(T);
            Ky = Kf + eye(nPoints)*noiseVar;
            % log likelihood equation. Source: Rasmussen pg. 113
            dataFitPenalty      = -0.5*y'*(Ky\y);
            complexityPenalty   = -0.5*log(det(Ky));
            normalizingConstant = -0.5*nPoints*log(2*pi);
            val = dataFitPenalty + complexityPenalty + normalizingConstant;
        end
        
        % calculate total marginal likelihood
        function val = calcTotalMarginalLikelihood(obj,XT,y,hyp)
            % update the object hyper-parameters
            obj.spatialCovAmp       = hyp(1);
            obj.spatialLengthScale  = hyp(2:end-2);
            obj.temporalCovAmp      = hyp(end-1);
            obj.temporalLengthScale = hyp(end);
            % local variables
            noiseVar = obj.noiseVariance;
            nPoints  = numel(y);
            Kf = obj.makeTotalCovarianceMatrix(XT);
            Ky = Kf + eye(nPoints)*noiseVar;
            % log likelihood equation. Source: Rasmussen pg. 113
            dataFitPenalty      = -0.5*y'*(Ky\y);
            complexityPenalty   = -0.5*log(det(Ky));
            normalizingConstant = -0.5*nPoints*log(2*pi);
            val = dataFitPenalty + complexityPenalty + normalizingConstant;
        end
        
    end
    
    %% methods to optimize hyper-parameters
    methods
        % optimize spatial hyper-parameters
        function val = findOptSpatialHyperParams(obj,X,y,iniGuess)
            % set optimization solver options
            options = optimoptions('fmincon','Display','notify');
            % local variables
            nHyps = numel(iniGuess);
            lb = 0.001*ones(nHyps,1);
            % find vals
            optVals = ...
                fmincon(@(hyp)-obj.calcSpatialMarginalLikelihood(X,y,hyp),...
                iniGuess,[],[],[],[],lb,[],[],options);
            % output
            val.opt_spatialCovAmp = optVals(1);
            val.opt_spatialLengthScale = optVals(2:end);
        end
        
        % optimize temporal hyper-parameters
        function val = findOptTemporalHyperParams(obj,T,y,iniGuess)
            % set optimization solver options
            options = optimoptions('fmincon','Display','notify');
            % local variables
            nHyps = numel(iniGuess);
            lb = 0.001*ones(nHyps,1);
            % find vals
            optVals = ...
                fmincon(@(hyp)-obj.calcTemporalMarginalLikelihood(T,y,hyp),...
                iniGuess,[],[],[],[],lb,[],[],options);
            % output
            val.opt_temporalCovAmp = optVals(1);
            val.opt_temporalLengthScale = optVals(2);
        end
        
        % optimize spatio-temporal hyper-parameters
        function val = findOptSpatioTemporalHyperParams(obj,XT,y,iniGuess)
            % set optimization solver options
            options = optimoptions('fmincon','Display','notify');
            % local variables
            nHyps = numel(iniGuess);
            lb = 0.001*ones(nHyps,1);
            % find vals
            optVals = ...
                fmincon(@(hyp)-obj.calcTotalMarginalLikelihood(XT,y,hyp),...
                iniGuess,[],[],[],[],lb,[],[],options);
            % output
            val.opt_spatialCovAmp       = optVals(1);
            val.opt_spatialLengthScale  = optVals(2:end-2);
            val.opt_temporalCovAmp      = optVals(end-1);
            val.opt_temporalLengthScale = optVals(end);
        end
        
        % update object to use the optimized hyper-parameters
        function obj = setOptimumHyperParameters(obj,val)
            obj.spatialCovAmp       = val.opt_spatialCovAmp;
            obj.spatialLengthScale  = val.opt_spatialLengthScale;
            obj.temporalCovAmp      = val.opt_temporalCovAmp;
            obj.temporalLengthScale = val.opt_temporalLengthScale;
        end
        
    end
    
    %% regression related methods
    methods
        % calculate prediction mean and posterior variance. Rasmussen pg. 17
        function [predMean,postVar] = calcPredMeanAndPostVar(obj,...
                covMat,XT,y,xStar)
            % local variables
            nTestPoints = size(xStar,2);
            nTrainPoints = numel(y);
            % pre-allocate matrices
            kx_xstar     = NaN(nTrainPoints,nTestPoints);
            kxstar_xstar = NaN(nTestPoints,1);
            % for kx_xstart and kxstar_xstar
            for ii = 1:nTestPoints
                for jj = 1:nTrainPoints
                    kx_xstar(jj,ii) = ...
                        obj.calcTotalCovariance(xStar(1:end-1,ii),...
                        XT(1:end-1,jj),xStar(end,ii),XT(end,jj));
                end
                kxstar_xstar(ii) = ...
                    obj.calcTotalCovariance(xStar(1:end-1,ii),...
                    xStar(1:end-1,ii),xStar(end,ii),xStar(end,ii));
            end
            
            % local variables to avoid taking matrix inverse twice
            Ky = covMat + obj.noiseVariance*eye(nTrainPoints);
            kInvK = kx_xstar'/Ky;
            % prediction mean
            mXstar = obj.meanFunction(xStar(1:end-1,:)',obj.meanFnProps);
            mX = obj.meanFunction(XT(1:end-1,:)',obj.meanFnProps);
            predMean = mXstar + kInvK*(y-mX);
            % posterior variance
            postVar = kxstar_xstar - diag(kInvK*kx_xstar);
                        
        end
        
        % guassian process regression
        function covMatOut = augmentCovarianceMatrix(obj,XT_old,XT_new,covMat)
            % make covariance matrix if it's empty
            if isempty(covMat)
                covMat = obj.makeTotalCovarianceMatrix(XT_old);
            end
            % local variables
            npOld = size(XT_old,2);
            npNew = size(XT_new,2);
            % calculate covariance of old points with the new one
            kxold_xnew = NaN(npOld,npNew);
            for ii = 1:npOld
                for jj = 1:npNew
                    kxold_xnew(ii,jj) = ...
                        obj.calcTotalCovariance(XT_old(1:end-1,ii),...
                        XT_new(1:end-1,jj),XT_old(end,ii),XT_new(end,jj));
                end
            end
            kxnew_xnew = obj.makeTotalCovarianceMatrix(XT_new);
            % append to covMat
            covMatOut = [covMat kxold_xnew; kxold_xnew' kxnew_xnew];
        end
        
    end
    
    
end
