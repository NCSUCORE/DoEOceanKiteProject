classdef vehicle < dynamicprops
    
    %VEHICLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numSurfaces
        numTurbines
        numTethers
        centOfBuoy
        aeroRefPt
        mass
        inertia
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
                obj.(p.Results.SurfaceNames{ii}) = vehicle.aeroSurf;
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
        
    end
end

