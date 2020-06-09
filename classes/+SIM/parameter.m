classdef parameter < handle
    % Parameter class
    properties (SetAccess = private)
        Value       % real scalar
        Unit        % unit scalar
        NoScale    % bool
        Min
        Max
    end % end properties
    properties (SetAccess = public)
        Description % string scalar
    end
    
    methods
        %% Constructor
        function obj = parameter(varargin)
            p = inputParser;
            addParameter(p,'Value',[],@(x) isnumeric(x) || islogical(x) || isa(x,'timeseries'))
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
        function scale(obj,lengthScale,densityScale)
            obj.Value = obj.Value;
            if ~obj.NoScale && ~isempty(obj.Value) && ~isempty(obj.Unit)
                scaleUnitList = {'m','s','kg','rad','deg','N','Pa','W'}; % units that impact how to scale things
                lengthFactorList  = {...
                    '(lengthScale',...
                    '(sqrt(lengthScale)',...
                    '((lengthScale^3)',...
                    '(1',...
                    '(1',...
                    '((lengthScale^3)',...
                    '(lengthScale',...
                    '(lengthScale^(2.5)'};
                densityFactorList = {...
                    '*1)',...
                    '*1)',...
                    '*densityScale)',...
                    '*1)',...
                    '*1)',...
                    '*densityScale)',...
                    '*densityScale)',...
                    '*1)'};
                units = obj.Unit;
                for ii = 1:length(scaleUnitList)
                    units = strrep(units,scaleUnitList{ii},strcat(lengthFactorList{ii},densityFactorList{ii}));
                end
                if isa(obj.Value,'timeseries')
                    obj.Value.Data = obj.Value.Data*eval(units);
                    obj.Value.Time = obj.Value.Time*sqrt(lengthScale);
                else
                    obj.Value = obj.Value.*eval(units);
                end
            end
        end % end scale
        function setValue(hobj,val,unit,varargin)
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
            if isa(hobj.Value,'timeseries')
                if isa(val,'timeseries')
                    hobj.Value=val;
                elseif ~isempty(varargin) % user specified new time vector, overwrite the whole timeseries with the new one
                    hobj.Value = timeseries(val,varargin{1});
                    hObj.Value.DataInfo.Units = unit;
                else
                    hobj.Value.Data = val;
                end
            else
                hobj.Value = val;
                hobj.Unit = unit;
            end
        end % end set.Value
        
        %% Getters
        
        %% Setters
        
    end % end methods
    
end % end parameter