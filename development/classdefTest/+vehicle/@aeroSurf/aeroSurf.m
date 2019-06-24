classdef aeroSurf < handle
    %AEROSURF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        refArea
        aeroCentPosVec
        spanUnitVec
        chordUnitVec
        CL
        CD
        alpha
        GainCL
        GainCD
        MaxCtrlDeflDn
        MaxCtrlDeflUp
        
    end
    
    methods
        function obj = aeroSurf
            obj.refArea         = vehicle.param('Unit','m^2');
            obj.aeroCentPosVec  = vehicle.param('Unit','m');
            obj.spanUnitVec     = vehicle.param;
            obj.chordUnitVec    = vehicle.param;
            obj.CL              = vehicle.param;
            obj.CD              = vehicle.param;
            obj.alpha           = vehicle.param('Unit','deg');
            obj.GainCL          = vehicle.param;
            obj.GainCD          = vehicle.param;
            obj.MaxCtrlDeflDn   = vehicle.param('Unit','deg');
            obj.MaxCtrlDeflUp   = vehicle.param('Unit','deg');
        end
        
        function obj = scale(obj,scaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).Value = scaleParam(obj.(props{ii}),scaleFactor);
            end
        end
    end
    
    
end

