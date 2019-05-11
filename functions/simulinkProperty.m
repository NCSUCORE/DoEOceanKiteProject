function param = simulinkProperty(value,varargin)
% Function to create class properties of the type Simulink.Parameter

% Parse varargin
p = inputParser;
addRequired(p,'Value'      ,@isnumeric);
addOptional(p,'Description','',@ischar)
addOptional(p,'Unit'       ,'',@ischar)
addOptional(p,'Min'        ,[],@isnumeric)
addOptional(p,'Max'        ,[],@isnumeric)
parse(p,value,varargin{:})
% Create simulink parameter object with specified values
param = Simulink.Parameter(value);
param.Value       = p.Results.Value;
param.Description = p.Results.Description;
param.Min         = p.Results.Min;
param.Max         = p.Results.Max;
param.Unit        = p.Results.Unit;
end