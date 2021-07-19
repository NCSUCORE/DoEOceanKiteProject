classdef poolGndStn < dynamicprops
    
    %STATION Class definition for a ground station
    
    properties (SetAccess = private)
        mass
        poolLength
        preTension
        latGuySpan
        longGuySpan
        guyModulus
        guyDiam
        inertia
        dampCoeff
        initAngPos
        initAngVel
        initPos
        initVel
        towSpeed
    end
    
    properties (Dependent)
        guyArea
        guyHookes
    end
    methods
        function obj = poolGndStn
            %VEHICLE Construct an instance of this class
            obj.mass                        = SIM.parameter('Unit','kg');
            obj.poolLength                  = SIM.parameter('Unit','m','Value',22.86);
            obj.inertia                     = SIM.parameter('Unit','kg*m^2');
            obj.dampCoeff                   = SIM.parameter('Unit','(N*m)/(rad/s)');
            obj.initAngPos                  = SIM.parameter('Unit','rad');
            obj.initAngVel                  = SIM.parameter('Unit','rad/s');
            obj.initPos                     = SIM.parameter('Unit','m');
            obj.initVel                     = SIM.parameter('Unit','m/s');
            obj.preTension                  = SIM.parameter('Unit','N');
            obj.latGuySpan                  = SIM.parameter('Unit','m','Value',1);
            obj.longGuySpan                 = SIM.parameter('Unit','m','Value',1);
            obj.guyModulus                  = SIM.parameter('Unit','N/(m^2)','Value',50e9);
            obj.guyDiam                     = SIM.parameter('Unit','m','Value',0.01);
            obj.towSpeed                    = SIM.parameter('Unit','m/s');
        end        
        
        % Function to build the ground station (add tether attachment
        % properties)
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
                obj.(p.Results.TetherNames{ii}) = OCT.thrAttch;
            end
        end
        
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
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
            addParameter(p,'InitAngPos',0,@isnumeric)
            addParameter(p,'InitAngVel',0,@isnumeric)
            parse(p,varargin{:})
            obj.initAngPos.Value    = p.Results.InitPos;
            obj.initAngVel.Value    = p.Results.InitVel;
        end
        
        function val = get.guyArea(obj)
            val = SIM.parameter('Value',pi*obj.guyDiam.Value^2/4,'Unit','m^2',...
                'Description','Guy Wire Area');
        end
        
        function val = get.guyHookes(obj)
            val = SIM.parameter('Value',obj.guyModulus.Value*obj.guyArea.Value/obj.poolLength.Value,...
                'Unit','N/m');
        end
    end
end

