classdef turb < handle
    %TURB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        diameter
        axisUnitVec
        attachPtVec
        powerCoeff
        dragCoeff
    end
    methods
        function obj = turb
            obj.diameter             = vehicle.param('Unit','m');
            obj.axisUnitVec          = vehicle.param('Description','Vector defining axis of rotation in body frame, should be close to [1 0 0]');
            obj.attachPtVec          = vehicle.param('Unit','m','Description','Vector from CoM to turbine center, in body frame');
            obj.powerCoeff           = vehicle.param;
            obj.dragCoeff            = vehicle.param;
        end
    end
end

