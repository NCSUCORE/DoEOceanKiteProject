function varargout = powersummary(obj,varargin)
%% Print out summary of power to the user, if applicable

% Print out power summary
if isprop(obj,'winchPower')
    diffTime = diff(obj.winchPower.Time);
    timesteps = .5*([diffTime; diffTime(end)] + [diffTime(1); diffTime]); %averages left and right timestep lengths for each data point.
    energy=squeeze(obj.winchPower.Data).*squeeze(timesteps);
    if ~isempty(varargin)
        timeBounds=varargin{1};
        bounds = [obj.winchPower.closestIndex(timeBounds(1)) obj.winchPower.closestIndex(timeBounds(2))];
        powAvg = sum(energy(bounds(1):bounds(2)))/(obj.winchPower.Time(bounds(2))-obj.winchPower.Time(bounds(1)));
        fprintf('Average power for the specified range = %.5g kW.\n',powAvg/1000);
    elseif isprop(obj,'closestPathVariable')
        lapInds = find(abs(obj.closestPathVariable.Data(2:end)-obj.closestPathVariable.Data(1:end-1))>.95);
        lapTimes = obj.positionVec.Time(lapInds);
        lapInds(lapTimes(2:end)-lapTimes(1:end-1) < 1) = [];
        if ~isempty(lapInds) && length(lapInds)>=2
            bounds=[lapInds(end-1) lapInds(end)];
            powAvg=sum(energy(bounds(1):bounds(2)))/(obj.winchPower.Time(bounds(2))-obj.winchPower.Time(bounds(1)));
            fprintf('Average power for the last lap = %.5g kW.\n',powAvg/1000);
        else
            bounds = [1 length(obj.winchPower.Time)];
            powAvg = sum(energy(bounds(1):bounds(2)))/(obj.winchPower.Time(bounds(2))-obj.winchPower.Time(bounds(1)));
            fprintf('Less Than 1 Lap Detected. Average power for the entire simulation = %.5g kW.\n',powAvg/1000);
        end
    else
        bounds = [1 length(obj.winchPower.Time)];
        powAvg = sum(energy(bounds(1):bounds(2)))/(obj.winchPower.Time(bounds(2))-obj.winchPower.Time(bounds(1)));
        fprintf('Less Than 1 Lap Detected. Average power for the entire simulation = %.5g kW.\n',powAvg/1000);
    end
    if nargout == 1
        varargout{1}=powAvg;
    end
%     save('pow.mat','powAvg')
end
end