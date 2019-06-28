classdef vehicle < dynamicprops
    
    %VEHICLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
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
            obj.numSurfaces = SIM.parameter('Description','Number of fluid dynamic surfaces');
            obj.numTurbines = SIM.parameter('Description','Number of turbines');
            obj.numTethers  = SIM.parameter('Description','Number of tethers');
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
        %% Setters
        function setNumSurfaces(obj,val,units)
            obj.numSurfaces.setValue(val,units);
        end
        
        function setNumTurbines(obj,val,units)
            obj.numTurbines.setValue(val,units);
        end
        
        function setNumTethers(obj,val,units)
            obj.numTethers.setValue(val,units);
        end
        
        function setCentOfBuoy(obj,val,units)
            obj.centOfBuoy.setValue(val,units);
        end
        
        function setMass(obj,val,units)
            obj.mass.setValue(val,units);
        end
        
        function setIxx(obj,val,units)
            obj.Ixx.setValue(val,units);
        end
        
        function setIyy(obj,val,units)
            obj.Iyy.setValue(val,units);
        end
        
        function setIzz(obj,val,units)
            obj.Izz.setValue(val,units);
        end
        
        function setIxy(obj,val,units)
            obj.Ixy.setValue(val,units);
        end
        
        function setIxz(obj,val,units)
            obj.Ixz.setValue(val,units);
        end
        
        function setIyz(obj,val,units)
            obj.Iyz.setValue(val,units);
        end
        
        function setInertia(obj,val,units)
            obj.inertia.setValue(val,units);
        end
        
        function setInitPosVecGnd(obj,val,units)
            obj.initPosVecGnd.setValue(val,units);
        end
        
        function setInitVelVecGnd(obj,val,units)
            obj.initVelVecGnd.setValue(val,units);
        end
        
        function setInitEulAngBdy(obj,val,units)
            obj.initEulAngBdy.setValue(val,units);
        end
        
        function setInitAngVelVecBdy(obj,val,units)
            obj.initAngVelBdy.setValue(val,units);
        end
        
        function setVolume(obj,val,units)
            obj.volume.setValue(val,units);
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
            addParameter(p,'SurfaceNames',defSurfName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'TetherNames',defThrName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            parse(p,varargin{:})
            
            % Create aero surface fields
            for ii = 1:obj.numSurfaces.Value
                obj.addprop(p.Results.SurfaceNames{ii});
                obj.(p.Results.SurfaceNames{ii}) = OCT.aeroSurf;
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
                try
                    obj.(props{ii}).scale(scaleFactor);
                catch
                    x = 1;
                end
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
                    if isa(obj.(props{ii}).(subProps{jj}),'SIM.parameter')
                        val(ii).(subProps{jj}) = obj.(props{ii}).(subProps{jj}).Value;
                    end
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
        function save(obj,fileName)
            vhcl = obj;
            save(fileName,'vhcl')
        end
        % Function to run AVL on all OCT.aeroSurf properties
        function AVL(obj,varargin)
            
            p = inputParser;
            addParameter(p,'SaveFileName',[],@ischar);
            parse(p,varargin{:})
            
            props = getPropsByClass(obj,'OCT.aeroSurf');
            for ii = 1:numel(props)
                obj.(props{ii}).AVL;
            end
            
            if ~isempty(p.Results.SaveFileName)
                vhcl = obj;
                filePath = fileparts(which('OCTProject.prj'));
                filePath = fullfile(filePath,'vehicleDesign','AVL','designLibrary',p.Results.SaveFileName);
                save(filePath,'vhcl')
            end
            
        end
        
        % function to plot the geometry
        function h = plotGeometry(obj,varargin)
            p = inputParser;
            addParameter(p,'FigHandle',[],@(x) isa(x,'matlab.ui.Figure'));
            addParameter(p,'EulerAngles',[0 0 0],@isnumeric);
            addParameter(p,'Position',[0 0 0],@isnumeric);
            parse(p,varargin{:})
            
            if isempty(p.Results.FigHandle)
                h.fig = figure('Position',[1          41        1920         963],'Units','pixels');
            else
                h.fig = p.Results.figHandle;
            end
            
            surfaces = obj.getPropsByClass('OCT.aeroSurf');
            for ii = 1:numel(surfaces)
                obj.(surfaces{ii}).plotGeometry(...
                    'FigHandle',h.fig,...
                    'EulerAngles',p.Results.EulerAngles,...
                    'Position',p.Results.Position);
            end
            grid on
            set(gca,'DataAspectRatio',[1 1 1])
        end
        
        % Function to plot polars
        % Function to run AVL on all OCT.aeroSurf properties
        function plotPolars(obj,varargin)
            props = getPropsByClass(obj,'OCT.aeroSurf');
            for ii = 1:numel(props)
                obj.(props{ii}).plotPolars;
                set(gcf,'Name',props{ii})
            end
        end
        
        
    end
end

