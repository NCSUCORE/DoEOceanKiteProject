classdef constT_XYZvarZ_Ramp < handle
    % Flow wherin the flow speed vector varies linearly with depty (z)
    % Flow vector is constant with respect to time, but the vx, vy, and vz
    % components increase linearly with z.
    
    properties (SetAccess = public)
        nominal100mFlowVec % Flow speed at 100m depth/altitude
        density
    end
    methods
        %% contructor
        function obj = constT_XYZvarZ_Ramp
            obj.nominal100mFlowVec      = SIM.parameter('Unit','m/s');
            obj.density                 = SIM.parameter('Unit','kg/m^3','NoScale',false);
        end
        function setNominal100mFlowVec(obj,val,unit)
            obj.nominal100mFlowVec.setValue(val,unit);
        end
        function setDensity(obj,val,unit)
            obj.density(val,unit);
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

