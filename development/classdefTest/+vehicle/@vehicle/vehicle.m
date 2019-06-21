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
            obj.centOfBuoy  = vehicle.param;
            obj.mass        = vehicle.param;
            obj.inertia     = vehicle.param;
        end
        
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
            
            for ii = 1:obj.numSurfaces.Value
                obj.addprop(p.Results.SurfaceNames{ii});
                obj.(p.Results.SurfaceNames{ii}) = vehicle.aeroSurf;
            end
            for ii = 1:obj.numTethers.Value
               obj.addprop(p.Results.TetherNames{ii});
               obj.(p.Results.TetherNames{ii}) = vehicle.thrAttch;
            end
        end
    end
end

