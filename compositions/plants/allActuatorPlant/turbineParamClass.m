classdef turbineParamClass
    properties
        d_turbine
        A_turbine
        Cp_turb
        CD_turb
        R1turb_cm
        R2turb_cm
        rated_power
    end
    methods
        function obj = turbineParamClass
            obj.d_turbine = simulinkProperty(8.7,'Unit','m','Description','turbine diameter');
            obj.A_turbine = simulinkProperty((pi/4)*obj.d_turbine.Value^2,'Unit','m^2','Description','turbine area');
            obj.Cp_turb   = simulinkProperty(0.5,'Description','pressure coefficent turbine');
            obj.CD_turb   = simulinkProperty(0.8,'Description','drag coefficent turbine');
        end
        function obj = setupTurbines(obj,envParam,geomParam)
            rated_flow = 1.5;
            
            req_power = obj.A_turbine.Value*(0.5*envParam.density.Value*obj.Cp_turb.Value*rated_flow^3);
            chord = geomParam.chord.Value;
            x_cm = geomParam.x_cm.Value;
            span = geomParam.span.Value;
            turb_offset = geomParam.chord.Value/20;
            
            obj.R1turb_cm = simulinkProperty([(chord - x_cm);-(span/2 + turb_offset);0],'Unit','m','Description','turbine');
            obj.R2turb_cm = simulinkProperty([(chord - x_cm); (span/2 + turb_offset);0],'Unit','m','Description','turbine');
            
            obj.rated_power = simulinkProperty(2*req_power,'Unit','N*m/s','Description','turbine rated power');
        end
    end
end