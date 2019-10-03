classdef constXY_ZvarT_ADCP
    %Flow profile that is constant WRT X and Y but varies with Z according
    %to ADCP data flow.  Individual components of the flow vector can be
    %enabled or zeroed using componentEnable
    properties (SetAccess = private)
        density
        gravAccel
        startADCPTime
        endADCPTime
        componentEnable
        depthArray
        flowVecTSeries
        flowDirTSeries
    end
    
    properties (Access = private)
        adcp
    end
        
    methods
        
        %% constructor
        function obj = constXY_ZvarT_ADCP
            obj.gravAccel                   = SIM.parameter('Unit','m/s^2');
            obj.density                     = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.startADCPTime               = SIM.parameter('Value',0,'Unit','s');
            obj.endADCPTime                 = SIM.parameter('Value',inf,'Unit','s');
            obj.componentEnable             = SIM.parameter('Value',logical([1 1 1]),'Unit','');
            obj.adcp = ENV.ADCP;
            obj.flowVecTSeries                 = SIM.parameter(...
                'Value',obj.adcp.flowVecTSeries.Value,...
                'Unit' ,obj.adcp.flowVecTSeries.Unit);
            obj.flowDirTSeries                 = SIM.parameter(...
                'Value',obj.adcp.flowDirTSeries.Value,...
                'Unit' ,obj.adcp.flowDirTSeries.Unit);
        end
        
        %% Setters (Independent properties)
        function setDensity(obj,val,unit)
            obj.density.setValue(val,unit);
        end
        function setGravAccel(obj,val,unit)
            obj.gravAccel.setValue(val,unit);
        end
        function obj = setStartADCPTime(obj,val,unit)
            obj.startADCPTime.setValue(val,unit);
            
            if obj.startADCPTime.Value<=obj.endADCPTime.Value
                [vecTSeries,dirTSeries] = obj.adcp.crop(obj.startADCPTime.Value,obj.endADCPTime.Value);
                obj.flowVecTSeries = SIM.parameter(...
                    'Value',vecTSeries,...
                    'Unit' ,vecTSeries.DataInfo.Units);
                obj.flowDirTSeries = SIM.parameter(...
                    'Value',dirTSeries,...
                    'Unit' ,dirTSeries.DataInfo.Units);
            else
                error('Start time must be <= end time')
            end
        end
        function obj = setEndADCPTime(obj,val,unit)
            obj.endADCPTime.setValue(val,unit);
            if obj.startADCPTime.Value<=obj.endADCPTime.Value
                [vecTSeries,dirTSeries] = obj.adcp.crop(obj.startADCPTime.Value,obj.endADCPTime.Value);
                obj.flowVecTSeries = SIM.parameter(...
                    'Value',vecTSeries,...
                    'Unit' ,vecTSeries.DataInfo.Units);
                obj.flowDirTSeries = SIM.parameter(...
                    'Value',dirTSeries,...
                    'Unit' ,dirTSeries.DataInfo.Units);
            else
                error('Start time must be <= end time')
            end
        end
        function setComponentEnable(obj,val,unit)
            obj.componentEnable.setValue(logical(val),unit);
        end
        
        % Getters (Dependent Properties)
%         function val = get.flowTSeries(obj)
%             val = obj.adcp.flowVecTSeries;
%             val = getsampleusingtime(val,obj.startADCPTime.Value,obj.endADCPTime.Value);
%             val.Time = val.Time-val.Time(1);
%             % Zero components specified by the user
%             val.Data(~obj.componentEnable.Value(:),:,:) = 0;
%         end
        
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