classdef floor < handle
    %FLOOR class to hold parameters that model ocean floor contact modeling
    
    properties (SetAccess = private)
        bedrockZ
        oceanFloorZ
        stiffnessZPt
        stiffnessFMag
        fricCoeff
    end
    
    properties (Dependent)
        stiffnessCoefficient
    end
    
    methods
        function obj = floor
            obj.bedrockZ        = SIM.parameter('Unit','m','Description','Z position where normal force goes to inf');
            obj.oceanFloorZ     = SIM.parameter('Unit','m','Description','Z position of ocean floor');
            obj.stiffnessZPt    = SIM.parameter('Unit','m','Description','Z position where tuning normal force is evaluated');
            obj.stiffnessFMag   = SIM.parameter('Unit','N','Description','Tuning normal force');
            obj.fricCoeff       = SIM.parameter('Unit','','Description','Friction coefficient for lateral motion');
        end
        
        function setBedrockZ(obj,val,unit)
            obj.bedrockZ.setValue(val,unit);
        end
        function setOceanFloorZ(obj,val,unit)
            obj.oceanFloorZ.setValue(val,unit);
        end
        function setStiffnessZPt(obj,val,unit)
            obj.stiffnessZPt.setValue(val,unit);
        end
        function setStiffnessFMag(obj,val,unit)
            obj.stiffnessFMag.setValue(val,unit);
        end
        function setFricCoeff(obj,val,unit)
            obj.fricCoeff.setValue(val,unit);
        end
        
        function val = get.stiffnessCoefficient(obj)
            FnStar  = obj.stiffnessFMag.Value;
            zStar   = obj.stiffnessZPt.Value;
            z0      = obj.bedrockZ.Value;
            z1      = obj.oceanFloorZ.Value;
            value = FnStar*((zStar-z1)/(z0-(zStar-z1)))^-2;
            val = SIM.parameter('Value',value,'Unit','rad/m','Description','Coefficient describing how spring force changes with depth');
        end
        
        function [FSpring] = calcNormForceMag(obj,z)
            % method to calculate net vertical force
            FStar = obj.stiffnessFMag.Value;
            zStar = obj.stiffnessZPt.Value;
            z0    = obj.bedrockZ.Value;
            z1    = obj.oceanFloorZ.Value;
            k     = obj.stiffnessCoefficient.Value;
            FSpring = zeros(size(z));
            FSpring(z<z1) = k*((z(z<z1)-z1)./(z0-(z(z<z1)-z1))).^2;
            
        end
        
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = findAttrValue(obj,'SetAccess','private');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        
    end
end

