classdef planarWaveModel < handle
 
    
    properties (SetAccess = private)
        waveNumber
        frequency
        amplitude
        phase
       
    end
    
    methods
        function obj = planarWaveModel
            
            
            obj.waveNumber = SIM.parameter('Unit','rad/m');
            obj.frequency  = SIM.parameter('Unit','rad/s');
            obj.amplitude  = SIM.parameter('Unit','m');
            obj.phase      = SIM.parameter('Unit','rad');
         
        end
        
        function setWaveNumber(obj,val,unit)
            obj.waveNumber.setValue(val,unit);
        end
        function setFrequency(obj,val,unit)
            obj.frequency.setValue(val,unit);
        end
        function setAmplitude(obj,val,unit)
            obj.amplitude.setValue(val,unit);
        end
        function setPhase(obj,val,unit)
            obj.phase.setValue(val,unit);
        end
        
        
    end
end

