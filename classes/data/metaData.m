classdef metaData
    %METADATA classdef to hold metadata for the signal container class
    properties
        author
        machine
        createdOn
        callStack
        activeVariants
    end
    
    methods
        function newObj = crop(obj)
            newObj = obj;
        end
        
        function obj = metaData(varargin)
            if ~isempty(varargin)
                verbose=varargin{1};
            end
            % Name of computer user calling this
            obj.author = getenv('username');
            % Name of computer they are using
            obj.machine = getenv('computername');
            % Date of creation
            obj.createdOn = datestr(now);
            % Callstack used to create this
            obj.callStack = dbstack;
            
            obj.activeVariants = {};
            baseVars = evalin('base','who');
            for ii = 1:numel(baseVars)
                if evalin('base',sprintf('isa(%s,''Simulink.Variant'')',baseVars{ii}))
                    try
                    if evalin('base',sprintf('eval(%s.Condition)',baseVars{ii}))
                        obj.activeVariants = {obj.activeVariants;baseVars{ii}};
                    end
                    catch
                        if verbose
                            warning('Unable to evaluate %s.Condition',baseVars{ii})
                        end
                    end
                end
            end
        end
    end
end

