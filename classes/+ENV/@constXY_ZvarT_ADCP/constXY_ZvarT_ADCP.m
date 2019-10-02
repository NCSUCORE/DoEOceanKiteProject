classdef constXY_ZvarT_ADCP < dynamicprops
    %DESCRIPTION HERE
    
    properties (SetAccess = private)
        density
        gravAccel
        startADCPTime
        endADCPTime
        depthArray
    end
    
    properties (Dependent)
        flowTSeries
    end
    
    methods
        
        %% constructor
        function obj = constXY_ZvarT_ADCP
            obj.gravAccel                   = SIM.parameter('Unit','m/s^2');
            obj.density                     = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.flowTSeries                 = SIM.parameter('Unit','' );
            obj.startADCPTime               = SIM.parameter('Unit','s');
            obj.endADCPTime                 = SIM.parameter('Unit','s');
            % Set depth array in constructor
            obj.depthArray                  = SIM.parameter('Value',6.31:1:4*61+6.31,'Unit','m');
        end
        
        %% Setters (Independent properties)
        function setDensity(obj,val,unit)
            obj.density.setValue(val,unit);
        end
        function setGravAccel(obj,val,unit)
            obj.gravAccel.setValue(val,unit);
        end

        function setStartADCPTime(obj,val,unit)
            obj.startADCPTime.setValue(val,unit);
        end
        function setEndADCPTime(obj,val,unit)
            obj.endADCPTime.setValue(val,unit);
        end
        
        % Getters (Dependent Properties)
        function val = get.flowTSeries(obj)

        end
        function val = get.depthArray(obj)
        
        end
        
        %% other methods
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = findAttrValue(obj,'SetAccess','public');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end