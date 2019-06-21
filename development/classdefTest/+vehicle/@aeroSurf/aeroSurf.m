classdef aeroSurf < handle
    %AEROSURF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        span
        chord
        leadEdgePos
        aspectRatio
        dihedral
        incidenceAngle
        nacaAirFoil
        airfoilCLLimits
        numPtsSpanwise
        numPtsChordwise
        sweepAngle
        spanUnitVec
        chordUnitVec
        aeroCtrVec
        refArea
        alphas
        CLs
        CDs
        GainCL
        GainCD
    end
    
    methods
        function obj = aeroSurf
            obj.span            = vehicle.param('Unit','m');
            obj.chord           = vehicle.param('Unit','m');
            obj.sweepAngle      = vehicle.param('Value',0,'Unit','deg');
            obj.spanUnitVec     = vehicle.param;
            obj.chordUnitVec    = vehicle.param;
            obj.aeroCtrVec      = vehicle.param('Unit','m');
            obj.refArea         = vehicle.param('Unit','m^2');
            obj.alphas          = vehicle.param('Unit','deg');
            obj.CLs             = vehicle.param;
            obj.CDs             = vehicle.param;
            obj.GainCL          = vehicle.param('Unit','1/deg');
            obj.GainCD          = vehicle.param('Unit','1/deg');
        end
    end
end

