function tsc = parseLogsout(varargin)
%PARSELOGSOUT function to compile struct named tsc in base workspace.
%"tsc" = "timeseries collection", is a collection of individual timeseries
%in a structure.

if ~isempty(varargin)
    variableName = varargin{1};
else
    variableName = 'logsout';
end

try
    logsout = evalin('base',variableName);
catch
    error('Unable to load logsout from base workspace')
end

% get names of signals
names = logsout.getElementNames;
% get rid of unnamed signals (empty strings)
names = names(cellfun(@(x) ~isempty(x),names));
% add each signal to the struct
for ii = 1:length(names)
    ts = logsout.getElement(names{ii});
    tsc.(names{ii}) = ts.Values;
end
% send the variable back to the base workspace
assignin('base','tsc',tsc);
end