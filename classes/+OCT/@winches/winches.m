classdef winches < dynamicprops
    %WINCHES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        numWinches
    end
    
    methods
        
        function obj = winches
            obj.numWinches = SIM.parameter('NoScale',true);
        end
        
        function obj = setNumWinches(obj,val,units)
            obj.numWinches.setValue(val,units);
        end
        
        function obj = build(obj,varargin)
            defNames = {};
            for ii = 1:obj.numWinches.Value
                defNames{ii} = sprintf('winch%d',ii);
            end
            p = inputParser;
            addParameter(p,'WinchNames',defNames,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            parse(p,varargin{:})
            % Create winches
            for ii = 1:obj.numWinches.Value
                obj.addprop(p.Results.WinchNames{ii});
                obj.(p.Results.WinchNames{ii}) = OCT.winch;
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
                    parameter = obj.(props{ii}).(subProps{jj});
                    val(ii).(subProps{jj}) = parameter.Value;
                end
            end
        end
        
        function val = getPropsByClass(obj,className)
            props = properties(obj);
            val = {};
            for ii = 1:length(props)
                if isa(obj.(props{ii}),className)
                    val{end+1} = props{ii};
                end
            end
        end
        
        % set intial length
        function obj = setTetherInitLength(obj,vhcl,initGndStnPos,env,thr,flowVelocity)
            % calculate total external forces except tethers
            F_grav = vhcl.mass.Value*env.gravAccel.Value*[0;0;-1];
            F_buoy = env.water.density.Value*vhcl.volume.Value*...
                env.gravAccel.Value*[0;0;1];
            
            % calculate lift forces for wing and HS, ignore VS
            [RBdy2Gnd,RGnd2Bdy] = rotation_sequence(vhcl.initEulAng.Value);
%             RBdy2Gnd = rotation_sequence([0 10 0]*pi/180);
            
            YBdyGnd = RBdy2Gnd(:,2);
            ZBdyGnd = RBdy2Gnd(:,3);
            
            % Plotting script to check the body axes
%             XBdyGnd = RBdy2Gnd(:,1);
%             plot3([0 XBdyGnd(1)],[0 XBdyGnd(2)],[0 XBdyGnd(3)],'DisplayName','x')
%             hold on
%             grid on
%             plot3([0 YBdyGnd(1)],[0 YBdyGnd(2)],[0 YBdyGnd(3)],'DisplayName','y')
%             plot3([0 ZBdyGnd(1)],[0 ZBdyGnd(2)],[0 ZBdyGnd(3)],'DisplayName','z')
%             daspect([1 1 1])
%             xlabel('x')
%             ylabel('y')
%             zlabel('z')
%             legend
            
            VRelGnd = padarray(flowVelocity(:),numel(vhcl.initVelVecBdy.Value)-numel(flowVelocity),0,'post') - RBdy2Gnd*vhcl.initVelVecBdy.Value(:);
            URelGnd = VRelGnd./norm(VRelGnd);
            VRelBdy = RGnd2Bdy*VRelGnd;
            URelBdy = VRelBdy./norm(VRelBdy);
            
            
            % Calculate the drag direction in the ground frame
            UDragGnd = URelGnd;
            UDragBdy = URelBdy;
            % Calculate angles of attack for all surfaces
            alphaNormal = atan2d(UDragBdy(3),UDragBdy(1));
            alphaVStab  = atan2d(UDragBdy(2),UDragBdy(1));
            
            % Calculate lift directions by rotating body axis by alpha's
            % https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
            % Calculate the lift direction in the ground frame for the "Normal" surfaces
            % Rotate body z about -body y by alpha
            ULiftGndNormal = ZBdyGnd*cosd(alphaNormal)...
                + cross(-YBdyGnd,ZBdyGnd)*sind(alphaNormal)...
                +   dot(-YBdyGnd,ZBdyGnd)*(1-cosd(alphaNormal));
            % Calculate the lift direction in the ground frame for the vertical stabilizer
            % Rotate body y about z by alpha
            ULiftGndvStab = YBdyGnd*cosd(alphaVStab)...
                + cross(ZBdyGnd,YBdyGnd)*sind(alphaVStab)...
                +   dot(ZBdyGnd,YBdyGnd)*(1-cosd(alphaVStab));
            
            % Calculate the dynamic pressure
            q = 0.5*env.water.density.Value*(norm(VRelBdy))^2;
            
            % Get list of aerodynamic surfaces in the vehicle
            aeroSurfs = vhcl.getPropsByClass('OCT.aeroSurf');
            normSurfs = aeroSurfs(~contains(aeroSurfs,'vStab'));
            vStabSurf = aeroSurfs(contains(aeroSurfs,'vStab'));
            
            % Calculate the forces from the "normal" surfaces
            F_aero = [0;0;0];
            for ii = 1:numel(normSurfs)
                Sref = vhcl.(normSurfs{ii}).refArea.Value;
                CL = interp1(...
                    vhcl.(normSurfs{ii}).alpha.Value,...
                    vhcl.(normSurfs{ii}).CL.Value,...
                    min(max(alphaNormal,min(vhcl.(normSurfs{ii}).alpha.Value)),max(vhcl.(normSurfs{ii}).alpha.Value)));
                CD = interp1(vhcl.(normSurfs{ii}).alpha.Value,...
                    vhcl.(normSurfs{ii}).CL.Value,...
                    min(max(alphaNormal,min(vhcl.(normSurfs{ii}).alpha.Value)),max(vhcl.(normSurfs{ii}).alpha.Value)));
                F_aero = F_aero + q*Sref*(CL*ULiftGndNormal(:) + CD*UDragGnd(:));
            end
            
            % Calculate surfaces from the vertical stabilizer
            CL = interp1(...
                vhcl.(vStabSurf{1}).alpha.Value,...
                vhcl.(vStabSurf{1}).CL.Value,...
                alphaVStab);
            CD = interp1(vhcl.(vStabSurf{1}).alpha.Value,...
                vhcl.(vStabSurf{1}).CL.Value,...
                alphaVStab);
            F_aero = F_aero + q*vhcl.(vStabSurf{1}).refArea.Value*(CL*ULiftGndvStab+CD*UDragGnd);
            
            % Calculate component in the direction of the tether
            FNet = F_grav + F_buoy + F_aero;
            dirVec = (vhcl.initPosVecGnd.Value(:)-initGndStnPos(:))./norm(vhcl.initPosVecGnd.Value(:)-initGndStnPos(:));
            sum_F = dot(FNet,dirVec);
            
            switch obj.numWinches.Value
                case 1
                    L = norm(thr.tether1.initAirNodePos.Value - ...
                        thr.tether1.initGndNodePos.Value);
                    delta_L = -(L*sum_F)/(thr.tether1.youngsMod.Value*...
                        (pi/4)*thr.tether1.diameter.Value^2);
                    
                   
                    obj.winch1.initLength.setValue(L+delta_L/2,'m')
                case 3
%                     error('Init tether length calculation has been changed and this portion of the code is not updated')
                    L1 = norm(thr.tether1.initAirNodePos.Value - ...
                        thr.tether1.initGndNodePos.Value);
                    delta_L1 = (sum_F/4)/(L1*thr.tether1.youngsMod.Value*...
                        (pi/4)*thr.tether1.diameter.Value^2);
                    
                    obj.winch1.initLength.setValue(L1 + delta_L1,obj.winch1.initLength.Unit);
                    % winch 2
                    L2 = norm(thr.tether2.initAirNodePos.Value - ...
                        thr.tether2.initGndNodePos.Value);
                    delta_L2 = (sum_F/2)/(L2*thr.tether2.youngsMod.Value*...
                        (pi/4)*thr.tether2.diameter.Value^2);
                    
                    obj.winch2.initLength.setValue(L2 + delta_L2,obj.winch2.initLength.Unit);
                    % winch 3
                    L3 = norm(thr.tether3.initAirNodePos.Value - ...
                        thr.tether3.initGndNodePos.Value);
                    delta_L3 = (sum_F/4)/(L3*thr.tether3.youngsMod.Value*...
                        (pi/4)*thr.tether3.diameter.Value^2);
                    
                    obj.winch3.initLength.setValue(L3 + delta_L3,obj.winch3.initLength.Unit);
                    
                otherwise
                    error(['Method not progerammed for %d winches.',thr.numWinches.Value])
            end
            
        end
        
    end
end

