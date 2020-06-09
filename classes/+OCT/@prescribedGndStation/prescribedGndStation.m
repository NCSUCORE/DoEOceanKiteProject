classdef prescribedGndStation < dynamicprops
    
    %STATION Class definition for a ground station
    
    properties (SetAccess = private)
        numTethers
        inertia
        dampCoeff
        eulerAngVec
        freeSpnEnbl
        posVecTrajectory
        anchThrs
        lumpedMassPositionMatrixBdy
    end
    
    properties (Dependent)
        initPosVec
        velVecTrajectory
    end
    
    methods
        function obj = prescribedGndStation
            %VEHICLE Construct an instance of this class
            obj.numTethers                  = SIM.parameter('NoScale',true);
            obj.inertia                     = SIM.parameter('Unit','kg*m^2');
            obj.dampCoeff                   = SIM.parameter('Unit','(N*m)/(rad/s)');
            obj.eulerAngVec                 = SIM.parameter('Unit','rad');
            obj.freeSpnEnbl                 = SIM.parameter('NoScale',true);
            %obj.initPosVec                  = SIM.parameter('Unit','m');
            obj.posVecTrajectory            = SIM.parameter('Unit','m','Description','Timesignal for position vector over time');
            %obj.velVecTrajectory            = SIM.parameter('Unit','m/s','Description','Timesignal for velocity vector over time');
            obj.lumpedMassPositionMatrixBdy = SIM.parameter('Unit','m');
            
            obj.anchThrs = OCT.tethers;
        end
        
        % Setters
        
        function setNumTethers(obj,val,unit)
            obj.numTethers.setValue(val,unit);
        end
        function setInertia(obj,val,unit)
            obj.inertia.setValue(val,unit);
        end
        function setDampCoeff(obj,val,unit)
            obj.dampCoeff.setValue(val,unit);
        end
        function setEulerAngVec(obj,val,unit)
            obj.eulerAngVec.setValue(val,unit);
        end
        function setFreeSpnEnbl(obj,val,unit)
            obj.freeSpnEnbl.setValue(val,unit);
        end
        function setPosVecTrajectory(obj,val,unit)
            obj.posVecTrajectory.setValue(val,unit);
        end
        function setLumpedMassPositionMatrixBdy(obj,val,unit)
            obj.lumpedMassPositionMatrixBdy.setValue(val,unit);
        end
        
        % Getters
        function val = get.initPosVec(obj,varargin)
            posVal = obj.posVecTrajectory.Value.getsampleusingtime(0).Data;
            val = SIM.parameter('Value',posVal,'Unit','m');
        end    
        function val = get.velVecTrajectory(obj,varargin)
            velVal = obj.posVecTrajectory.Value.diff;
            val = SIM.parameter('Value',velVal,'Unit','m/s');
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
%         function obj = setICs(obj,varargin)
%             p = inputParser;
%             addParameter(p,'InitAngPos',0,@isnumeric)
%             addParameter(p,'InitAngVel',0,@isnumeric)
%             parse(p,varargin{:})
%             obj.initAngPos.Value    = p.Results.InitPos;
%             obj.initAngVel.Value    = p.Results.InitVel;
%         end
    end
end

