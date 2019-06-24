classdef vehicle < dynamicprops
    
    %VEHICLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numSurfaces
        numTurbines
        numTethers
        centOfBuoy
        mass
        inertia
        initPosVecGnd
        initVelVecGnd
        initEulAngBdy
        initAngVelVecBdy
        volume
    end
    
    methods
        function obj = vehicle
            %VEHICLE Construct an instance of this class
            obj.numSurfaces = vehicle.param;
            obj.numTurbines = vehicle.param;
            obj.numTethers  = vehicle.param;
            obj.centOfBuoy  = vehicle.param('Unit','m');
            obj.mass        = vehicle.param('Unit','kg');
            obj.inertia     = vehicle.param('Unit','kg*m^2');
            obj.initPosVecGnd     = vehicle.param('Unit','m');
            obj.initVelVecGnd     = vehicle.param('Unit','m/s');
            obj.initEulAngBdy     = vehicle.param('Unit','rad');
            obj.initAngVelVecBdy  = vehicle.param('Unit','rad/s');
            obj.volume            = vehicle.param('Unit','m^3');
            
        end
        
        % Function to build the vehicle
        function obj = build(obj,varargin)
            % Populate cell array of default names
            defSurfName = {};
            for ii = 1:obj.numSurfaces.Value
                defSurfName{ii} = sprintf('aeroSurf%d',ii);
            end
            defThrName = {};
            for ii = 1:obj.numTethers.Value
                defThrName{ii} = sprintf('thrAttch%d',ii);
            end
            p = inputParser;
            addRequired(p,'AeroStructFile',@ischar)
            addParameter(p,'SurfaceNames',defSurfName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'TetherNames',defThrName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            parse(p,varargin{:})
            
            % Create aero surface fields
            load(p.Results.AeroStructFile)
            propNames = fields(aeroStruct);
            obj.numSurfaces.Value = numel(aeroStruct);
            for ii = 1:obj.numSurfaces.Value
                obj.addprop(p.Results.SurfaceNames{ii});
                obj.(p.Results.SurfaceNames{ii}) = vehicle.aeroSurf;
                
                for jj = 1:length(propNames)
                    obj.(p.Results.SurfaceNames{ii}).(propNames{jj}).Value = aeroStruct(ii).(propNames{jj});
                end
            end
            % Create tethers
            for ii = 1:obj.numTethers.Value
                obj.addprop(p.Results.TetherNames{ii});
                obj.(p.Results.TetherNames{ii}) = vehicle.thrAttch;
            end
            % Create turbines
            for ii = 1:obj.numTurbines.Value
                obj.addprop(sprintf('turbine%d',ii));
                obj.(sprintf('turbine%d',ii)) = vehicle.turb;
            end
            
            
        end
        
        % Function to scale the object
        function obj = scale(obj,scaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}) = obj.(props{ii}).scale(scaleFactor);
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
            addParameter(p,'InitPos',[0 0 0],@isnumeric)
            addParameter(p,'InitVel',[0 0 0]',@isnumeric)
            addParameter(p,'InitEulAng',[0 0 0],@isnumeric)
            addParameter(p,'InitAngVel',[0 0 0]',@isnumeric)
            parse(p,varargin{:})
            obj.initPosVecGnd.Value     = p.Results.InitPos;
            obj.initVelVecGnd.Value     = p.Results.InitVel;
            obj.initEulAngBdy.Value     = p.Results.InitEulAng;
            obj.initAngVelVecBdy.Value  = p.Results.InitAngVel;
        end
    end
end

