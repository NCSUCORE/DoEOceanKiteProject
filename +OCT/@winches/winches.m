classdef winches < dynamicprops
    %WINCHES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numWinches
    end
    
    methods
        
        function obj = winches
            obj.numWinches = OCT.param('IgnoreScaling',true);
        end
        
        function obj = build(obj,varargin)
            defNames = {};
            for ii = 1:obj.numWinches.Value
                defNames{ii} = sprintf('winch%d',ii);
            end
            p = inputParser;
            addParameter(p,'WinchNames',defNames,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            parse(p,varargin{:})
            % Create winches
            for ii = 1:obj.numWinches.Value
                obj.addprop(p.Results.WinchNames{ii});
                obj.(p.Results.WinchNames{ii}) = OCT.winch;
            end
        end
        
        % Function to scale the object
        function obj = scale(obj,scaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(scaleFactor);
            end
        end
        
        function val = struct(obj,className)
            % Function returns all properties of the specified class in a
            % 1xN struct useable in a for loop in simulink
            % Example classnames: OCT.turb, OCT.aeroSurf
            props = sort(obj.getPropsByClass(className));
            if numel(props)<1
                return
            end
            subProps = properties(obj.(props{1}));
            for ii = 1:length(props)
                for jj = 1:numel(subProps)
                    param = obj.(props{ii}).(subProps{jj});
                    val(ii).(subProps{jj}) = param.Value;
                end
            end
        end
        
        function val = getPropsByClass(obj,className)
            props = properties(obj);
            val = {};
            for ii = 1:length(props)
                if isa(obj.(props{ii}),className)
                    val{end+1} = props{ii};
                end
            end
        end
    end
end

