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
            obj.diameter             = SIM.parameter('Unit','m');
            obj.axisUnitVec          = SIM.parameter('Description','Vector defining axis of rotation in body frame, should be close to [1 0 0]');
            obj.attachPtVec          = SIM.parameter('Unit','m','Description','Vector from CoM to turbine center, in body frame');
            obj.powerCoeff           = SIM.parameter;
            obj.dragCoeff            = SIM.parameter;
        end
        function setDiameter(obj,val,units)
            obj.diameter.setValue(val,units)
        end

        function setAxisUnitVec(obj,val,units)
            obj.axisUnitVec.setValue(val,units)
        end

        function setAttachPtVec(obj,val,units)
            obj.attachPtVec.setValue(val,units)
        end

        function setPowerCoeff(obj,val,units)
            obj.powerCoeff.setValue(val,units)
        end

        function setDragCoeff(obj,val,units)
            obj.dragCoeff.setValue(val,units)
        end
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end

