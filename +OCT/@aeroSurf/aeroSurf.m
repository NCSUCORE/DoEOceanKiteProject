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
            obj.refArea         = SIM.param('Unit','m^2');
            obj.aeroCentPosVec  = SIM.param('Unit','m');
            obj.spanUnitVec     = SIM.param;
            obj.chordUnitVec    = SIM.param;
            obj.CL              = SIM.param;
            obj.CD              = SIM.param;
            obj.alpha           = SIM.param('Unit','deg');
            obj.GainCL          = SIM.param('Unit','1/deg');
            obj.GainCD          = SIM.param('Unit','1/deg');
            obj.MaxCtrlDeflDn   = SIM.param('Unit','deg');
            obj.MaxCtrlDeflUp   = SIM.param('Unit','deg');
        end
        
        function obj = scale(obj,factor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(factor);
            end
        end
    end
    
    
end

