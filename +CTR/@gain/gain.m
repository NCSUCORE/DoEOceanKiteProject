classdef gain < Simulink.Parameter
    properties
        IgnoreScaling@logical;
    end
    methods
        % Constructor
        function obj = gain(varargin)
            p = inputParser;
            addParameter(p,'Value',[],@(x) isnumeric(x)||islogical(x))
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
        % Function to scale down the parameter
        function scale(obj,factor)
            obj.Value = obj.Value;
            if ~obj.IgnoreScaling && ~isempty(obj.Value) && ~isempty(obj.Unit)
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
                obj.Value = obj.Value.*eval(units);
            end
        end
    end
end % classdef

