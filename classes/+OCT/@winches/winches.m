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
        function obj = setTetherInitLength(obj,vhcl,env,thr)
            % calculate total external forces except tethers
            F_grav = vhcl.mass.Value*env.gravAccel.Value*[0;0;-1];
            F_buoy =  env.water.density.Value*vhcl.volume.Value*...
                env.gravAccel.Value*[0;0;1];
            
            % calculate lift forces for wing and HS, ignore VS
            Vrel = env.water.flowVec.Value - rotation_sequence(vhcl.initEulAng.Value)*vhcl.initVelVecBdy.Value;
            q = 0.5*env.water.density.Value*(norm(Vrel))^2;
            aeroSurfs = vhcl.getPropsByClass('OCT.aeroSurf');
            F_aero = [0;0;0];
            for ii = 1:3
                Sref = vhcl.(aeroSurfs{ii}).refArea.Value;
                CL(ii) = interp1(vhcl.(aeroSurfs{ii}).alpha.Value,...
                    vhcl.(aeroSurfs{ii}).CL.Value,...
                    (180/pi)*vhcl.initEulAng.Value(2));
                CD(ii) = interp1(vhcl.(aeroSurfs{ii}).alpha.Value,...
                    vhcl.(aeroSurfs{ii}).CL.Value,...
                    (180/pi)*vhcl.initEulAng.Value(2));
                F_aero = F_aero + q*Sref*[CD(ii);0;CL(ii)];
            end
            
            sum_F = norm(F_grav + F_buoy + F_aero);
            
            switch obj.numWinches.Value
                case 1
                    L = norm(thr.tether1.initAirNodePos.Value - ...
                        thr.tether1.initGndNodePos.Value);
                    delta_L = sum_F/(L*thr.tether1.youngsMod.Value*...
                        (pi/4)*thr.tether1.diameter.Value^2);
                    
                    obj.winch1.initLength.setValue(L + delta_L,obj.winch1.initLength.Unit);
                    obj.winch1.initLength.setValue(norm(vhcl.initPosVecGnd.Value),'m')
                case 3
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

