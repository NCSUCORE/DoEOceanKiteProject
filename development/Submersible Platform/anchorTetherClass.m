classdef anchorTetherClass < handle
    properties
        E = simulinkProperty(3.8e9,'Unit','N/m^2','Description','Young''s Modulus of Tether');
        d = simulinkProperty(.055,'Unit','m','Description','Diameter of Tether');
        zeta = simulinkProperty(.05,'Unit','','Description','Damping Ratio of Tether');
        crossA
        unstretchedL
        k
        anchorPos
        cmDistanceBuoy
        b
    end
    methods
        function obj = anchorTetherClass
            obj.crossA                  = obj.d.Value.^2*pi/4;
        end
        function obj = setInitialConditions(obj,initialPlatform,massplatform,varargin)
            p = inputParser;
            addOptional(p,'anchorPosition',[0 0 0],@isnumeric);
            addOptional(p,'cmDistanceBuoy',[0 0 0],@isnumeric);
            parse(p,varargin{:})
            
            obj.anchorPos         = p.Results.anchorPosition(:);
            obj.cmDistanceBuoy    = p.Results.cmDistanceBuoy(:);
            
            initial = initialPlatform.Value(1:3);
            mass = massplatform.Value;
            
            obj.unstretchedL            = norm(initial+obj.cmDistanceBuoy-obj.anchorPos);
            obj.k                       = obj.E.Value*obj.crossA/obj.unstretchedL;
            obj.b                       = obj.zeta.Value*(2*sqrt(obj.k*mass));
        end
    end
end