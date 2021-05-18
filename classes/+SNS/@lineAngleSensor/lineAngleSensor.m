classdef lineAngleSensor < dynamicprops
    %REALISTIC container for instances of realistic sensor models
    
    properties
    % Dynamics Paramters
    mass
    volume
    diameter
    length
    Ixx
    Iyy
    Izz
    L_CB
    L_CM
    CD
    dragEnable
    tetherEnable
    initAng
    initAngVel
    r_RP
    r_PT
    tetherAngleTable
    tetherLengthPoly
    end
    
    methods
        function obj = lineAngleSensor()
            obj.mass            = SIM.parameter('Unit','kg','Description','Line Angle Sensor Mass');
            obj.volume          = SIM.parameter('Unit','m^3','Description','Line Angle Sensor Volume');
            obj.diameter        = SIM.parameter('Unit','m','Description','Line Angle Boom Diameter');
            obj.length          = SIM.parameter('Unit','m','Description','Line Angle Sensor Pendulum Length');
            obj.Ixx             = SIM.parameter('Unit','kg*m^2','Description','Line Angle Sensor Inertia about the X Axis');
            obj.Iyy             = SIM.parameter('Unit','kg*m^2','Description','Line Angle Sensor Inertia about the Y Axis');
            obj.Izz             = SIM.parameter('Unit','kg*m^2','Description','Line Angle Sensor Inertia about the Z Axis');
            obj.L_CM            = SIM.parameter('Unit','m','Description','Linear Distance to the Center of Mass from pivot');
            obj.L_CB            = SIM.parameter('Unit','m','Description','Linear Distance to the Center of Buoyancy from pivot');
            obj.CD              = SIM.parameter('Unit','','Description','Coefficient of Drag');
            obj.dragEnable      = SIM.parameter('Value',1,'Description','Enable Line Angle Sensor Drag');
            obj.tetherEnable    = SIM.parameter('Value',1,'Description','Enable Tether Loading');
            obj.initAng         = SIM.parameter('Unit','rad','Description','Initial Angles');
            obj.initAngVel      = SIM.parameter('Value',[0 0],'Unit','rad/s','Description','Initial Angular Velocities');
            obj.r_RP            = SIM.parameter('Unit','m','Description','Position Vector from pivot roller to center of rotation');
            obj.r_PT            = SIM.parameter('Unit','m','Description','Position Vector from tether pass through at the end effector to the pivot');
            obj.tetherAngleTable = SIM.parameter('Value',[-0.0014,1.1256,.4256],'Description','Coefficients for quadratic relationship between LAS angle and tether angle');
            obj.tetherLengthPoly = SIM.parameter('Value',[1.5831 444.73],'Description','Coefficients for linear relationship between LAS and tether payout');
        end
        
        function obj = setMass(obj,val,unit)
            obj.mass.setValue(val,unit);
        end
        
        function obj = setVolume(obj,val,unit)
            obj.volume.setValue(val,unit);
        end
        
        function obj = setDiameter(obj,val,unit)
            obj.diameter.setValue(val,unit);
        end
        
        function obj = setLength(obj,val,unit)
            obj.length.setValue(val,unit);
        end
        
        function obj = setIxx(obj,val,unit)
            obj.Ixx.setValue(val,unit);
        end
        
        function obj = setIyy(obj,val,unit)
            obj.Iyy.setValue(val,unit);
        end 

        function obj = setIzz(obj,val,unit)
            obj.Izz.setValue(val,unit);
        end
        
        function obj = setL_CM(obj,val,unit)
            obj.L_CM.setValue(val,unit);
        end
        
        function obj = setL_CB(obj,val,unit)
            obj.L_CB.setValue(val,unit);
        end
        
        function obj = setCD(obj,val,unit)
            obj.CD.setValue(val,unit);
        end
        
        function obj = dragEnableOn(obj)
            obj.dragEnable.setValue(1,'');
        end
        
        function obj = dragDisable(obj)
            obj.dragEnable.setValue(0,'');
        end
        
        function obj = tetherLoadEnable(obj)
            obj.tetherEnable.setValue(1,'')
        end
        
        function obj = tetherLoadDisable(obj)
            obj.tetherEnable.setValue(0,'')
        end
        
        function obj = setInitAng(obj,val,unit)
            obj.initAng.setValue(val,unit);
        end
        
        function obj = setInitAngVel(obj,val,unit)
            obj.initAngVel.setValue(val,unit);
        end
        
        function obj = setR_RP(obj,val,unit)
            obj.r_RP.setValue(val,unit);
        end
        
        function obj = setR_PT(obj,val,unit)
            obj.r_PT.setValue(val,unit);
        end
    end
end

