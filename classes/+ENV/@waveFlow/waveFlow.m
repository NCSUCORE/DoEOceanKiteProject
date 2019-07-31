classdef waveFlow < handle
    %WAVEFLOW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        density
        wavePeriod
        waveAmplitude
        waveHeading
        oceanDepth
        pltfrmAppFlwMag
        flowVelocityVec
    end
    
    methods
        function obj = waveFlow
            %WAVEFLOW Construct an instance of this class
            %   Detailed explanation goes here
            obj.density         = SIM.parameter('Unit','kg/m^3','Description','Density of the fluid in the flow');
            obj.wavePeriod      = SIM.parameter('Unit','s','Description','Interval between wave peaks/troughs and circulation period.');
            obj.waveAmplitude   = SIM.parameter('Unit','m','Description','Wave height above/below oceanDepth');
            obj.waveHeading     = SIM.parameter('Unit','deg','Description','Direction of wave travel, 0 deg = +x dir, 90 deg = +y dir');
            obj.oceanDepth      = SIM.parameter('Unit','m','Description','Depth of the ocean');
            obj.pltfrmAppFlwMag = SIM.parameter('Unit','m/s','Description','Apparent flow velocity magnitude applied to platform');
            obj.flowVelocityVec = SIM.parameter('Unit','m/s','Description','Flow velocity vector applied to anchor tethers');
        end
        
        function val = setDensity(obj,val,unit)
            obj.density.setValue(val,unit);
        end
        function val = setWavePeriod(obj,val,unit)
            obj.wavePeriod.setValue(val,unit);
        end
        function val = setWaveAmplitude(obj,val,unit)
            obj.waveAmplitude.setValue(val,unit);
        end
        function val = setWaveHeading(obj,val,unit)
            obj.waveHeading.setValue(val,unit);
        end
        function val = setOceanDepth(obj,val,unit)
            obj.oceanDepth.setValue(val,unit);
        end
        function val = setPltfrmAppFlwMag(obj,val,unit)
            obj.pltfrmAppFlwMag.setValue(val,unit);
        end
        function val = setFlowVelocityVec(obj,val,unit)
            obj.flowVelocityVec.setValue(val,unit);
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

