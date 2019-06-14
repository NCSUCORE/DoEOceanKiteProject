classdef simParamClass < handle
    properties
        N = simulinkProperty(5,'Description','Number of tether nodes');
        aero_param
        geom_param
        env_param
        turbine_param
        tether_param
        tether_imp_nodes
        platform_param
        unstretched_l
%         X0
        initPosVec
        initVelVec
        initEulAng
        initAngVel
        avlSRef
        avlBRef
        avlCRef
        freeSpinEnable
        initPltAng
        initPltAngVel
        winch_time_const
    end
    
    methods
        % Constructor function
        function obj = simParamClass
            % Initialize all the sub-classes (not the right word)
            obj.aero_param    = aeroParamsClass;
            obj.geom_param    = geomParamsClass;
            obj.env_param     = envParamsClass;
            obj.turbine_param = turbineParamClass;
            obj.tether_param  = tetherParamClass;
            obj.tether_imp_nodes = tetherImpNodesParamClass;
            obj.platform_param = platformParamClass;
            
            % Calculate all the parameters with interdependence
            obj.aero_param.setupGeometry(obj.geom_param);
            obj.geom_param.setupInertial(obj.aero_param,obj.env_param);
            obj.turbine_param.setupTurbines(obj.env_param,obj.geom_param);
            obj.tether_param.setupTether(obj.env_param);
            obj.tether_imp_nodes.setupTetherEndNodes(obj.aero_param,obj.geom_param);
            
            obj.avlSRef = simulinkProperty(40.00,'Unit','m/s');
            obj.avlBRef = simulinkProperty(20.00,'Unit','m/s');
            obj.avlCRef = simulinkProperty(1.80,'Unit','m/s');
            
            obj.freeSpinEnable = simulinkProperty(0,'Unit','');
            obj.winch_time_const = simulinkProperty(1,'Unit','s');
        end
        function obj = setInitialConditions(obj,varargin)
            p = inputParser;
            addOptional(p,'Position',[0 0 0],@isnumeric);
            addOptional(p,'Velocity',[0 0 0],@isnumeric);
            addOptional(p,'EulerAngles',[0 0 0],@isnumeric);
            addOptional(p,'AngularVelocity',[0 0 0],@isnumeric);
            addOptional(p,'PlatformAngle',0,@isnumeric)
            addOptional(p,'PlatformAngularVelocity',0,@isnumeric);
            parse(p,varargin{:})
            
            x_cm = obj.geom_param.x_cm.Value;
            span = obj.geom_param.span.Value;
            t_max = obj.aero_param.t_max.Value;
            HS_LE = obj.aero_param.HS_LE.Value;
            HS_chord = obj.aero_param.HS_chord.Value;
            chord = obj.geom_param.chord.Value;
            
            % last node locations wrt CM
            R1n_cm = [(-x_cm); -(span/2); -t_max*chord/2];
            R2n_cm = [(HS_LE + HS_chord); 0; -t_max*chord/2];
            R3n_cm = [(-x_cm); (span/2); -t_max*chord/2];
            
            % first node location wrt origin
            R11_g = 1*[R1n_cm(1); R1n_cm(2); -R1n_cm(3)];
            R21_g = 1*[R2n_cm(1); R2n_cm(2); -R2n_cm(3)];
            R31_g = 1*[R3n_cm(1); R3n_cm(2); -R3n_cm(3)];
            
            ini_Rcm_o        = p.Results.Position(:);
            ini_O_Vcm_o      = p.Results.Velocity(:);
            ini_euler_ang    = p.Results.EulerAngles(:);
            ini_OwB          = p.Results.AngularVelocity(:);
            ini_platform_ang = p.Results.PlatformAngle(:);
            ini_platform_vel = p.Results.PlatformAngularVelocity(:);
            
            obj.initPosVec = simulinkProperty(ini_Rcm_o,'Unit','m');
            obj.initVelVec = simulinkProperty(ini_O_Vcm_o,'Unit','m/s');
            obj.initEulAng = simulinkProperty(ini_euler_ang,'Unit','rad');
            obj.initAngVel = simulinkProperty(ini_OwB,'Unit','rad/s');
            obj.initPltAng = simulinkProperty(ini_platform_ang,'Unit','rad');
            obj.initPltAngVel = simulinkProperty(ini_platform_vel,'Unit','rad/s');
            
            X0_partial = cat(1,ini_Rcm_o,ini_O_Vcm_o,ini_euler_ang,ini_OwB,ini_platform_ang,ini_platform_vel,obj.platform_param.gnd_station.Value);
            
            node_locations = intermediate_nodes(R11_g,R21_g,R31_g,R1n_cm,R2n_cm,R3n_cm,obj.N.Value,X0_partial);
            
            ini_R1i_o = node_locations.tether_1_nodes;
            ini_R2i_o = node_locations.tether_2_nodes;
            ini_R3i_o = node_locations.tether_3_nodes;
            
            ul1 = norm(ini_R1i_o(end-2:end,1) - ini_R1i_o(1:3,1));
            ul2 = norm(ini_R2i_o(end-2:end,1) - ini_R2i_o(1:3,1));
            ul3 = norm(ini_R3i_o(end-2:end,1) - ini_R3i_o(1:3,1));
            
            obj.unstretched_l = simulinkProperty([ul1;ul2;ul3],'Unit','m');
            
            % initial node velocities
%             ini_O_V1i_o = zeros(size(ini_R1i_o));
%             ini_O_V2i_o = zeros(size(ini_R2i_o));
%             ini_O_V3i_o = zeros(size(ini_R3i_o));
            
%             obj.X0 = simulinkProperty(cat(1,ini_Rcm_o,ini_O_Vcm_o,ini_euler_ang,ini_OwB,ini_platform_ang,ini_platform_vel,...
%                 ini_R1i_o,ini_R2i_o,ini_R3i_o,ini_O_V1i_o,ini_O_V2i_o,ini_O_V3i_o));
        end
        
        % Function to scale all parameters
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            obj.aero_param      = scaleObj(obj.aero_param,lengthScaleFactor,densityScaleFactor);
            obj.geom_param      = scaleObj(obj.geom_param,lengthScaleFactor,densityScaleFactor);
            obj.env_param       = scaleObj(obj.env_param,lengthScaleFactor,densityScaleFactor);
            obj.turbine_param   = scaleObj(obj.turbine_param,lengthScaleFactor,densityScaleFactor);
            obj.tether_param    = scaleObj(obj.tether_param,lengthScaleFactor,densityScaleFactor);
            obj.tether_imp_nodes= scaleObj(obj.tether_imp_nodes,lengthScaleFactor,densityScaleFactor);
            obj.platform_param  = scaleObj(obj.platform_param,lengthScaleFactor,densityScaleFactor);
            
            obj.avlBRef.Value = obj.avlBRef.Value*lengthScaleFactor;
            obj.avlCRef.Value = obj.avlCRef.Value*lengthScaleFactor;
            obj.avlSRef.Value = obj.avlSRef.Value*lengthScaleFactor^2;
            obj.initPosVec.Value = obj.initPosVec.Value*lengthScaleFactor;
            obj.initVelVec.Value = obj.initVelVec.Value*sqrt(lengthScaleFactor);
            obj.unstretched_l.Value = obj.unstretched_l.Value*lengthScaleFactor;
            obj.winch_time_const.Value = obj.winch_time_const.Value*sqrt(lengthScaleFactor);
        end
    end
end
