classdef submersiblePlatformClass < handle
    properties
        buoy
        landing
        env
        actuator
        initial
    end
    methods
        function obj = setInitialConditions(obj,varargin)
            p = inputParser;
            addOptional(p,'PositionBuoy',[0 0 0],@isnumeric);
            addOptional(p,'VelocityBuoy',[0 0 0],@isnumeric);
            addOptional(p,'PositionLanding',[0 0 0],@isnumeric);
            addOptional(p,'VelocityLanding',[0 0 0],@isnumeric);
%             addOptional(p,'AngularVelocity',[0 0 0],@isnumeric);
%             addOptional(p,'Angle',[0 0 0],@isnumeric)
            parse(p,varargin{:})
            
            initialPosBuoy          = p.Results.PositionBuoy(:);
            initialVelBuoy          = p.Results.VelocityBuoy(:);
            initialPosLand          = p.Results.PositionLanding(:);
            initialVelLand          = p.Results.VelocityLanding(:);
%             initialAng              = p.Results.Angle(:);
%             initialAngVel           = p.Results.AngularVelocity(:);
            
            obj.initial = simulinkProperty(cat(1,initialPosBuoy,initialVelBuoy,initialPosLand,initialVelLand));
        end
        function obj = submersiblePlatformClass
            % Buoyant Platform
            obj.buoy.vol =              simulinkProperty(5.5,'Unit','m^3','Description','Volume of Buoyant Platform');
            obj.buoy.rho =              simulinkProperty(100,'Unit','kg/m^3','Description','Density of Buoyant Platform');
            obj.buoy.mass =             simulinkProperty(obj.buoy.vol.Value*obj.buoy.rho.Value,'Unit','kg','Description','Mass of Buoyant Platform');
            obj.buoy.charD =            simulinkProperty(1,'Unit','m','Description','Characteristic Diameter of the Platform');
            % Landing Platform
            obj.landing.vol =           simulinkProperty(3.25,'Unit','m^3','Description','Volume of Landing Platform');
            obj.landing.rho =           simulinkProperty(1100,'Unit','kg/m^3','Description','Density of Landing Platform');
            obj.landing.mass =          simulinkProperty(obj.landing.vol.Value*obj.landing.rho.Value,'Unit','kg','Description','Mass of Landing Platform');
            % Environment
            obj.env.g =                 simulinkProperty(9.81,'Unit','m/s^2','Description','Gravity');
            obj.env.rho =               simulinkProperty(1000,'Unit','kg/m^3','Description','Density of Fluid');
            obj.env.gamma =             simulinkProperty(obj.env.g.Value*obj.env.rho.Value,'Unit','N/m^3','Description','Specific Weight of Fluid');
            obj.env.waveAmp =           simulinkProperty(1.5,'Unit','m','Description','Wave Amplitude');
            obj.env.waveLength =        simulinkProperty(11,'Unit','m','Description','Wave Length');
            obj.env.waveNumber =        simulinkProperty(2*pi/obj.env.waveLength.Value,'Unit','1/m','Description','Wave Number');
            % Actuator Properties
            obj.actuator.E =            simulinkProperty(200e9,'Unit','N/m^2','Description','Young''s Modulus of Linear Actuator');
            obj.actuator.unstretchedL = simulinkProperty(18,'Unit','m','Description','Unstretched Actuator Length');
            obj.actuator.crossA =       simulinkProperty(obj.buoy.charD.Value^2*pi/4,'Unit','m^2','Description','Cross-Sectional Area of Actuator');
            obj.actuator.k =            simulinkProperty(obj.actuator.E.Value*obj.actuator.crossA.Value/obj.actuator.unstretchedL.Value,'Unit','N/m','Description','Effective Spring Constant of Actuator');
            obj.actuator.zeta =         simulinkProperty(.05,'Unit','','Description','Damping Ratio for Actuator');
            obj.actuator.b =            simulinkProperty(obj.actuator.zeta.Value*(2*sqrt(obj.actuator.k.Value*obj.landing.mass.Value)),'Unit','N*s/m','Description','Effective Damping Constant of Actuator');
        end
    end
end