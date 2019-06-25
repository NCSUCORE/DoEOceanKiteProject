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
            obj.diameter             = OCT.param('Unit','m');
            obj.axisUnitVec          = OCT.param('Description','Vector defining axis of rotation in body frame, should be close to [1 0 0]');
            obj.attachPtVec          = OCT.param('Unit','m','Description','Vector from CoM to turbine center, in body frame');
            obj.powerCoeff           = OCT.param;
            obj.dragCoeff            = OCT.param;
        end
        function obj = scale(obj,factor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(factor);
            end
        end
    end
end

