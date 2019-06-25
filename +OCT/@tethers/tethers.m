classdef tethers < dynamicprops
    %TETHERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numTethers
    end
    
    methods
        function obj = tethers
            obj.numTethers      = OCT.param('IgnoreScaling',true);
        end
        
        function obj = build(obj,varargin)
            defThrName = {};
            for ii = 1:obj.numTethers.Value
                defThrName{ii} = sprintf('tether%d',ii);
            end
            
            p = inputParser;
            addParameter(p,'TetherNames',defThrName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            parse(p,varargin{:})
            
            % Create tethers
            for ii = 1:obj.numTethers.Value
                obj.addprop(p.Results.TetherNames{ii});
                obj.(p.Results.TetherNames{ii}) = OCT.tether;
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
        % Function to get properties according to their class
        % May be able to vectorize this somehow
        function val = getPropsByClass(obj,className)
            props = properties(obj);
            val = {};
            for ii = 1:length(props)
                if isa(obj.(props{ii}),className)
                    val{end+1} = props{ii};
                end
            end
        end
        % Function to scale the object
        function obj = scale(obj,scaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(scaleFactor);
            end
        end
        
    end
end

