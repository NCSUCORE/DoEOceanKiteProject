classdef waveFlow < handle
    %WAVEFLOW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        density
        wavePeriod
        waveAmplitude
        oceanDepth
        pltfrmAppFlwMag
        velVec
        
    end
    
    methods
        function obj = waveFlow
            %WAVEFLOW Construct an instance of this class
            %   Detailed explanation goes here
            obj.density         = SIM.parameter('Unit','kg/m^3','Description','Density of the fluid in the flow');
            obj.wavePeriod      = SIM.parameter('Unit','s','Description','Interval between wave peaks/troughs and circulation period.');
            obj.waveAmplitude   = SIM.parameter('Unit','m','Description','Wave height above/below oceanDepth');
            obj.oceanDepth      = SIM.parameter('Unit','m','Description','Depth of the ocean');
            obj.pltfrmAppFlwMag = SIM.parameter('Unit','m/s','Description','Apparent flow velocity magnitude applied to platform');
            obj.velVec          = SIM.parameter('Unit','','Description','Flow velocity vector applied to anchor tethers');
        end
        
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end

