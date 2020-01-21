classdef signalcontainer < dynamicprops
    %SIGNALCONTAINER Custom class used to store and organize timesignal
    %objects.
    
    properties
        
    end
    
    methods
        function obj = signalcontainer(objToParse,varargin)
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
                            warning('Duplicate signal names: ''%s''.  Taking first found signal.',ts{1}.Name)
                            ts = ts{1};
                        end
                        switch class(ts.Values)
                            case 'timeseries'
                                % add signal object
                                propName = genvarname(ts.Name);
                                obj.addprop(propName);
                                obj.(propName) = timesignal(ts.Values);
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
                                warning('Unknown signal class in logsout, skipping signal: %s ',ts.Name)
                                
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
                                propName = genvarname(ts.Name);
                                obj.addprop(propName);
                                obj.(propName) = timesignal(ts);
                            case 'struct'
                                % otherwise, add a signal container and
                                % call the constructor on that sigcontainer
                                propName = genvarname(names{ii});
                                obj.addprop(propName);
                                obj.(propName) = signalcontainer(ts);
                            otherwise
                                warning('Unknown signal class in logsout, skipping signal: %s ',ts.Name)
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
                                propName = genvarname(ts.Name);
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
            newobj=obj;
            props = properties(obj);
            for ii = 1:numel(props)
                newobj.(props{ii}) = obj.(props{ii}).crop(varargin{:});
            end
        end
        
        % Function to crop with GUI
        function obj = guicrop(obj,sigName)
            hFig = obj.(sigName).plot;
            [x,~] = ginput(2);
            close(hFig);
            obj = obj.crop(min(x),max(x));
        end
        
        function obj = resample(obj,varargin)
            % Call the crop method of each property
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}) = obj.(props{ii}).resample(varargin{:});
            end
        end
        
    end
end

