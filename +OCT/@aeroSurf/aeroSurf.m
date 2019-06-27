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
            obj.refArea         = SIM.parameter('Unit','m^2');
            obj.aeroCentPosVec  = SIM.parameter('Unit','m');
            obj.spanUnitVec     = SIM.parameter;
            obj.chordUnitVec    = SIM.parameter;
            obj.CL              = SIM.parameter;
            obj.CD              = SIM.parameter;
            obj.alpha           = SIM.parameter('Unit','deg');
            obj.GainCL          = SIM.parameter('Unit','1/deg');
            obj.GainCD          = SIM.parameter('Unit','1/deg');
            obj.MaxCtrlDeflDn   = SIM.parameter('Unit','deg');
            obj.MaxCtrlDeflUp   = SIM.parameter('Unit','deg');
        end
        
        function obj = scale(obj,factor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(factor);
            end
        end
    end
    
    
end

