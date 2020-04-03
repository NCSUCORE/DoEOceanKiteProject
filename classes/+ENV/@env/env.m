% ENV.env is a container class meant to contain instances of "flow" that
% represent different operating conditions (constant flow, variable flow,
% etc).
classdef env < dynamicprops
    properties (SetAccess = private)
        gravAccel
    end
    methods
        
        function obj = env
            obj.gravAccel = SIM.parameter('Value',9.81,'Unit','m/s^2','NoScale',true);
        end
        
        function obj = addFlow(obj,FlowNames,FlowTypes,varargin)
            p = inputParser;
            addRequired(p,'FlowNames',@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addRequired(p,'FlowTypes',@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'FlowDensities',[],@(x) all(isnumeric(x)))
            parse(p,FlowNames,FlowTypes,varargin{:})
            % Create properties of env according to the specified classes
            for ii = 1:numel(p.Results.FlowNames)
                obj.addprop(p.Results.FlowNames{ii});
                obj.(p.Results.FlowNames{ii}) = ENV.(p.Results.FlowTypes{ii});
                if ~isempty(p.Results.FlowDensities)
                    obj.(p.Results.FlowNames{ii}).density.setValue(p.Results.FlowDensities(ii),'kg/m^3');
                end
            end
        end
        
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                try
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
                catch
                    x = 1;
                end
            end
            
        end
    end
end
