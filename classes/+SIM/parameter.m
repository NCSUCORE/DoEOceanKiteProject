classdef parameter < handle
    % Parameter class
    properties (SetAccess = private)
        Value       % real scalar
        Unit        % unit scalar
        Description % string scalar
        NoScale    % bool
        Min
        Max
    end % end properties
    
    methods
        %% Constructor
        function obj = parameter(varargin)
            p = inputParser;
            addParameter(p,'Value',[],@(x) isnumeric(x) || islogical(x))
            addParameter(p,'Min',[],@isnumeric)
            addParameter(p,'Max',[],@isnumeric)
            addParameter(p,'Unit','',@ischar)
            addParameter(p,'Description','',@ischar)
            addParameter(p,'NoScale',false,@islogical)
            parse(p,varargin{:})
            for ii = 1:length(p.Parameters)
                obj.(p.Parameters{ii}) = p.Results.(p.Parameters{ii});
            end            
        end       
        
        %% Methods
        function scale(obj,factor)
            obj.Value = obj.Value;
            if ~obj.NoScale && ~isempty(obj.Value) && ~isempty(obj.Unit)
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
                obj.Value = obj.Value*eval(units);
            end
        end % end scale
        function setValue(hobj,val,unit)
            if nargin < 2
                warning(['No unit provided for' hobj.Description '. Using default which is ' hobj.Unit]);
            end
            try
                if ~strcmp(hobj.Unit,unit)
                    ME = MException('param:unitChange','Cannot change units after object is constructed. No change in value.');
                    throw(ME);
                end
            catch ME
                warning(ME.message);
                rethrow(ME);
            end
            hobj.Value = val;
            hobj.Unit = unit;
        end % end set.Value
        
        %% Getters
        
        %% Setters
        
    end % end methods
    
end % end parameter