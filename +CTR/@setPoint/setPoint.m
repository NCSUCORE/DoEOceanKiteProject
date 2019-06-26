classdef setPoint
    %SETPOINT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Value
    end
    
    methods
        function obj = setPoint
            %SETPOINT Construct an instance of this class
            %   Detailed explanation goes here
            obj.Value = timeseries;
        end
        
        % Function to scale the object
        function obj = scale(obj,factor)
            obj.Value.Time = obj.Value.Time*sqrt(factor);
            switch obj.Value.DataInfo.Units
                case 'm'
                    obj.Value.Data = obj.Value.Data*factor;
                case {'deg','rad'}
                    % Do nothing, just here to avoid hitting the otherwise
                    % statement in this case
                otherwise
                    error('I havent coded the scaling for that yet.  See CTR.setPoint')
            end
        end
    end
end

