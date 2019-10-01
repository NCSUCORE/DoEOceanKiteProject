classdef constX_YZvarT_ADCPTurb < dynamicprops
    %CONSTANT UNIVFORM FLOW
    
    properties (SetAccess = private)
        velVec
        density
        depth
        depthArray
        gravAccel
        flowTSeriesX
        flowTSeriesY
        flowTSeriesZ
        startADCPTime
        endADCPTime
        flowType
        nominal100mFlowVec
        yBreakPoints
    end
    
    properties (Dependent)
        speed
        elevation
        heading   
    end
    
    methods
        
        %% contructor
        function obj = constX_YZvarT_ADCPTurb
            obj.velVec                      = SIM.parameter('Unit','m/s');
            obj.gravAccel                   = SIM.parameter('Unit','m/s^2');
            obj.density                     = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.depth                       = SIM.parameter('Unit','m','NoScale',true);
            obj.flowTSeriesX                = SIM.parameter('Unit','','NoScale',true);
            obj.flowTSeriesY                = SIM.parameter('Unit','','NoScale',true);
            obj.flowTSeriesZ                = SIM.parameter('Unit','','NoScale',true);
            obj.flowType                    = SIM.parameter('Unit','','NoScale',true);
            obj.nominal100mFlowVec          = SIM.parameter('Unit','m/s');
            obj.startADCPTime               = SIM.parameter('Unit','s','NoScale',true);
            obj.endADCPTime                 = SIM.parameter('Unit','s','NoScale',true);
            obj.depthArray                  = SIM.parameter('Unit','m','NoScale',true);
            obj.yBreakPoints                = SIM.parameter('Unit','m','NoScale',true);
            
        end
        
        
        %% Setters
        function setVelVec(obj,val,unit)
            obj.velVec.setValue(val,unit);
        end
         function setNominal100mFlowVec(obj,val,unit)
            obj.nominal100mFlowVec.setValue(val,unit);
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
        
        function setDepthArray(obj,val,unit)
            depthMat = linspace(0,obj.depth.Value,obj.depth.Value);
            obj.depthArray.setValue(depthMat,'m');
        end
        
        function setYBreakPoints(obj,val,unit)
            obj.yBreakPoints.setValue(val,unit);
        end
        
        function setStartADCPTime(obj,val,unit)
            obj.startADCPTime.setValue(val,unit);
        end
        
        function setEndADCPTime(obj,val,unit)
            obj.endADCPTime.setValue(val,unit);
        end
        
        function setFlowType(obj,val,unit)
            obj.flowType.setValue(val,unit);
        end
        
         function setFlowTSeries(obj,unit)
             if ~exist('turbGrid.mat')
             [val1,val2,val3] = createADCPTimeSeriesTurb(obj);
             obj.flowTSeriesX.setValue(val1,unit);
             obj.flowTSeriesY.setValue(val2,unit);
             obj.flowTSeriesZ.setValue(val3,unit);
             
             else
             [val1,val2,val3] = createADCPTimeSeriesTurb2(obj);
             obj.flowTSeriesX.setValue(val1,unit);
             obj.flowTSeriesY.setValue(val2,unit);
             obj.flowTSeriesZ.setValue(val3,unit);
             end
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