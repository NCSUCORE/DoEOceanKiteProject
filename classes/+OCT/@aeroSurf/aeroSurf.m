classdef aeroSurf < handle
    %AEROSURF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = {?OCT.vehicle_v2})
        refArea
        aeroCentPosVec
        spanUnitVec
        chordUnitVec
        CL
        CD
        alpha
        GainCL
        GainCD
        RBdy2Surf
    end
    properties (SetAccess = public)
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
            obj.RBdy2Surf       = SIM.parameter('NoScale',true);
        end
        
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        
        function val = get.RBdy2Surf(obj)
            value = [...
                obj.chordUnitVec.Value(:)';...
                obj.spanUnitVec.Value(:)';...
                cross(obj.chordUnitVec.Value(:)',obj.spanUnitVec.Value(:)')];
            val = SIM.parameter('Value',value);
        end
    end
    
    
end

