classdef setPoint
    %SETPOINT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Value
        Unit
    end
    
    methods
        function obj = setPoint(units)
            %SETPOINT Construct an instance of this class
            %   Detailed explanation goes here
            obj.Unit = units;
        end
        
        % Function to scale the object
        function scale(obj,factor)
            
            if ~isempty(obj.Value) && ~isempty(obj.Unit)
                scaleUnitList = {'m','s','kg','rad','deg','N','Pa'}; % units that impact how to scale things
                scaleFactorList  = {...
                    'factor',...
                    'sqrt(factor)',...
                    '(factor^3)',...
                    '1',...
                    '1',...
                    'factor^3',...
                    'factor'};
                units = obj.Unit;
                for ii = 1:length(scaleUnitList)
                    units = strrep(units,scaleUnitList{ii},scaleFactorList{ii});
                end
                if isa(obj.Value,'timeseries')
                    obj.Value.Data = obj.Value.Data.*eval(units);
                else
                    obj.Value = obj.Value.*eval(units);
                end
            end
        end
        
        
    end
end

