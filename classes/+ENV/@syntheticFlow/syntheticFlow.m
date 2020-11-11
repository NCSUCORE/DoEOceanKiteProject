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
        zGridPoints
        density
    end
    %% constructor
    methods
        function obj = syntheticFlow
            obj.spatialCovFn        = 'squaredExponential';
            obj.temporalCovFn       = 'squaredExponential';
            obj.meanFn              = 'windPowerLaw';
            obj.spatialCovAmp       = SIM.parameter('Unit','m^2');
            obj.spatialLengthScale  = SIM.parameter('Unit','m');
            obj.temporalLengthScale = SIM.parameter('Unit','s');
            obj.noiseVariance       = SIM.parameter('Unit','');
            obj.density             = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.zGridPoints         = SIM.parameter('Value',0:10:200,'Unit','m','NoScale',false);

        end
    end
    %% other methods
    methods
        function [synFlow,synAlt] = generateData(obj,tFinData,stdDevSynData,timeStepSynData)
            gp = GP.GaussianProcess(obj.spatialCovFn,...
                obj.temporalCovFn,obj.meanFn);
            gp.spatialCovAmp       = obj.spatialCovAmp.Value;
            gp.spatialLengthScale  = obj.spatialLengthScale.Value;
            gp.temporalCovAmp      = 1;
            gp.temporalLengthScale = obj.temporalLengthScale.Value/60;
            gp.noiseVariance       = obj.noiseVariance.Value;
            
            [synFlow,synAlt] = gp.generateSyntheticFlowData(...
                obj.zGridPoints.Value,tFinData,stdDevSynData,...
                'timeStep',timeStepSynData);
            
        end
    end
end

