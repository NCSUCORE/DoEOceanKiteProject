function varargout = parseLogsout(varargin)
% PARSELOGSOUT compile structure tsc in base workspace from simulink output logsout.
%
%   PARSELOGSOUT parses the Simulink.SimulationData.Dataset object logsout
%   created by the default signal logging signale in simulink and assigns
%   the result to the variable tsc in the base workspace.
%
%   PARSELOGSOUT('DataSetVarName','Name') parses the
%   Simulink.SimulationData.Dataset object Name from the base workspace and
%   assigns it the structure tsc in the base workspace.
%
%   OUTNAME = PARSELOGSOUT assigns the result to the variable OUTNAME.

p = inputParser;
addParameter(p,'DataSetVarName','logsout',@ischar);
parse(p,varargin{:});

try
    logsout = evalin('base',p.Results.DataSetVarName);
catch
    error('Unable to load %s from base workspace.',p.Results.DataSetVarName)
end

% get names of signals
names = logsout.getElementNames;
% get rid of unnamed signals (empty strings)
names = names(cellfun(@(x) ~isempty(x),names));
% add each signal to the struct
for ii = 1:length(names)
    ts = logsout.getElement(names{ii});
    if isa(ts,'Simulink.SimulationData.Signal')
        tsc.(cleanString(names{ii})) = ts.Values;
    else
       warning('Duplicate signal names %s, skipping', names{ii})
       break
    end
    
end

if nargout == 0
    % Assign tsc in base workspace
    assignin('base','tsc',tsc);
else
    % Return tsc as the output argument
    varargout{1} = tsc;
end
end