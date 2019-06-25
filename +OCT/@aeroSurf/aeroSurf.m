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
            obj.refArea         = OCT.param('Unit','m^2');
            obj.aeroCentPosVec  = OCT.param('Unit','m');
            obj.spanUnitVec     = OCT.param;
            obj.chordUnitVec    = OCT.param;
            obj.CL              = OCT.param;
            obj.CD              = OCT.param;
            obj.alpha           = OCT.param('Unit','deg');
            obj.GainCL          = OCT.param;
            obj.GainCD          = OCT.param;
            obj.MaxCtrlDeflDn   = OCT.param('Unit','deg');
            obj.MaxCtrlDeflUp   = OCT.param('Unit','deg');
        end
        
        function obj = scale(obj,factor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(factor);
            end
        end
    end
    
    
end

