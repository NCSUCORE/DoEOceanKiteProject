classdef variedFlow < dynamicprops
    %CONSTANT UNIVFORM FLOW
    
    properties (SetAccess = private)
        velVec
        density
        depth
        repeat 
        amplitude
        waveBias
        depthArray
        waveCoursenessFactor
        gravAccel
        flowTSeries
        startADCPTime
    end
    
    properties (Dependent)
        speed
        elevation
        heading   
    end
    
    methods
        
        %% contructor
        function obj = variedFlow
            obj.velVec                      = SIM.parameter('Unit','m/s');
            obj.gravAccel                   = SIM.parameter('Unit','m/s^2');
            obj.density                     = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.depth                       = SIM.parameter('Unit','m','NoScale',true);
            obj.repeat                      = SIM.parameter('Unit','','NoScale',true);
            obj.amplitude                   = SIM.parameter('Unit','','NoScale',true);
            obj.waveBias                    = SIM.parameter('Unit','','NoScale',true);
            obj.flowTSeries                 = SIM.parameter('Unit','','NoScale',true);
            obj.waveCoursenessFactor        = SIM.parameter('Unit','','NoScale',true);
            obj.startADCPTime               = SIM.parameter('Unit','s','NoScale',true);
            obj.depthArray                  = SIM.parameter('Unit','m','NoScale',true);
            
        end
        
        
        %% Setters
        function setVelVec(obj,val,unit)
            obj.velVec.setValue(val,unit);
        end
        
        function setGravAccel(obj,val,unit)
            obj.gravAccel.setValue(val,unit);
        end
        
        function setDensity(obj,val,unit)
            obj.density.setValue(val,unit);
        end
        
        function setDepth(obj,val,unit)
            obj.depth.setValue(val,unit);
        end
        
        function setAmplitude(obj,val,unit)
            obj.amplitude.setValue(val,unit);
        end
        
        function setWaveBias(obj,val,unit)
            obj.waveBias.setValue(val,unit);
        end
        
         function setWaveCoursenessFactor(obj,val,unit)
            obj.waveCoursenessFactor.setValue(val,unit);
        end
        
        function setPeriod(obj,duration_s,period)      
             obj.repeat.setValue(duration_s/period ,'');
        end
        
        function setDepthArray(obj,duration_s)
            depthMat = linspace(0,obj.depth.Value,obj.depth.Value);
            obj.depthArray.setValue(depthMat,'m');
        end
        
        function setFlowTSeries(obj,val,unit)
            obj.flowTSeries.setValue(val,unit);
        end

        function setStartADCPTime(obj,val,unit)
            obj.startADCPTime.setValue(val,unit);
        end
        function obj = addFlow(obj,FlowNames,FlowTypes,varargin)
            p = inputParser;
            addRequired(p,'FlowNames',@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addRequired(p,'FlowTypes',@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'FlowDensities',[],@(x) all(isnumeric(x)))
            parse(p,FlowNames,FlowTypes,varargin{:})
            % Create winches
            for ii = 1:numel(p.Results.FlowNames)
                obj.addprop(p.Results.FlowNames{ii});
                obj.(p.Results.FlowNames{ii}) = ENV.(p.Results.FlowTypes{ii});
                if ~isempty(p.Results.FlowDensities)
                    obj.(p.Results.FlowNames{ii}).density.setValue(p.Results.FlowDensities(ii),'kg/m^3');
                end
            end
        end
        
        
        
     
        
        
        %% getters
        function val = get.speed(obj)
            val = SIM.parameter('Value',sqrt(sum(obj.velVec.Value.^2)),...
                'Unit','m/s');
        end
        
        function val = get.elevation(obj)
            val =  SIM.parameter('Value',acosd(obj.velVec.Value(3)./sqrt(obj.velVec.Value(1)^2+obj.velVec.Value(2).^2)),...
                'Unit','deg');
            
        end
        
        function val = get.heading(obj)
            val = SIM.parameter('Value',atan2d(obj.velVec.Value(2),obj.velVec.Value(1)),...
                'Unit','deg');
        end
        
      
        
    
        
        %% other methods
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = findAttrValue(obj,'SetAccess','public');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        
        
        
    end
end