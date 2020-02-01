classdef signalcontainer < dynamicprops
    %SIGNALCONTAINER Custom class used to store and organize timesignal
    %objects.
    
    properties
        
    end
    
    methods
        function obj = signalcontainer(objToParse,varargin)
            % Parse inputs
            p = inputParser;
            addOptional(p,'logsout',[],@(x) isa(x,'Simulink.SimulationData.Dataset'))
            addParameter(p,'Verbose',true,@islogical);
            parse(p,varargin{:});
            switch class(objToParse)
                case {'Simulink.SimulationData.Dataset','Simulink.sdi.DatasetRef'}
                    % Add metadata to the signal container at highest level
                    obj.addprop('metaData');
                    obj.metaData = metaData(p.Results.Verbose);
                    % get names of signals
                    names = objToParse.getElementNames;
                    % get rid of unnamed signals (empty strings)
                    names = names(cellfun(@(x) ~isempty(x),names));
                    % get rid of duplicate signal names
                    names = unique(names);
                    % add each signal to the struct
                    for ii = 1:length(names)
                        % Get element from logsout
                        ts = objToParse.getElement(names{ii});
                        % Get the name of the name and make it a valid
                        % property name
                        if ~isempty(ts.Name)
                        propName = genvarname(ts.Name);
                        else
                            propName = genvarname(names{ii});
                        end
                        % Deal with duplicate signal names
                        if isa(ts,'Simulink.SimulationData.Dataset')
                            if p.Results.Verbose
                                warning('Duplicate signal names: ''%s''.  Taking first found signal.',ts{1}.Name)
                            end
                            ts = ts{1};
                        end
                        % Add a new field by this name
                        obj.addprop(propName);
                        % Preallocate with empty structure
                        obj.(propName) = struct.empty(numel(ts.Values),0);
                        % Loop through each signal stored in ts.Values
                        for jj = 1:numel(ts.Values)
                            switch class(ts.Values(jj))
                                case 'timeseries'
                                    obj.(propName) = timesignal(ts.Values(jj),'BlockPath',ts.BlockPath);
                                case 'struct'
                                    subPropNames = fieldnames(ts.Values);
                                    for kk = 1:numel(subPropNames)
                                        obj.(propName)(jj).(subPropNames{kk}) = timesignal(ts.Values(jj).(subPropNames{kk}),'BlockPath',ts.BlockPath);
                                    end
                            end
                        end
                    end
                otherwise
                    error('Unknown data type to parse')
            end
            
            % Print out power summary for the user
            if p.Results.Verbose
                obj.powerSummary
            end
            
        end
        
        % Function to summarize power
        function powerSummary(obj)
            % Print out power summary
            if isprop(obj,'winchPower')
                diffTime = diff(obj.winchPower.Time);
                timesteps = .5*([diffTime; diffTime(end)] + [diffTime(1); diffTime]); %averages left and right timestep lengths for each data point.
                energy=squeeze(obj.winchPower.Data).*squeeze(timesteps);
                if isfield(obj,'closestPathVariable')
                    lapInds = find(abs(obj.closestPathVariable.Data(2:end)-obj.closestPathVariable.Data(1:end-1))>.95);
                    if ~isempty(lapInds) && length(lapInds)>=2
                        bounds=[lapInds(end-1) lapInds(end)];
                        powAvg=sum(energy(bounds(1):bounds(2)))/(obj.winchPower.Time(bounds(2))-obj.winchPower.Time(bounds(1)));
                        fprintf('Average power for the last lap = %.5g kW.\n',powAvg/1000);
                    else
                        bounds = [1 length(obj.winchPower.Time)];
                        powAvg = sum(energy(bounds(1):bounds(2)))/(obj.winchPower.Time(bounds(2))-obj.winchPower.Time(bounds(1)));
                        fprintf('Average power for the simulation = %.5g kW.\n',powAvg/1000);
                    end
                else
                    bounds = [floor(length(obj.winchPower.Time)/2) length(obj.winchPower.Time)];
                    powAvg = sum(energy(bounds(1):bounds(2)))/(obj.winchPower.Time(bounds(2))-obj.winchPower.Time(bounds(1)));
                    fprintf('Average power for the last half of the simulation = %.5g kW.\n',powAvg/1000);
                end
            end
        end
        
        % Function to crop all signals
        function newObj = crop(obj,varargin)
            % Call the crop method of each property
            newObj = obj;
            props  = properties(newObj);
            for ii = 1:numel(props)
                switch class(newObj.(props{ii}))
                    case 'timesignal'
                        if ismethod(newObj.(props{ii}),'crop')
                            newObj.(props{ii}) = newObj.(props{ii}).crop(varargin{:});
                        end
                    case 'struct'
                        subProps = fields(newObj.(props{ii}));
                        for jj = 1:numel(newObj.(props{ii})) % Loop through stuct
                            for kk = 1:numel(subProps) % Loop through properties
                                if ismethod(newObj.(props{ii})(jj).(subProps{kk}),'crop')
                                    newObj.(props{ii})(jj).(subProps{kk}) = newObj.(props{ii})(jj).(subProps{kk}).crop(varargin{:});
                                end
                            end
                        end
                   
                end
            end
        end
        % Function to crop with GUI
        function newObj = guicrop(obj,sigName)
            newObj = obj;
            hFig = newObj.(sigName).plot;
            [x,~] = ginput(2);
            close(hFig);
            newObj = newObj.crop(min(x),max(x));
        end
        
        function newObj = resample(obj,varargin)
            % Call the crop method of each property
            %             newObj = obj;
            %             props = properties(newObj);
            %             for ii = 1:numel(props)
            %                 if ismethod(newObj.(props{ii}),'resample')
            %                     newObj.(props{ii}) = newObj.(props{ii}).resample(varargin{:});
            %                 end
            %             end
            newObj = obj;
            props  = properties(newObj);
            for ii = 1:numel(props)
                switch class(newObj.(props{ii}))
                    case {'timesignal','timeseries'}
                        if ismethod(newObj.(props{ii}),'crop')
                            newObj.(props{ii}) = newObj.(props{ii}).resample(varargin{:});
                        end
                    case 'struct'
                        subProps = fields(newObj.(props{ii}));
                        for jj = 1:numel(newObj.(props{ii})) % Loop through stuct
                            for kk = 1:numel(subProps) % Loop through properties
                                if ismethod(newObj.(props{ii})(jj).(subProps{kk}),'crop')
                                    newObj.(props{ii})(jj).(subProps{kk}) = newObj.(props{ii})(jj).(subProps{kk}).resample(varargin{:});
                                end
                            end
                        end
                end
            end
        end
        
    end
end

