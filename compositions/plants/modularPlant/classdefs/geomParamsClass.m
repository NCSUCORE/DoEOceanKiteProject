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
            obj.MI = simulinkProperty(diag([1.433*1e13*(1e-6),1.432*1e11*(1e-6),1.530*1e13*(1e-6)]),'Unit','kg*m^2','Description','lifting body moment of inertia');
        end
        
%         function val = aeroStruct(obj)
%             
%             obj.aeroStruct(1).refArea        = 1;
%             obj.aeroStruct(1).aeroCentPosVec = [0.1 -1 0];
%             obj.aeroStruct(1).spanUnitVec    = [0 1 0];
%             obj.aeroStruct(1).chordUnitVec   = [1 0 0];
%             obj.aeroStruct(1).CL = partitionedAero(1).CLVals;
%             obj.aeroStruct(1).CD = partitionedAero(1).CDVals;
%             obj.aeroStruct(1).alpha = partitionedAero(1).alpha;
%             obj.aeroStruct(1).GainCL = partitionedAero(1).GainCL;
%             obj.aeroStruct(1).GainCD = partitionedAero(1).GainCD;
%             
%             obj.aeroStruct(2).refArea        = 1;
%             obj.aeroStruct(2).aeroCentPosVec = [0.1 1 0];
%             obj.aeroStruct(2).spanUnitVec    = [0 1 0];
%             obj.aeroStruct(2).chordUnitVec   = [1 0 0];
%             obj.aeroStruct(2).CL = partitionedAero(2).CLVals;
%             obj.aeroStruct(2).CD = partitionedAero(2).CDVals;
%             obj.aeroStruct(2).alpha = partitionedAero(2).alpha;
%             obj.aeroStruct(2).GainCL = partitionedAero(2).GainCL;
%             obj.aeroStruct(2).GainCD = partitionedAero(2).GainCD;
%             
%             obj.aeroStruct(3).refArea        = 1;
%             obj.aeroStruct(3).aeroCentPosVec = [4 0 0];
%             obj.aeroStruct(3).spanUnitVec    = [0 1 0];
%             obj.aeroStruct(3).chordUnitVec   = [1 0 0];
%             obj.aeroStruct(3).CL = partitionedAero(3).CLVals;
%             obj.aeroStruct(3).CD = partitionedAero(3).CDVals;
%             obj.aeroStruct(3).alpha = partitionedAero(3).alpha;
%             obj.aeroStruct(3).GainCL = partitionedAero(3).GainCL;
%             obj.aeroStruct(3).GainCD = partitionedAero(3).GainCD;
%             
%             obj.aeroStruct(4).refArea        = 1;
%             obj.aeroStruct(4).aeroCentPosVec = [4 0 0.1];
%             obj.aeroStruct(4).spanUnitVec    = [0 0 1];
%             obj.aeroStruct(4).chordUnitVec   = [1 0 0];
%             obj.aeroStruct(4).CL = partitionedAero(4).CLVals;
%             obj.aeroStruct(4).CD = partitionedAero(4).CDVals;
%             obj.aeroStruct(4).alpha = partitionedAero(4).alpha;
%             obj.aeroStruct(4).GainCL = partitionedAero(4).GainCL;
%             obj.aeroStruct(4).GainCD = partitionedAero(4).GainCD;
%             
%         end
%         
        % Method to calculate inertial properties that depend on
        % environment
        function obj = setupInertial(obj,aeroParam,envParam)
            obj.F_buoy = simulinkProperty(envParam.density.Value*obj.vol.Value*envParam.grav.Value,'Unit','N','Description','lifting body bouyancy');
            obj.mass   = simulinkProperty(obj.F_buoy.Value/(obj.buoy_factor.Value*envParam.grav.Value),'Unit','kg','Description','lifting body mass');
            
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
            
            obj.m_added = simulinkProperty([m_added_x;m_added_y;m_added_z],'Unit','kg','Description','lifting body added mass');
            obj.Izz_added = simulinkProperty(0,'Unit','kg*m^2','Description','lifting body added moment of inertia');
        end
        
    end
end