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
    %   break
    end
end

if nargout == 0
    % Assign tsc in base workspace
    assignin('base','tsc',tsc);
else
    % Return tsc as the output argument
    varargout{1} = tsc;
end

if isfield(tsc,'winchPower')
    diffTime = diff(tsc.winchPower.Time); 
    timesteps = .5*([diffTime; diffTime(end)] + [diffTime(1); diffTime]); %averages left and right timestep lengths for each data point.
    energy=squeeze(tsc.winchPower.Data).*squeeze(timesteps);
    if isfield(tsc,'closestPathVariable')
        lapInds=find(abs(tsc.closestPathVariable.Data(2:end)-tsc.closestPathVariable.Data(1:end-1))>.95);
        if ~isempty(lapInds) && length(lapInds)>=2
            bounds=[lapInds(end-1) lapInds(end)];
            powAvg=sum(energy(bounds(1):bounds(2)))/(tsc.winchPower.Time(bounds(2))-tsc.winchPower.Time(bounds(1)));
            fprintf('Average power for the last lap = %.5g kW.\n',powAvg/1000);
        else
            bounds=[1 length(tsc.winchPower.Time)];
            powAvg=sum(energy(bounds(1):bounds(2)))/(tsc.winchPower.Time(bounds(2))-tsc.winchPower.Time(bounds(1)));
            fprintf('Average power for the simulation = %.5g kW.\n',powAvg/1000);
        end
    else
        bounds=[floor(length(tsc.winchPower.Time)/2) length(tsc.winchPower.Time)];
        powAvg=sum(energy(bounds(1):bounds(2)))/(tsc.winchPower.Time(bounds(2))-tsc.winchPower.Time(bounds(1)));
        fprintf('Average power for the last half of the simulation = %.5g kW.\n',powAvg/1000);
    end
end
end