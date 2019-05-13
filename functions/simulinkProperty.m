function h = simulinkProperty(Value,varargin)

p = inputParser;
addRequired(p,'Value',@isnumeric)
addParameter(p,'Unit','',@ischar)
addParameter(p,'Description','',@ischar)
addParameter(p,'Min',[],@isnumeric)
addParameter(p,'Max',[],@isnumeric)
parse(p,Value,varargin{:});

h = Simulink.Parameter(Value);
fieldNames = fields(p.Results);
for ii = 1:length(fieldNames)
    h.(fieldNames{ii}) = p.Results.(fieldNames{ii});
end
end