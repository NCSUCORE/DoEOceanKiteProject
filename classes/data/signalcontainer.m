classdef signalcontainer < dynamicprops
    %SIGNALCONTAINER Custom class used to store and organize timesignal
    %objects.
    
    properties
        metaData
    end
    
    methods
        function obj = signalcontainer(objToParse,varargin)
            % Add metadata to the signal container
            obj.metaData = metaData;
            % Parse inputs
            p = inputParser;
            addOptional(p,'logsout',[],@(x) isa(x,'Simulink.SimulationData.Dataset'))
            addParameter(p,'Verbose',false,@islogical);
            parse(p,varargin{:});
            
            switch class(objToParse)
                case 'Simulink.SimulationData.Dataset'
                    % get names of signals
                    names = objToParse.getElementNames;
                    % get rid of unnamed signals (empty strings)
                    names = names(cellfun(@(x) ~isempty(x),names));
                    % get rid of duplicate signal names
                    names = unique(names);
                    % add each signal to the struct
                    for ii = 1:length(names)
                        ts = objToParse.getElement(names{ii});
                        if isa(ts,'Simulink.SimulationData.Dataset')
                            if p.Results.Verbose
                                warning('Duplicate signal names: ''%s''.  Taking first found signal.',ts{1}.Name)
                            end
                            ts = ts{1};
                        end
                        switch class(ts.Values)
                            case 'timeseries'
                                % add signal object
                                propName = genvarname(ts.Name);
                                obj.addprop(propName);
                                obj.(propName) = timesignal(ts.Values,'BlockPath',ts.BlockPath);
                            case 'struct'
                                % otherwise, add a signal container and
                                % call the constructor on that sigcontainer
                                propName = genvarname(ts.Name);
                                obj.addprop(propName);
                                obj.(propName) = signalcontainer.empty(0);
                                for jj = 1:numel(ts.Values)
                                    obj.(propName)(jj) = signalcontainer(ts.Values(jj));
                                end
                            otherwise
                                if p.Results.Verbose
                                    warning('Unknown signal class in logsout, skipping signal: %s ',ts.Name)
                                end
                                
                        end
                    end
                case 'struct'
                    % get names of signals
                    names = fieldnames(objToParse);
                    % get rid of unnamed signals (empty strings)
                    names = names(cellfun(@(x) ~isempty(x),names));
                    % add each signal to the struct
                    for ii = 1:length(names)
                        ts = objToParse.(names{ii});
                        switch class(ts)
                            case 'timeseries'
                                % add signal object
                                propName = genvarname(names{ii});
                                obj.addprop(propName);
                                obj.(propName) = timesignal(ts);
                            case 'struct'
                                % otherwise, add a signal container and
                                % call the constructor on that sigcontainer
                                propName = genvarname(names{ii});
                                obj.addprop(propName);
                                obj.(propName) = signalcontainer(ts);
                            otherwise
                                if p.Results.Verbose
                                    warning('Unknown signal class in logsout, skipping signal: %s ',ts.Name)
                                end
                        end
                    end
                case 'signalcontainer'
                    % get names of signals
                    names = fieldnames(objToParse);
                    % get rid of unnamed signals (empty strings)
                    names = names(cellfun(@(x) ~isempty(x),names));
                    % add each signal to the struct
                    for ii = 1:length(names)
                        ts = objToParse.(names{ii});
                        switch class(ts)
                            case 'timesignal'
                                propName = genvarname(names{ii});
                                obj.addprop(propName);
                                obj.(propName) = timesignal(ts);
                            case 'signalcontainer'
                                propName = genvarname(names{ii});
                                obj.addprop(propName);
                                obj.(propName) = signalcontainer(ts);
                        end
                    end
                otherwise
                    error('Unknown class in logsout')
            end
        end
        
        % Function to crop all signals
        function newobj = crop(obj,varargin)
            % Call the crop method of each property
            newobj=signalcontainer(obj);
            props = properties(newobj);
            for ii = 1:numel(props)
                if ismethod(newobj.(props{ii}),'crop')
                    newobj.(props{ii}) = newobj.(props{ii}).crop(varargin{:});
                end
            end
        end
        
        % Function to crop with GUI
        function newobj = guicrop(obj,sigName)
            newobj = signalcontainer(obj);
            hFig = newobj.(sigName).plot;
            [x,~] = ginput(2);
            close(hFig);
            newobj = newobj.crop(min(x),max(x));
        end
        
        function newobj = resample(obj,varargin)
            % Call the crop method of each property
            newobj = signalcontainer(obj);
            props = properties(newobj);
            for ii = 1:numel(props)
                if ismethod(newobj.(props{ii}),'resample')
                newobj.(props{ii}) = newobj.(props{ii}).resample(varargin{:});
                end
            end
        end
        
    end
end

