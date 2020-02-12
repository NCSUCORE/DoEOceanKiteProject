classdef sixDoFStation < dynamicprops
    
    %SIXDOFSTATION Class definition for the floating, six DoF gnd station
    
    properties (SetAccess = private)
        % Inertial properties
        mass
        inertia
        
        % Buoyancy properties
        volume
        lumpedMassNetBouyancyForce
        gravForcePerLM
        cdX
        cdY
        cdZ
        aMX
        aMY
        aMZ
        
        %lumped mass and shaped properties
        lumpedMassPositionMatrixBdy
        lumpedMassSphereRadius
        
        
        angMatExt
        zMatExt
        rMatExt
        
        angMatT
        zMatT
        rMatT
        
        
        angMatB
        zMatB
        rMatB
        
        
        angMatInt
        zMatInt
        rMatInt
        
        cylRad
        cylTotH
        angSpac
        heightSpac
        lumpedMassNormalVecMat
        lumpedMassAreaMat
        
        % Initial conditions
        initPosVecGnd
        initVelVecBdy
        initEulAng
        initAngVelVec
        initAnchTetherLength
        
        
        %kite tether
        numTethers
        
        % Anchor tethers
        anchThrs
        
        
        % BS Params forced by the fact that we use the same 6dof dynamics
        % model
        
        addedMass
        addedInertia
        
        
    end
    
    methods
        function obj = sixDoFStation
            % Inertial properties
            obj.mass                        = SIM.parameter('Unit','kg','Description','Total mass of system');
            obj.inertia               = SIM.parameter('Unit','kg*m^2','Description','3x3 inertia matrix');
            
            % Buoyancy properties
            obj.volume                      = SIM.parameter('Unit','m^3','Description','Total volume used in buoyancy calculation');
            obj.lumpedMassPositionMatrixBdy = SIM.parameter('Unit','m','Description','lumped mass position matrix');
            obj.lumpedMassSphereRadius      = SIM.parameter('Unit','m','Description','lumped mass sphere radius');
            obj.lumpedMassNetBouyancyForce  = SIM.parameter('Unit','N','Description','lumped mass bouyancy force');
            obj.gravForcePerLM              = SIM.parameter('Unit','N','Description','lumped mass gravity force');
            
            % Initial conditions
            obj.initPosVecGnd                     = SIM.parameter('Unit','m','Description','Initial position of the station in the ground frame.');
            obj.initVelVecBdy                     = SIM.parameter('Unit','m/s','Description','Initial velocity of the station in the ground frame.');
            obj.initEulAng                  = SIM.parameter('Unit','rad','Description','Initial Euler angles of the station in the ground frame, radians.');
            obj.initAngVelVec                  = SIM.parameter('Unit','rad/s','Description','Initial angular velocity of the station in the ground frame, radians per sec');
            obj.initAnchTetherLength        = SIM.parameter('Unit','m','Description','Unstretched Tether Length');
            
            
            % added mass and drag coefficants
            obj.cdX                         = SIM.parameter('Unit','','Description','lumped mass drag coefficiant x direction');
            obj.cdY                         = SIM.parameter('Unit','','Description','lumped mass drag coefficiant y direction');
            obj.cdZ                         = SIM.parameter('Unit','','Description','lumped mass drag coefficiant z direction');
            obj.aMX                         = SIM.parameter('Unit','','Description','lumped mass added mass coefficiant x direction');
            obj.aMY                         = SIM.parameter('Unit','','Description','lumped mass added mass coefficiant y direction');
            obj.aMZ                         = SIM.parameter('Unit','','Description','lumped mass added mass coefficiant z direction');
            
            %geometry of ground station coordinates
            obj.angMatExt                   = SIM.parameter('Unit','rad','Description','the angle on a cylinder that the exterior lumped masses lie');
            obj.zMatExt                     = SIM.parameter('Unit','m','Description','the z coordinate on a cylinder that the exterior lumped masses lie');
            obj.rMatExt                     = SIM.parameter('Unit','m','Description','the radius on a cylinder that the exterior lumped masses lie');
            
            obj.angMatT                    = SIM.parameter('Unit','rad','Description','the angle on a cylinder that the top  lumped masses lie');
            obj.zMatT                      = SIM.parameter('Unit','m','Description','the z coordinate on a cylinder that the top lumped masses lie');
            obj.rMatT                      = SIM.parameter('Unit','m','Description','the radius on a cylinder that the top lumped masses lie');
            
            obj.angMatB                    = SIM.parameter('Unit','rad','Description','the angle on a cylinder that the bottom lumped masses lie');
            obj.zMatB                      = SIM.parameter('Unit','m','Description','the z coordinate on a cylinder that the bottom lumped masses lie');
            obj.rMatB                      = SIM.parameter('Unit','m','Description','the radius on a cylinder that the top bottom masses lie');
            
            obj.angMatInt                   = SIM.parameter('Unit','rad','Description','the angle on a cylinder that the interior lumped masses lie');
            obj.zMatInt                     = SIM.parameter('Unit','m','Description','the z coordinate on a cylinder that the interior lumped masses lie');
            obj.rMatInt                     = SIM.parameter('Unit','m','Description','the radius on a cylinder that the interior lumped masses lie');
            
            obj.cylRad                      = SIM.parameter('Unit','m','Description','the radius of the cylinder');
            obj.cylTotH                     = SIM.parameter('Unit','m','Description','the cylinder total height');
            obj.angSpac                     = SIM.parameter('Unit','rad','Description','the lumped Mass Angle Spacing');
            obj.heightSpac                  = SIM.parameter('Unit','m','Description','the gnd station height spacing');
            obj.lumpedMassNormalVecMat      = SIM.parameter('Unit','','Description','normal vectors of the area of each lumped mass');
            obj.lumpedMassAreaMat           = SIM.parameter('Unit','m^2','Description','area of each lumped mass');
            
            %number of tethers from GS to KITE
            obj.numTethers                  = SIM.parameter('Unit','','Description','number of tethers from GS to KITE');
            
            obj.addedMass                     = SIM.parameter('Unit','');
            obj.addedInertia                  = SIM.parameter('Unit','');
            
            % Anchor tethers
            obj.anchThrs = OCT.tethers;
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
        
        
        
        % Method to add tether attachment points
        function obj = addThrAttch(obj,Name,initPosVecGnd)
            addprop(obj,Name);
            obj.(Name) = OCT.thrAttch;
            obj.(Name).setPosVec(initPosVecGnd,'m');
        end
        
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        
        % Setters
        % Inertial properties
        function setMass(obj,val,unit)
            obj.mass.setValue(val,unit);
        end
        
        function setAddedMass(obj,val,unit)
            obj.addedMass.setValue(val,unit);
        end
        
        function setAddedInertia(obj,val,unit)
            obj.addedInertia.setValue(val,unit);
        end
        
        function setInertia(obj,val,unit)
            obj.inertia.setValue(val,unit);
        end
        % Buoyancy properties
        function setVolume(obj,val,unit)
            obj.volume.setValue(val,unit);
        end
        
        function setLumpedMassSphereRadius(obj,val,unit)
            obj.lumpedMassSphereRadius.setValue(val,unit);
        end
        
        function setLumpedMassPositionMatrixBdy(obj,val,unit)
            obj.lumpedMassPositionMatrixBdy.setValue(val,unit);
        end
        
        function setLumpedMassNetBouyancyForce(obj,val,unit)
            obj.lumpedMassNetBouyancyForce.setValue(val,unit)
        end
        
        function setInitAnchTetherLength(obj,val,unit)
            obj.initAnchTetherLength.setValue(val,unit)
        end
        
        function setNumTethers(obj,val,unit)
            obj.numTethers.setValue(val,unit)
        end
        
        function setCdX (obj,val,unit)
            obj.cdX.setValue(val,unit)
        end
        
        function setCdY (obj,val,unit)
            obj.cdY.setValue(val,unit)
        end
        
        function setCdZ (obj,val,unit)
            obj.cdZ.setValue(val,unit)
        end
        
        function setAMX(obj,val,unit)
            obj.aMX.setValue(val,unit)
        end
        
        function setAMY(obj,val,unit)
            obj.aMY.setValue(val,unit)
        end
        
        function setAMZ(obj,val,unit)
            obj.aMZ.setValue(val,unit)
        end
        
        function setGravForcePerLM(obj,val,unit)
            obj.gravForcePerLM.setValue(val,unit)
        end
        
        function setAngMatExt(obj,val,unit)
            obj.angMatExt.setValue(val,unit)
        end
        
        function setangMatT(obj,val,unit)
            obj.angMatT.setValue(val,unit)
        end
        
        function setangMatB(obj,val,unit)
            obj.angMatB.setValue(val,unit)
        end
        
        function setAngMatInt(obj,val,unit)
            obj.angMatInt.setValue(val,unit)
        end
        
        function setZMatExt(obj,val,unit)
            obj.zMatExt.setValue(val,unit)
        end
        
        function setzMatT(obj,val,unit)
            obj.zMatT.setValue(val,unit)
        end
        
        function setZMatB(obj,val,unit)
            obj.zMatB.setValue(val,unit)
        end
        
        function setZMatInt(obj,val,unit)
            obj.zMatInt.setValue(val,unit)
        end
        
        function setRMatExt(obj,val,unit)
            obj.rMatExt.setValue(val,unit)
        end
        
        function setRMatT(obj,val,unit)
            obj.rMatT.setValue(val,unit)
        end
        
        function setRMatB(obj,val,unit)
            obj.rMatB.setValue(val,unit)
        end
        
        function setRMatInt(obj,val,unit)
            obj.rMatInt.setValue(val,unit)
        end
        
        function setCylRad(obj,val,unit)
            obj.cylRad.setValue(val,unit)
        end
        
        function setCylTotH(obj,val,unit)
            obj.cylTotH.setValue(val,unit)
        end
        
        function setAngSpac (obj,val,unit)
            obj.angSpac.setValue(val,unit)
        end
        
        function setHeightSpac(obj,val,unit)
            obj.heightSpac.setValue(val,unit)
        end
        
        function setLumpedMassNormalVecMat(obj,val,unit)
            obj.lumpedMassNormalVecMat.setValue(val,unit)
        end
        
        function setLumpedMassAreaMat(obj,val,unit)
            obj.lumpedMassAreaMat.setValue(val,unit)
        end
        
        % getters
        function val = get.cylTotH(obj)
            val = obj.cylTotH;
            height = max(obj.zMatExt.Value)-min(obj.zMatExt.Value);
            val.setValue(height,obj.zMatExt.Unit)
        end
        
        
        
        function bouyancy(obj)
            numLM     =  numel(obj.lumpedMassPositionMatrixBdy.Value)/3;
            gravForce = (obj.mass.Value/numLM)*9.81;
            bouyForce = (obj.volume.Value/numLM)*1000*9.81;
            obj.setLumpedMassNetBouyancyForce([0,0,bouyForce],'N')
            obj.setGravForcePerLM([0,0,-gravForce],'N')
        end
        
        function obj = buildCylStation(obj)
            %%
            % Concatination to make lumped mass matrix
            allThetas = [obj.angMatExt.Value,obj.angMatT.Value,obj.angMatB.Value, obj.angMatInt.Value];
            allZMat = [obj.zMatExt.Value,obj.zMatT.Value,obj.zMatB.Value,obj.zMatInt.Value];
            allRMat = [obj.rMatExt.Value,obj.rMatT.Value,obj.rMatB.Value,obj.rMatInt.Value];
            
            
            [X,Y,Z] = pol2cart(allThetas,allRMat,allZMat);
            lumpedMassPointsMatrix = [X;Y;Z];
            obj.setLumpedMassPositionMatrixBdy(lumpedMassPointsMatrix,'m');
            
            %%
            % normal vector calculation per lumped mass ext
            
            [xNEX,yNEX,zNEX]= pol2cart(obj.angMatExt.Value,ones(1,numel(obj.angMatExt.Value)),zeros(1,numel(obj.angMatExt.Value)));
            normalVecExt = [xNEX;yNEX;zNEX];
            
            
            % normal vector calculation per lumped mass top
            normalVecT = [zeros(1,numel(obj.angMatT.Value));zeros(1,numel(obj.angMatT.Value));ones(1,numel(obj.angMatT.Value))];
            
            
            % normal vector calculation per lumped mass bottom
            normalVecB = [zeros(1,numel(obj.angMatB.Value));zeros(1,numel(obj.angMatB.Value));-1*ones(1,numel(obj.angMatB.Value))];
            
            % normal vector for interior doesnt matter so it is zero for
            % all
            
            normalVecInt = zeros(3,numel(obj.rMatInt.Value));
            
            %setting the normal vector mat
            obj.setLumpedMassNormalVecMat([normalVecExt,normalVecT,normalVecB,normalVecInt],'');
            
            %% Areas
            % Front and Side Area
            d = 2*(obj.cylRad.Value).*sin(obj.angSpac.Value);
            q = sqrt((obj.cylRad.Value^2) - (d/2)^2);
            frontArea = obj.heightSpac.Value*d;
            sideArea  = (obj.cylRad.Value - q)*(obj.heightSpac.Value);
            
            areaExt = [frontArea*ones(1,numel(obj.angMatExt.Value));sideArea*ones(1,numel(obj.angMatExt.Value));zeros(1,numel(obj.angMatExt.Value))];
            areaInt =  zeros(3,numel(obj.rMatInt.Value));
            areaT   = ((pi*(obj.cylRad.Value)^2)/(numel(obj.angMatB.Value)))*[zeros(1,numel(obj.angMatB.Value));zeros(1,numel(obj.angMatB.Value));-1*ones(1,numel(obj.angMatB.Value))];
            areaB   = ((pi*(obj.cylRad.Value)^2)/(numel(obj.angMatB.Value)))*[zeros(1,numel(obj.angMatB.Value));zeros(1,numel(obj.angMatB.Value));-1*ones(1,numel(obj.angMatB.Value))];
            obj.setLumpedMassAreaMat([areaExt,areaInt,areaT,areaB],'m^2')
            
            
            
            
            
            
            
            
            
            
            
        end
        % Initial conditions
        function setInitPosVecGnd(obj,val,unit)
            obj.initPosVecGnd.setValue(val,unit);
        end
        function setInitVelVecBdy(obj,val,unit)
            obj.initVelVecBdy.setValue(val,unit);
        end
        function setInitEulAng(obj,val,unit)
            obj.initEulAng.setValue(val,unit);
        end
        function setInitAngVelVec(obj,val,unit)
            obj.initAngVelVec.setValue(val,unit);
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
        function val = struct(obj,className,prefix)
            % Function returns all properties of the specified class in a
            % 1xN struct useable in a for loop in simulink
            % Example classnames: OCT.turb, OCT.aeroSurf
            props = sort(obj.getPropsByClass(className));
            props = props(contains(props,prefix,'IgnoreCase',true)); % Sort on the ones containing the prefix
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
        
        function plotLumps(obj)
            
            scatter3(obj.lumpedMassPositionMatrixBdy.Value(1,:),obj.lumpedMassPositionMatrixBdy.Value(2,:),obj.lumpedMassPositionMatrixBdy.Value(3,:))
            hold on
