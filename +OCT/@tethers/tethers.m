classdef tethers < dynamicprops
    %TETHERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numTethers
        maxPercentageElongation = SIM.parameter('Value',0.05);
        maxAppFlowMultiplier = SIM.parameter('Value',2);
    end
    
    methods
        function obj = tethers
            obj.numTethers      = SIM.parameter('NoScale',true);
        end
        
        function obj = build(obj,varargin)
            defThrName = {};
            for ii = 1:obj.numTethers.Value
                defThrName{ii} = sprintf('tether%d',ii);
            end
            
            p = inputParser;
            addParameter(p,'TetherNames',defThrName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            parse(p,varargin{:})
            
            % Create tethers
            for ii = 1:obj.numTethers.Value
                obj.addprop(p.Results.TetherNames{ii});
                obj.(p.Results.TetherNames{ii}) = OCT.tether;
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
        
        % function to design tether dimater
        function obj = designTetherDiameter(obj,vhcl,env)
            % calculate total external forces except tethers
            F_grav = vhcl.mass.Value*env.gravAccel.Value*[0;0;-1];
            F_buoy =  env.water.density.Value*vhcl.volume.Value*...
                env.gravAccel.Value*[0;0;1];
            
            % calculate lift forces for wing and HS, ignore VS
            q_max = 0.5*env.water.density.Value*(obj.maxAppFlowMultiplier.Value*norm(env.water.velVec.Value))^2;
            Sref = vhcl.aeroSurf1.refArea.Value;
            F_aero = [0;0;0];
            for ii = 1:3
                CLm(ii) = max(vhcl.(strcat('aeroSurf',num2str(ii))).CL.Value);
                F_aero = F_aero + q_max*Sref*[0;0;CLm(ii)];
            end
            
            sum_F = norm(F_grav + F_buoy + F_aero);
            
            switch obj.numTethers.Value
                case 1
                    obj.tether1.diameter.setValue(sqrt((4*sum_F)/...
                        (pi*obj.maxPercentageElongation.Value*obj.tether1.youngsMod.Value)),obj.tether1.diameter.Unit);
                case 3
                    obj.tether1.diameter.setValue(sqrt((4*sum_F/4)/...
                        (pi*obj.maxPercentageElongation.Value*obj.tether1.youngsMod.Value)),obj.tether1.diameter.Unit);
                    obj.tether2.diameter.setValue(sqrt((4*sum_F/2)/...
                        (pi*obj.maxPercentageElongation.Value*obj.tether2.youngsMod.Value)),obj.tether2.diameter.Unit);
                    obj.tether3.diameter.setValue(sqrt((4*sum_F/4)/...
                        (pi*obj.maxPercentageElongation.Value*obj.tether3.youngsMod.Value)),obj.tether3.diameter.Unit);
                otherwise
                    error(['What are you trying to achieve by running this system with %d tether?! '...
                        'I didn''t account for that!\n',obj.numTethers.Value])
            end
        end
        
        % Function to scale the object
        function obj = scale(obj,scaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                try
                obj.(props{ii}).scale(scaleFactor);
                catch
                end
            end
        end
    end

    
end

