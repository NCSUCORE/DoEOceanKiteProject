classdef env < dynamicprops
    properties
        gravAccel
    end
    methods
        function obj = env
            obj.gravAccel = SIM.parameter('Value',9.81,'Unit','m/s^2','NoScale',true);
        end

        function obj = addFlow(obj,FlowNames,varargin)

            p = inputParser;
            addRequired(p,'FlowNames',@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'FlowDensities',[],@(x) all(isnumeric(x)))
            parse(p,FlowNames,varargin{:})
            % Create winches
            for ii = 1:numel(p.Results.FlowNames)
                obj.addprop(p.Results.FlowNames{ii});
                obj.(p.Results.FlowNames{ii}) = ENV.flow;
                if ~isempty(p.Results.FlowDensities)
                    obj.(p.Results.FlowNames{ii}).density.setValue(p.Results.FlowDensities(ii),'kg/m^3');
                end
            end
        end
        
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end