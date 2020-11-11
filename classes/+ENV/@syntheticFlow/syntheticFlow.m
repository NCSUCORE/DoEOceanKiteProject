classdef syntheticFlow
    %SYNTHETICFLOW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        spatialCovFn
        temporalCovFn
        meanFn
        spatialCovAmp
        spatialLengthScale
        temporalLengthScale
        noiseVariance
        rngSeed
        zGridPoints
        density
        stdDevSynData
        timeStepSynData
        tFinData
        meanFnProps
    end
    properties (SetAccess = private)
        gravAccel
    end
    %% constructor
    methods
        function obj = syntheticFlow
            obj.gravAccel = SIM.parameter('Value',9.81,'Unit','m/s^2','NoScale',true);
            obj.spatialCovFn        = 'squaredExponential';
            obj.temporalCovFn       = 'squaredExponential';
            obj.meanFn              = 'constantMean';
            obj.spatialCovAmp       = SIM.parameter('Unit','m^2');
            obj.spatialLengthScale  = SIM.parameter('Unit','m');
            obj.temporalLengthScale = SIM.parameter('Unit','s');
            obj.noiseVariance       = SIM.parameter('Unit','');
            obj.rngSeed             = SIM.parameter('Unit','');
            obj.density             = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.zGridPoints         = SIM.parameter('Value',0:10:200,'Unit','m','NoScale',false);
            obj.stdDevSynData       = SIM.parameter('Value',0.5,'Unit','m/s','NoScale',false);
            obj.timeStepSynData     = SIM.parameter('Value',1*60,'Unit','s','NoScale',false);
            obj.tFinData            = SIM.parameter('Value',500*60,'Unit','s','NoScale',false);
            obj.meanFnProps         = SIM.parameter('Unit','','Value',1.5);
        end
    end
    %% other methods
    methods
        function [synFlow,synAlt] = generateData(obj)
            gp = GP.GaussianProcess(obj.spatialCovFn,...
                obj.temporalCovFn,obj.meanFn);
            gp.spatialCovAmp       = obj.spatialCovAmp.Value;
            gp.spatialLengthScale  = obj.spatialLengthScale.Value;
            gp.temporalCovAmp      = 1;
            gp.temporalLengthScale = obj.temporalLengthScale.Value/60;
            gp.noiseVariance       = obj.noiseVariance.Value;
            gp.meanFnProps         = obj.meanFnProps.Value;
            
            rng(obj.rngSeed.Value);
            [synFlow,synAlt] = gp.generateSyntheticFlowData(...
                obj.zGridPoints.Value,obj.tFinData.Value/60,obj.stdDevSynData.Value,...
                'timeStep',obj.timeStepSynData.Value/60);
            
        end
        
        function obj = addFlow(obj,FlowNames,FlowTypes,varargin)
            p = inputParser;
            addRequired(p,'FlowNames',@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addRequired(p,'FlowTypes',@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'FlowDensities',[],@(x) all(isnumeric(x)))
            addOptional(p,'MnthIdx',1,@(x) mod(x,1)==0);
            addOptional(p,'XYZTConst',false,@(x) islogical(x));
            addOptional(p,'constSpd',0.3,@(x) isnumeric(x));
            parse(p,FlowNames,FlowTypes,varargin{:})
            % Create properties of env according to the specified classes
            for ii = 1:numel(p.Results.FlowNames)
                obj.addprop(p.Results.FlowNames{ii});
                if strcmp(p.Results.FlowTypes{ii},'Manta')
                    obj.(p.Results.FlowNames{ii}) = ENV.(p.Results.FlowTypes{ii})(p.Results.MnthIdx);
                else
                    obj.(p.Results.FlowNames{ii}) = ENV.(p.Results.FlowTypes{ii});
                end
                if ~isempty(p.Results.FlowDensities)
                    obj.(p.Results.FlowNames{ii}).density.setValue(p.Results.FlowDensities(ii),'kg/m^3');
                end
            end
        end
    end
end

