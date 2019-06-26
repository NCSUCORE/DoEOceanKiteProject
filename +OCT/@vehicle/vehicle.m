classdef vehicle < dynamicprops
    
    %VEHICLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numSurfaces
        numTurbines
        numTethers
        centOfBuoy
        mass
        Ixx
        Iyy
        Izz
        Ixy
        Ixz
        Iyz
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
            obj.numSurfaces = SIM.param;
            obj.numTurbines = SIM.param;
            obj.numTethers  = SIM.param;
            obj.centOfBuoy  = SIM.param('Unit','m');
            obj.mass        = SIM.param('Unit','kg');
            obj.Ixx         = SIM.param('Unit','kg*m^2');
            obj.Iyy         = SIM.param('Unit','kg*m^2');
            obj.Izz         = SIM.param('Unit','kg*m^2');
            obj.Ixy         = SIM.param('Unit','kg*m^2');
            obj.Ixz         = SIM.param('Unit','kg*m^2');
            obj.Iyz         = SIM.param('Unit','kg*m^2');
            obj.inertia     = SIM.param('Unit','kg*m^2');
            obj.initPosVecGnd     = SIM.param('Unit','m');
            obj.initVelVecGnd     = SIM.param('Unit','m/s');
            obj.initEulAngBdy     = SIM.param('Unit','rad');
            obj.initAngVelVecBdy  = SIM.param('Unit','rad/s');
            obj.volume            = SIM.param('Unit','m^3');
            
        end
        
        % Function to build the vehicle
        function obj = build(obj,AeroStructFile,varargin)
            
            p = inputParser;
            addRequired(p,'AeroStructFile',@ischar)
            parse(p,AeroStructFile)
            
            load(p.Results.AeroStructFile)
            obj.numSurfaces.Value = numel(aeroStruct);
            % Populate cell array of default names
            defSurfName = {};
            for ii = 1:obj.numSurfaces.Value
                defSurfName{ii} = sprintf('aeroSurf%d',ii);
            end
            defThrName = {};
            for ii = 1:obj.numTethers.Value
                defThrName{ii} = sprintf('thrAttch%d',ii);
            end
            
            addParameter(p,'SurfaceNames',defSurfName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'TetherNames',defThrName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            parse(p,AeroStructFile)
            
            % Create aero surface fields
            propNames = fields(aeroStruct);
            
            for ii = 1:obj.numSurfaces.Value
                obj.addprop(p.Results.SurfaceNames{ii});
                obj.(p.Results.SurfaceNames{ii}) = OCT.aeroSurf;
                
                for jj = 1:length(propNames)
                    obj.(p.Results.SurfaceNames{ii}).(propNames{jj}).Value = aeroStruct(ii).(propNames{jj});
                end
            end
            % Create tethers attachment points
            for ii = 1:obj.numTethers.Value
                obj.addprop(p.Results.TetherNames{ii});
                obj.(p.Results.TetherNames{ii}) = OCT.thrAttch;
            end
            % Create turbines
            for ii = 1:obj.numTurbines.Value
                obj.addprop(sprintf('turbine%d',ii));
                obj.(sprintf('turbine%d',ii)) = OCT.turb;
            end
            
            
        end
        function val = get.inertia(obj)
            val = SIM.param('Value',[obj.Ixx.Value -abs(obj.Ixy.Value) -abs(obj.Ixz.Value);...
                -abs(obj.Ixy.Value) obj.Iyy.Value -abs(obj.Iyz.Value);...
                -abs(obj.Ixz.Value) -abs(obj.Iyz.Value) obj.Izz.Value],'Unit','kg*m^2');
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

