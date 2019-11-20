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
        % frequencyDomainEqParams % componentts of mStar_jk in the paper
        midFreqs
        uStarLUT
        uThLUT
        vStarLUT
        vThLUT
        wStarLUT
        wThLUT
    end
    
    methods
        function obj = FAUTurb(varargin)
            p = inputParser;
            addParameter(p,'File','',@ischar)
            parse(p,varargin{:})
            
            obj.intensity= SIM.parameter('Unit','');
            obj.minFreqHz= SIM.parameter('Unit','Hz');
            obj.maxFreqHz= SIM.parameter('Unit','Hz');
            obj.numMidFreqs      = SIM.parameter('Unit','');
            obj.lateralStDevRatio= SIM.parameter('Unit','');
            obj.verticalStDevRatio       = SIM.parameter('Unit','');
            obj.spatialCorrFactor= SIM.parameter('Unit','');
            obj.midFreqs = SIM.parameter('Unit','Hz');
            obj.uStarLUT = SIM.parameter('Unit','m/s');
            obj.uThLUT   = SIM.parameter('Unit','rad');
            obj.vStarLUT = SIM.parameter('Unit','m/s');
            obj.vThLUT   = SIM.parameter('Unit','rad');
            obj.wStarLUT = SIM.parameter('Unit','m/s');
            obj.wThLUT   = SIM.parameter('Unit','rad');
            %     obj.frequencyDomainEqParams  = SIM.parameter('Unit','');
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
        function setFreqDomainParams(obj,val)
            obj.setMidFreqs(val.midFreqs.Value,'Hz');
            
            obj.setUStarLUT(val.uStarLUT.Value,'m/s');
            
            obj.setUThLUT(val.uThLUT.Value,'rad');
            
            obj.setVStarLUT(val.vStarLUT.Value,'m/s');
            
            obj.setVThLUT(val.vThLUT.Value,'rad');
            
            obj.setWStarLUT(val.wStarLUT.Value,'m/s');
            
            obj.setWThLUT(val.wThLUT.Value,'rad');
            
        end
        function setMidFreqs(obj,val,unit)
            obj.midFreqs.setValue(val,unit);
        end
        function setUStarLUT(obj,val,unit)
            obj.uStarLUT.setValue(val,unit);
        end
        function setUThLUT(obj,val,unit)
            obj.uThLUT.setValue(val,unit);
        end
        function setVStarLUT(obj,val,unit)
            obj.vStarLUT.setValue(val,unit);
        end
        function setVThLUT(obj,val,unit)
            obj.vThLUT.setValue(val,unit);
        end
        function setWStarLUT(obj,val,unit)
            obj.wStarLUT.setValue(val,unit);
        end
        function setWThLUT(obj,val,unit)
            obj.wThLUT.setValue(val,unit);
        end
        
        process(obj,lowFreqFlowObj,varargin)
        
    end
end

