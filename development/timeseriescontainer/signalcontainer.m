classdef signalcontainer < dynamicprops
    %SIGNALCONTAINER Summary of this class goes here
    %   Detailed explanation goes here
    
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
                    % add each signal to the struct
                    for ii = 1:length(names)
                        ts = objToParse.getElement(names{ii});
                        switch class(ts.Values)
                            case 'timeseries'
                                % add signal object
                                obj.addprop(ts.Name);
                                obj.(ts.Name) = timesignal(ts.Values);
                            case 'struct'
                                % otherwise, add a signal container and
                                % call the constructor on that sigcontainer
                                obj.addprop(ts.Name);
                                obj.(ts.Name) = signalcontainer(ts.Values);
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
                                obj.addprop(ts.Name);
                                obj.(ts.Name) = timesignal(ts);
                            case 'struct'
                                % otherwise, add a signal container and
                                % call the constructor on that sigcontainer
                                
                                obj.addprop(names{ii});
                                obj.(names{ii}) = signalcontainer(ts);
                                
                            otherwise
                                warning('Unknown signal class in logsout, skipping signal: %s ',ts.Name)
                                
                        end
                    end
                otherwise
                    error('Unknown class in logsout')
            end
        end
        
        function obj = crop(obj,varargin)
            switch numel(varargin)
                case 1
                    
                    startTime = min(varargin{1}(:));
                    endTime   = max(varargin{1}(:));
                case 2
                    startTime = varargin{1};
                    endTime   = varargin{2};
                otherwise
                    error('Incorrect number of input arguments')
            end
            
            
            props = properties(obj);
            
            for ii = 1:numel(props)
                try
                    obj.(props{ii}) = obj.(props{ii}).crop(varargin{:});
                catch
                    
                    x = 1;
                end
                %                    obj
                
                % Call crop functions recursively
            end
        end
        
    end
end

