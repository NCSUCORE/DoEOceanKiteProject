classdef env < dynamicprops
    properties
        gravAccel
    end
    methods
        function obj = env
            obj.gravAccel = OCT.param('Value',9.81,'Unit','m/s^2','IgnoreScaling',true);
        end

        function obj = addFlow(obj,FlowNames,varargin)

            p = inputParser;
            addRequired(p,'FlowNames',@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'FlowDensities',[],@(x) all(isnumeric(x)))
            parse(p,FlowNames,varargin{:})
            % Create winches
            for ii = 1:numel(p.Results.FlowNames)
                obj.addprop(p.Results.FlowNames{ii});
                obj.(p.Results.FlowNames{ii}) = OCT.flow;
                if ~isempty(p.Results.FlowDensities)
                    obj.(p.Results.FlowNames{ii}).density.Value = p.Results.FlowDensities(ii);
                end
            end
        end
        
        % Function to scale the object
        function obj = scale(obj,scaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(scaleFactor);
            end
        end
    end
end