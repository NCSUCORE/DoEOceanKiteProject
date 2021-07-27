classdef tethers < dynamicprops
    %TETHERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        numTethers
        numNodes
        maxPercentageElongation
        maxAppFlowMultiplier
    end
    
    methods
        function obj = tethers
            obj.numTethers      = SIM.parameter('NoScale',true);
            obj.numNodes        = SIM.parameter('NoScale',true,'Description','Number of nodes in each tether, all tethers have the same number of nodes');
            obj.maxPercentageElongation = SIM.parameter('Value',0.05);
            obj.maxAppFlowMultiplier = SIM.parameter('Value',2);
        end
        
        function obj = setNumTethers(obj,val,units)
            obj.numTethers.setValue(val,units);
        end
        
        function obj = setNumNodes(obj,val,units)
            props = obj.getPropsByClass('OCT.tether');
            for ii = 1:length(props)
                obj.(props{ii}).setNumNodes(val,units);
            end
            obj.numNodes.setValue(val,units);
            
        end
        
        function obj = build(obj,varargin)
            defThrName = {};
            for ii = 1:obj.numTethers.Value
                defThrName{ii} = sprintf('tether%d',ii);
            end
            
            p = inputParser;
            addParameter(p,'TetherNames',defThrName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'TetherClass','tether',@(x) any(strcmp(x,{'tether','tether001','tetherF'})))
            parse(p,varargin{:})
            
            % Create tethers
            for ii = 1:obj.numTethers.Value
                obj.addprop(p.Results.TetherNames{ii});
                obj.(p.Results.TetherNames{ii}) = eval(sprintf('OCT.%s(obj.numNodes.Value)',p.Results.TetherClass));
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
                    value = double(obj.(props{ii}).(subProps{jj}).Value);
                    if ~isnumeric(value)
                        warning('Non-numeric property, %s',subProps{jj})
                    else
                        if ~isempty(value)
                            val(ii).(subProps{jj}) = value;
                        end
                    end
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
            %             Sref = vhcl.stbWing.refArea.Value + vhcl.prtWing.refArea.Value;
            F_aero = [0;0;0];
            aeroSurfs = vhcl.getPropsByClass('OCT.aeroSurf');
            for ii = 1:numel(aeroSurfs)
                Sref = vhcl.(aeroSurfs{ii}).refArea.Value;
                CLm(ii) = max(vhcl.(aeroSurfs{ii}).CL.Value);
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
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                try
                    obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
                catch
                end
            end
        end
    end
    
    
end

