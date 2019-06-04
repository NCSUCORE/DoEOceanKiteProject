classdef tetherImpNodesParamClass < handle
    properties
        R1n_cm
        R2n_cm
        R3n_cm
        R11_g
        R21_g
        R31_g
    end
    methods
        function obj = tetherImpNodesParamClass

        end
        function obj = setupTetherEndNodes(obj,aeroParam,geomParam)
            x_cm        = geomParam.x_cm.Value;
            span        = geomParam.span.Value;
            t_max       = aeroParam.t_max.Value;
            chord       = geomParam.chord.Value;
            HS_LE       = aeroParam.HS_LE.Value;
            HS_chord    = aeroParam.HS_chord.Value;
            
            
            obj.R1n_cm = simulinkProperty([(-x_cm); -(span/2); -t_max*chord/2],'Unit','m','Description','last node locations with respect to center of mass');
            obj.R2n_cm = simulinkProperty([(HS_LE + HS_chord); 0; -t_max*chord/2],'Unit','m');
            obj.R3n_cm = simulinkProperty([(-x_cm); (span/2); -t_max*chord/2],'Unit','m');
            obj.R11_g  = simulinkProperty(1*[obj.R1n_cm.Value(1); obj.R1n_cm.Value(2); -obj.R1n_cm.Value(3)],'Unit','m');
            obj.R21_g  = simulinkProperty(1*[obj.R2n_cm.Value(1); obj.R2n_cm.Value(2); -obj.R2n_cm.Value(3)],'Unit','m');
            obj.R31_g  = simulinkProperty(1*[obj.R3n_cm.Value(1); obj.R3n_cm.Value(2); -obj.R3n_cm.Value(3)],'Unit','m');

        end
    end
end