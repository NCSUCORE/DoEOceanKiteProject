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
            obj.numSurfaces = SIM.parameter;
            obj.numTurbines = SIM.parameter;
            obj.numTethers  = SIM.parameter;
            obj.centOfBuoy  = SIM.parameter('Unit','m','Description','centOfBuoy');
            obj.mass        = SIM.parameter('Unit','kg','Description','mass');
            obj.Ixx         = SIM.parameter('Unit','kg*m^2','Description','Ixx');
            obj.Iyy         = SIM.parameter('Unit','kg*m^2','Description','Iyy');
            obj.Izz         = SIM.parameter('Unit','kg*m^2','Description','Izz');
            obj.Ixy         = SIM.parameter('Unit','kg*m^2','Description','Ixy');
            obj.Ixz         = SIM.parameter('Unit','kg*m^2','Description','Ixz');
            obj.Iyz         = SIM.parameter('Unit','kg*m^2','Description','Iyz');
            obj.inertia     = SIM.parameter('Unit','kg*m^2','Description','inertia');
            obj.initPosVecGnd     = SIM.parameter('Unit','m','Description','initPosVecGnd');
            obj.initVelVecGnd     = SIM.parameter('Unit','m/s','Description','initVelVecGnd');
            obj.initEulAngBdy     = SIM.parameter('Unit','rad','Description','initEulAngBdy');
            obj.initAngVelVecBdy  = SIM.parameter('Unit','rad/s','Description','initAngVelVecBdy');
            obj.volume            = SIM.parameter('Unit','m^3','Description','volume');            
        end % end vehicle
        
        % Function to build the vehicle
        function obj = build(obj,AeroStructFile,varargin)
            
            p = inputParser;
            addRequired(p,'AeroStructFile',@ischar)
            parse(p,AeroStructFile)
            
            load(p.Results.AeroStructFile)
            obj.numSurfaces.setValue(numel(aeroStruct),'');
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
                    obj.(p.Results.SurfaceNames{ii}).(propNames{jj}).setValue(aeroStruct(ii).(propNames{jj}),obj.(p.Results.SurfaceNames{ii}).(propNames{jj}).Unit);
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
            
            
        end % end build
        function val = get.inertia(obj)
            val = SIM.parameter('Value',[obj.Ixx.Value -abs(obj.Ixy.Value) -abs(obj.Ixz.Value);...
                -abs(obj.Ixy.Value) obj.Iyy.Value -abs(obj.Iyz.Value);...
                -abs(obj.Ixz.Value) -abs(obj.Iyz.Value) obj.Izz.Value],'Unit','kg*m^2');
        end % end get.inertia

        % Function to scale the object
        function obj = scale(obj,scaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(scaleFactor);
            end
        end % end scale
        
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
            obj.initPosVecGnd.setValue(p.Results.InitPos,'m');
            obj.initVelVecGnd.setValue(p.Results.InitVel,'m/s');
            obj.initEulAngBdy.setValue(p.Results.InitEulAng,'rad');
            obj.initAngVelVecBdy.setValue(p.Results.InitAngVel,'rad/s');
        end
    end
end

