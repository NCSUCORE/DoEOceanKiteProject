classdef oneDoFStation < dynamicprops
    
    %ONEDOFSTATION Class definition for a "fixed" ground station that can
    %rotate about it's z axis (or it can be locked so that it doesn't
    %rotate.
    
    properties (SetAccess = private)
        numTethers
        inertia
        dampCoeff
        initAngPos
        initAngVel
        freeSpnEnbl
        posVec
    end
    
    properties (Hidden)
        % structs tracking the tether attachment point
        % https://www.mathworks.com/matlabcentral/answers/48831-set-methods-for-dynamic-properties-with-unknown-names
        propNames = {};
        propVals  = {};
    end
    methods
        function obj = oneDoFStation
            obj.numTethers  = SIM.parameter('NoScale',true);
            obj.inertia     = SIM.parameter('Unit','kg*m^2','Description','Izz rotational inertia about about platform z axis');
            obj.dampCoeff   = SIM.parameter('Unit','(N*m)/(rad/s)','Description','Rotational damping coefficient of platform');
            obj.initAngPos  = SIM.parameter('Unit','rad','Description','Initial angular position');
            obj.initAngVel  = SIM.parameter('Unit','rad/s','Description','Initial angular velocity');
            obj.freeSpnEnbl = SIM.parameter('NoScale',true,'Description','Boolean variable, true = free spinning, false = no rotation');
            obj.posVec      = SIM.parameter('Unit','m','Description','Position relative to ground coordinate origin');
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
        % Function to build the ground station (add tether attachment
        % properties)
        function obj = build(obj)
            for ii = 1:obj.numTethers.Value
                prop = obj.addprop(sprintf('thrAttch%d',ii));
                prop.GetMethod = @(obj)getThrAttchPt(obj,sprintf('thrAttch%d',ii));
                obj.(sprintf('thrAttch%d',ii)) = OCT.thrAttch;
                obj.propNames{ii} = sprintf('thrAttch%d',ii);
                obj.propVals{ii} = OCT.thrAttch;
            end
        end
        
        function val = getThrAttchPt(obj,propName)
            val = obj.propVals{find(strcmp(obj.propNames,propName))};
            if ~isempty(val.posVec.Value)  && ~isempty(obj.initAngVel.Value)
                val.setVelVec(cross([0 0 obj.initAngVel.Value],val.posVec.Value),'m/s');
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
                error('No properties of that type')
            end
            subProps = properties(obj.(props{1}));
            for ii = 1:length(props)
                for jj = 1:numel(subProps)
                    if jj == 2
                       x =1 ;
                    end
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

