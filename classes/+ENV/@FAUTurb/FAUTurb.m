classdef FAUTurb < handle
    %FAUTURB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        intensity
        minFreqHz
        maxFreqHz
        numMidFreqs
        lateralStDevRatio  % P in the paper
        verticalStDevRatio % Q in the paper
        spatialCorrFactor  % C in the paper, coherence decay constant
        velWieghtingMatrix % H or Hm in the paper
    end
    
    methods
        function obj = FAUTurb(varargin)
            p = inputParser;
            addParameter(p,'File','',@ischar)
            parse(p,varargin{:})
            
            obj.intensity           = SIM.parameter('Unit','');
            obj.minFreqHz           = SIM.parameter('Unit','Hz');
            obj.maxFreqHz           = SIM.parameter('Unit','Hz');
            obj.numMidFreqs         = SIM.parameter('Unit','');
            obj.lateralStDevRatio   = SIM.parameter('Unit','');
            obj.verticalStDevRatio  = SIM.parameter('Unit','');
            obj.spatialCorrFactor   = SIM.parameter('Unit','');
            obj.velWieghtingMatrix  = SIM.parameter('Unit','');
        end
        
        function setIntensity(obj,val,unit)
            obj.intensity.setValue(val,unit);
        end
        function setMinFreqHz(obj,val,unit)
            obj.minFreqHz.setValue(val,unit);
        end
        function setMaxFreqHz(obj,val,unit)
            obj.maxFreqHz.setValue(val,unit);
        end
        function setNumMidFreqs(obj,val,unit)
            obj.numMidFreqs.setValue(val,unit);
        end
        function setLateralStDevRatio(obj,val,unit)
            obj.lateralStDevRatio.setValue(val,unit);
        end
        function setVerticalStDevRatio(obj,val,unit)
            obj.verticalStDevRatio.setValue(val,unit);
        end
        function setSpatialCorrFactor(obj,val,unit)
            obj.spatialCorrFactor.setValue(val,unit);
        end
        function setVelWieghtingMatrix(obj,val,unit)
            obj.velWieghtingMatrix.setValue(val,unit);
        end
        
        process(obj,lowFreqFlowObj)

    end
end

