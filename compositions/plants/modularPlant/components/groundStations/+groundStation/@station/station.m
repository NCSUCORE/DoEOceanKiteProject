classdef station < dynamicprops
    
    %VEHICLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numTethers
        inertia
        dampCoeff
        initAngPos
        initAngVel
        freeSpnEnbl
        posVec
    end
    
    methods
        function obj = station
            %VEHICLE Construct an instance of this class
            obj.numTethers  = vehicle.param('IgnoreScaling',true);
            obj.inertia     = vehicle.param('Unit','kg*m^2');
            obj.dampCoeff   = vehicle.param('Unit','N*s/m');
            obj.initAngPos  = vehicle.param('Unit','rad');
            obj.initAngVel  = vehicle.param('Unit','rad/s');
            obj.freeSpnEnbl = vehicle.param;
            obj.posVec      = vehicle.param('Unit','m');
        end
        
        % Function to build the vehicle
        function obj = build(obj,varargin)
            % Populate cell array of default names
            defThrName = {};
            for ii = 1:obj.numTethers.Value
                defThrName{ii} = sprintf('thrAttch%d',ii);
            end
            p = inputParser;
            addParameter(p,'TetherNames',defThrName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            parse(p,varargin{:})
            
            % Create tethers
            for ii = 1:obj.numTethers.Value
                obj.addprop(p.Results.TetherNames{ii});
                obj.(p.Results.TetherNames{ii}) = groundStation.thrAttach;
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
            % Example classnames: vehicle.turb, vehicle.aeroSurf
            props = obj.getPropsByClass(className);
            if numel(props)<1
                return
            end
            subProps = properties(obj.(props{1}));
            for ii = 1:length(props)
                for jj = 1:numel(subProps)
                    val(ii).(subProps{jj}) = obj.(props{ii}).(subProps{jj}).Value;
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
        
        % function to set initial conditions
        function obj = setICs(obj,varargin)
            p = inputParser;
            addParameter(p,'InitAngPos',0,@isnumeric)
            addParameter(p,'InitAngVel',0,@isnumeric)
            parse(p,varargin{:})
            obj.initAngPos.Value    = p.Results.InitPos;
            obj.initAngVel.Value    = p.Results.InitVel;
        end
    end
end

