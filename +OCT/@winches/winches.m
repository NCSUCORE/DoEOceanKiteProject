classdef winches < dynamicprops
    %WINCHES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numWinches
    end
    
    methods
        
        function obj = winches
            obj.numWinches = OCT.param('IgnoreScaling',true);
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
        function obj = scale(obj,scaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(scaleFactor);
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
                    param = obj.(props{ii}).(subProps{jj});
                    val(ii).(subProps{jj}) = param.Value;
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
            Vrel = env.water.velVec.Value - vhcl.initVelVecGnd.Value;
            q = 0.5*env.water.density.Value*(norm(Vrel))^2;
            Sref = vhcl.aeroSurf1.refArea.Value;
            F_aero = [0;0;0];
            for ii = 1:3
                CLm(ii) = max(vhcl.(strcat('aeroSurf',num2str(ii))).CL.Value);
                F_aero = F_aero + q*Sref*[0;0;CLm(ii)];
            end
            
            sum_F = norm(F_grav + F_buoy + F_aero);
            
            switch thr.numTethers.Value
                case 1
                    thr.tether1.diameter.Value = sqrt((4*sum_F)/...
                        (pi*thr.maxPercentageElongation*thr.tether1.youngsMod.Value));
                case 3
                    thr.tether1.diameter.Value = sqrt((4*sum_F/4)/...
                        (pi*thr.maxPercentageElongation*thr.tether1.youngsMod.Value));
                    thr.tether2.diameter.Value = sqrt((4*sum_F/2)/...
                        (pi*thr.maxPercentageElongation*thr.tether2.youngsMod.Value));
                    thr.tether3.diameter.Value = sqrt((4*sum_F/4)/...
                        (pi*thr.maxPercentageElongation*thr.tether3.youngsMod.Value));
                otherwise
                    error(['What are you trying to achieve by running this system with %d tether?! '...
                        'I didn''t account for that!\n',obj.numTethers.Value])
            end
            
        end
        
    end
end

