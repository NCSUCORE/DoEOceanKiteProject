classdef FullCycle < handle
    %   MantaFullCycle: Class definition for the Manta Ray full-cycle controller 
    
    properties (SetAccess = private)
        shiftLaps 
        preCCAlt
        Ts        
    end
    
    methods
        function obj = FullCycle
            % State machine 
           obj.shiftLaps = SIM.parameter('Value',5,'Description','Number of laps to shift Azimuth back to center','Unit','');
           obj.preCCAlt  = CTR.sat('upperLim',15,'lowerLim',20,'Unit','m');
           obj.Ts        = SIM.parameter('Value',0.01,'Unit','s','Description','Time step for discrete time implementation');
        end
       
        
        %%  Scaling
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)

            props = getPropsByClass(obj,'CTR.sat');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
            props = getPropsByClass(obj,'SIM.parameter');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
            props = getPropsByClass(obj,'CTR.FPID');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
            props = getPropsByClass(obj,'CTR.PID');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end % end scale
        
        val = getPropsByClass(obj,className)
        
        
    end
end

