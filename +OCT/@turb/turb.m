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
            obj.diameter             = SIM.param('Unit','m');
            obj.axisUnitVec          = SIM.param('Description','Vector defining axis of rotation in body frame, should be close to [1 0 0]');
            obj.attachPtVec          = SIM.param('Unit','m','Description','Vector from CoM to turbine center, in body frame');
            obj.powerCoeff           = SIM.param;
            obj.dragCoeff            = SIM.param;
        end
        function obj = scale(obj,factor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(factor);
            end
        end
    end
end

