classdef param < Simulink.Parameter
    properties
        IgnoreScaling@logical;
    end
    methods
        function obj = param(varargin)
%             obj = obj@Simulink.Parameter;
            p = inputParser;
            addParameter(p,'Value',[],@isnumeric)
            addParameter(p,'Min',[],@isnumeric)
            addParameter(p,'Max',[],@isnumeric)
            addParameter(p,'Unit','',@ischar)
            addParameter(p,'Description','',@ischar)
            addParameter(p,'IgnoreScaling',false,@islogical)
            parse(p,varargin{:})
            for ii = 1:length(p.Parameters)
                obj.(p.Parameters{ii}) = p.Results.(p.Parameters{ii});
            end
            
        end
        function scale(obj,scaleFactor)
            obj.Value = scaleParam(obj,scaleFactor);
        end
    end
end % classdef

