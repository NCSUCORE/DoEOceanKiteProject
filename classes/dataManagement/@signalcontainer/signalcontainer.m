classdef signalcontainer < dynamicprops
    %SIGNALCONTAINER Custom class used to store and organize timesignal
    %objects.
    
    properties
        
    end
    
    methods
        function obj = signalcontainer(objToParse,varargin)
            % Parse inputs
            p = inputParser;
%             addOptional(p,'logsout',[],@(x) isa(x,'Simulink.SimulationData.Dataset'))
            addOptional(p,'structBlockPath',[],@(x) isa(x,'Simulink.SimulationData.BlockPath')||isempty(x))
            addParameter(p,'Verbose',true,@islogical);
            parse(p,varargin{:});
            switch class(objToParse)
                case {'Simulink.SimulationData.Dataset','Simulink.sdi.DatasetRef'}
                    % Add metadata to the signal container at highest level
                    obj.addprop('metadata');
                    obj.metadata = metadata(p.Results.Verbose);
                    % get names of signals
                    names = objToParse.getElementNames;
                    % get rid of unnamed signals (empty strings)
                    names = names(cellfun(@(x) ~isempty(x),names));
                    % get rid of duplicate signal names
                    names = unique(names);
                    % add each signal to the signalcontainer
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
                                    obj.(propName) = signalcontainer(ts.Values(jj),'structBlockPath',ts.BlockPath);
                            end
                        end
                    end
                    % Print out power summary for the user
                    if p.Results.Verbose
                        obj.powersummary
                    end
                case 'struct'
                    % Add metadata to the signal container at highest level
                    obj.addprop('metadata');
                    obj.metadata = metadata(p.Results.Verbose);
                    % get names of signals
                    names = fieldnames(objToParse);
                    % get rid of unnamed signals (empty strings)
                    names = names(cellfun(@(x) ~isempty(x),names));
                    % get rid of duplicate signal names
                    names = unique(names);
                    % add each signal to the signalcontainer
                    for ii = 1:length(names)
                        % Get element from logsout
                        ts = objToParse.(names{ii});
                        % Get the name of the name and make it a valid
                        % property name
                        if isa(ts,'struct')
                            propName = genvarname(names{ii});
                        elseif ~isempty(ts.Name)
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
                        % Loop through each signal stored in ts.Values
                        switch class(ts)
                                case {'timeseries','timesignal'}
                                    obj.(propName) = timesignal(ts,'BlockPath',p.Results.structBlockPath);
                                case 'struct'
                                    obj.(propName) = signalcontainer(ts,'structBlockPath',p.Results.structBlockPath);
                        end
                    end
                case 'signalcontainer'
                    obj.addprop('metadata');
                    obj.metadata = objToParse.metadata;
                    propNames = properties(objToParse);
                    propNames = propNames(cellfun(@(x) ~strcmp(x,'metadata'),propNames));
                    for ii = 1:numel(propNames)
                        obj.addprop(propNames{ii});
                        switch class(objToParse.(propNames{ii}))
                            case {'timesignal','timeseries'}
                                obj.(propNames{ii}) = timesignal(objToParse.(propNames{ii}));
                            case {'signalcontainer','struct'}
                                obj.(propNames{ii}) = signalcontainer(objToParse.(propNames{ii}));
                        end
                    end
                otherwise
                    error('Unknown data type to parse')
            end
        end


    end
end

