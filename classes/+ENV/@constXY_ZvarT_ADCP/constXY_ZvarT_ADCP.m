classdef constXY_ZvarT_ADCP < dynamicprops
    %DESCRIPTION HERE
    
    properties (SetAccess = private)
        density
        gravAccel
        startADCPTime
        endADCPTime
        depthArray
        componentEnable
    end
    
    properties (Access = private)
        adcp
    end
    
    properties (Dependent)
        flowTSeries
    end
    
    methods
        
        %% constructor
        function obj = constXY_ZvarT_ADCP
            obj.gravAccel                   = SIM.parameter('Unit','m/s^2');
            obj.density                     = SIM.parameter('Unit','kg/m^3','NoScale',false);
%             obj.flowTSeries                 = SIM.parameter('Unit','' );
            obj.startADCPTime               = SIM.parameter('Value',0,'Unit','s');
            obj.endADCPTime                 = SIM.parameter('Value',inf,'Unit','s');
            obj.componentEnable             = SIM.parameter('Value',logical([1 1 1]),'Unit','');
            obj.adcp = ENV.ADCP;
            % Set depth array in constructor
%             obj.depthArray                  = SIM.parameter('Value',6.31:1:4*61+6.31,'Unit','m');
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
        function setComponentEnable(obj,val,unit)
            obj.componentEnable.setValue(logical(val),unit);
        end
        
        % Getters (Dependent Properties)
        function val = get.flowTSeries(obj)
           
            val = obj.adcp.flowVecTSeries;
            val = getsampleusingtime(val,obj.startADCPTime.Value,obj.endADCPTime.Value);
            val.Time = val.Time-val.Time(1);
            % Zero all z velocity (vertical direction) flow
            val.Data(~obj.componentEnable.Value(:),:,:) = 0;
        end
        
        function val = get.depthArray(obj)
            val = SIM.parameter('Value',obj.adcp.depths,'Unit','m/s');
        end

        
        %% other methods
        % Function to scale the object
        % Might not be written correctly ENV.ADCP needs a scale method
        % associated with it and that needs to be called from here
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = findAttrValue(obj,'SetAccess','public');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end