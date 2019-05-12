classdef geomParamsClass < handle
    properties
        chord
        x_cm
        x_ac
        AR
        span
        vol
        F_buoy
        buoy_factor
        mass
        center_of_buoy
        aero_center
        MI
        m_added
        Izz_added
    end
    methods
        % Constructor method to define parameters that are independent of
        % the environment
        function obj = geomParamsClass
            obj.chord = simulinkProperty(5,'Unit','m','Description','lifting body chord');
            obj.x_cm  = simulinkProperty(0.5*obj.chord.Value,'Unit','m','Description','lifting body center of gravity');
            obj.x_ac  = simulinkProperty(0.8*obj.chord.Value,'Unit','m','Description','lifting body aerodynamic center');
            obj.AR    = simulinkProperty(8,'Description','lifting body Aspect Ratio');
            obj.span  = simulinkProperty(obj.AR.Value*obj.chord.Value,'Unit','m','Description','lifting body span');
            obj.vol   = simulinkProperty(1.117e11*(1e-9),'Unit','m^3','Description','lifting body volume');
            obj.buoy_factor    = simulinkProperty(1.25,'Description','lifting body bouyancy factor');
            obj.center_of_buoy = simulinkProperty([0;0;0.0],'Unit','m','Description','lifting body center of bouyancy');
            obj.aero_center    = simulinkProperty([obj.x_ac.Value-obj.x_cm.Value;0;0],'Unit','m','Description','lifting body aerodynamic center with respect to center of mass');
            obj.MI = simulinkProperty(diag([1.433*1e13*(1e-6),1.432*1e11*(1e-6),1.530*1e13*(1e-6)]),'Unit','1000*g*m^2','Description','lifting body moment of inertia');
        end
        
        % Method to calculate inertial properties that depend on
        % environment
        function obj = setupInertial(obj,aeroParam,envParam)
            obj.F_buoy = simulinkProperty(envParam.density.Value*obj.vol.Value*envParam.grav.Value,'Unit','N','Description','lifting body bouyancy');
            obj.mass   = simulinkProperty(obj.F_buoy.Value/(obj.buoy_factor.Value*envParam.grav.Value),'Unit','g*1000','Description','lifting body mass');
            
            span    = obj.span.Value;
            chord   = obj.chord.Value;
            density = envParam.density.Value;
            
%             geomParam
            HS_span = aeroParam.HS_span.Value;
            HS_chord = aeroParam.HS_chord.Value;
            VS_span = aeroParam.VS_span.Value;
            VS_chord = aeroParam.VS_chord.Value;

            m_added_x = pi*density*(span*(0.15*chord/2)^2 + HS_span*(0.15*HS_chord/2)^2 + VS_span*(0.15*VS_chord/2)^2);
            m_added_y = pi*density*(1.98*span*(chord/2)^2 + 1.98*HS_span*(HS_chord/2)^2 + VS_span*(VS_chord/2)^2);
            m_added_z = pi*density*(span*(chord/2)^2 + HS_span*(HS_chord/2)^2 + 1.98*VS_span*(VS_chord/2)^2);
            
            obj.m_added = simulinkProperty([m_added_x;m_added_y;m_added_z],'Unit','g*1000','Description','lifting body added mass');
            obj.Izz_added = simulinkProperty(0,'Unit','kg*1000*m^2','Description','lifting body added moment of inertia');
        end
        
    end
end