%             plot3(obj.lumpedMassPositionMatrixBdy.Value(1,:),obj.lumpedMassPositionMatrixBdy.Value(2,:),obj.lumpedMassPositionMatrixBdy.Value(3,:))
        end
        
        function plotGndStnLoc(obj)
            
            
            p1 =  obj.inrThrAttchPt1.posVec.Value;
            
            p2 =  obj.inrThrAttchPt2.posVec.Value;
            
            p3 =  obj.inrThrAttchPt3.posVec.Value;
            
            
            p1b =  obj.pltThrAttchPt1.posVec.Value + obj.initPosVec.Value(:);
            
            p2b =  obj.pltThrAttchPt2.posVec.Value + obj.initPosVec.Value(:);
            
            p3b =  obj.pltThrAttchPt3.posVec.Value + obj.initPosVec.Value(:);
            
            x = [ p1(1),p2(1),p3(1),p1b(1),p2b(1),p3b(1)];
            y = [ p1(2),p2(2),p3(2),p1b(2),p2b(2),p3b(2)];
            z = [ p1(3),p2(3),p3(3),p1b(3),p2b(3),p3b(3)];
            scatter3(x,y,z)
        end
        
        function tdists = calcInitTetherLen(obj)
            
            %ground points
            p1g =  obj.inrThrAttchPt1.posVec.Value;
            
            p2g =  obj.inrThrAttchPt2.posVec.Value;
            
            p3g =  obj.inrThrAttchPt3.posVec.Value;
            
            %body initially lined up with gnd frame. body points
            p1b =  obj.pltThrAttchPt1.posVec.Value + obj.initPosVecGnd.Value(:);
            
            p2b =  obj.pltThrAttchPt2.posVec.Value + obj.initPosVecGnd.Value(:);
            
            p3b =  obj.pltThrAttchPt3.posVec.Value + obj.initPosVecGnd.Value(:);
            
            
            t1Dist =  sqrt(sum(((p1b - p1g)).^2));
            t2Dist =  sqrt(sum(((p2b - p2g)).^2));
            t3Dist =  sqrt(sum(((p3b - p3g)).^2));
            
%             disp(t1Dist)
%             disp(t2Dist)
%             disp(t3Dist)
            tdists = [ t1Dist ,t2Dist,t3Dist];
        end
        
    end
end

