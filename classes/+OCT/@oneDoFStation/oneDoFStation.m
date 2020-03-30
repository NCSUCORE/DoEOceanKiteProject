classdef oneDoFStation < dynamicprops
    
    %STATION Class definition for a ground station
    
    properties (SetAccess = private)
        numTethers
        inertia
        dampCoeff
        initAngPos
        initAngVel
        freeSpnEnbl
        posVec
        anchThrs
        lumpedMassPositionMatrixBdy
    end
    
    methods
        function obj = oneDoFStation
            %VEHICLE Construct an instance of this class
            obj.numTethers                  = SIM.parameter('NoScale',true);
            obj.inertia                     = SIM.parameter('Unit','kg*m^2');
            obj.dampCoeff                   = SIM.parameter('Unit','(N*m)/(rad/s)');
            obj.initAngPos                  = SIM.parameter('Unit','rad');
            obj.initAngVel                  = SIM.parameter('Unit','rad/s');
            obj.freeSpnEnbl                 = SIM.parameter('NoScale',true);
            obj.posVec                      = SIM.parameter('Unit','m');
            obj.lumpedMassPositionMatrixBdy = SIM.parameter('Unit','m');
            
            obj.anchThrs = OCT.tethers;
        end
        function setNumTethers(obj,val,unit)
            obj.numTethers.setValue(val,unit);
        end
        function setInertia(obj,val,unit)
            obj.inertia.setValue(val,unit);
        end
        function setDampCoeff(obj,val,unit)
            obj.dampCoeff.setValue(val,unit);
        end
        function setInitAngPos(obj,val,unit)
            obj.initAngPos.setValue(val,unit);
        end
        function setInitAngVel(obj,val,unit)
            obj.initAngVel.setValue(val,unit);
        end
        function setFreeSpnEnbl(obj,val,unit)
            obj.freeSpnEnbl.setValue(val,unit);
        end
        function setPosVec(obj,val,unit)
            obj.posVec.setValue(val,unit);
        end
        function setLumpedMassPositionMatrixBdy(obj,val,unit)
            obj.lumpedMassPositionMatrixBdy.setValue(val,unit);
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
    end
end

