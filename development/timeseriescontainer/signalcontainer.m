classdef signalcontainer
    %SIGNALCONTAINER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = signalcontainer(logsout,varargin)
            p = inputParser;
            addOptional(p,'logsout',[],@(x) isa(x,'Simulink.SimulationData.Dataset'))
            addParameter(p,'Verbose',false,@islogical);
            parse(p,varargin{:});
            
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
                    if p.Results.Verbose
                        warning('Duplicate signal names %s, skipping', names{ii})
                    end
                end
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

