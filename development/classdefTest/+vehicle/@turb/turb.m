classdef turb < handle
    %TURB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        diameter
        directionUnitVec
        attachPtVec
        powerCoeff
        dragCoeff
        refArea
    end
    
    methods
        function obj = turb
            obj.diameter             = vehicle.param('Unit','m');
            obj.directionUnitVec     = vehicle.param;
            obj.attachPtVec          = vehicle.param('Unit','m','Description','Vector from CoM to turbine center, in body frame');
            obj.powerCoeff           = vehicle.param;
            obj.dragCoeff            = vehicle.param;
            obj.refArea              = vehicle.param('Unit','m^2');
        end
    end
end

