classdef constX_YZvarT_CNAPSTurb 
    %Flow profile that's constant WRT x, but varies with Y and Z according
    %to the ADCP data with superimposed turbulence
    
    properties (SetAccess = private)
        density
        depthArray
        gravAccel
        startCNAPSTime
        endCNAPSTime
        yBreakPoints
        flowVecTSeries
        %         flowDirTSeries
        TI
        f_min
        f_max
        P
        Q
        C
        N_mid_freq
        flowTSX
        flowTSY
        flowTSZ
    end
    
    properties (Access = private)
        cnaps
    end
    
    methods
        
        %% contructor
        function obj = constX_YZvarT_CNAPSTurb
            obj.gravAccel                   = SIM.parameter('Unit','m/s^2');
            obj.density                     = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.startCNAPSTime               = SIM.parameter('Value',0,'Unit','s','NoScale',true);
            obj.endCNAPSTime                 = SIM.parameter('Value',inf,'Unit','s','NoScale',true);
            obj.yBreakPoints                = SIM.parameter('Unit','m','NoScale',true);
            obj.TI                          = SIM.parameter('Unit','');
            obj.f_min                       = SIM.parameter('Unit','Hz');
            obj.f_max                       = SIM.parameter('Unit','Hz');
            obj.P                           = SIM.parameter('Unit','');
            obj.Q                           = SIM.parameter('Unit','Hz');
            obj.C                           = SIM.parameter('Unit','');
            obj.N_mid_freq                  = SIM.parameter('Unit','');
            
            obj.cnaps = ENV.CNAPS;
        end
        
        %% Setters
        function setGravAccel(obj,val,unit)
            obj.gravAccel.setValue(val,unit);
        end
        
        function setDensity(obj,val,unit)
            obj.density.setValue(val,unit);
        end
        
        function setYBreakPoints(obj,val,unit)
            obj.yBreakPoints.setValue(val,unit);
        end
        
        
        function obj = setStartCNAPSTime(obj,val,unit)
            obj.startCNAPSTime.setValue(val,unit);
            
            if obj.startCNAPSTime.Value<=obj.endCNAPSTime.Value
                vecTSeries = obj.cnaps.crop(obj.startCNAPSTime.Value,obj.endCNAPSTime.Value);
                obj.flowVecTSeries = SIM.parameter(...
                    'Value',vecTSeries,...
                    'Unit' ,vecTSeries.DataInfo.Units);
                
            else
                error('Start time must be <= end time')
            end
        end
        function obj = setEndCNAPSTime(obj,val,unit)
            obj.endCNAPSTime.setValue(val,unit);
            if obj.startCNAPSTime.Value<=obj.endCNAPSTime.Value
                vecTSeries = obj.cnaps.crop(obj.startCNAPSTime.Value,obj.endCNAPSTime.Value);
                obj.flowVecTSeries = SIM.parameter(...
                    'Value',vecTSeries,...
                    'Unit' ,vecTSeries.DataInfo.Units);
                
            else
                error('Start time must be <= end time')
            end
        end
        function setTI(obj,val,unit)
            obj.TI.setValue(val,unit);
        end
        function setF_min(obj,val,unit)
            obj.f_min.setValue(val,unit);
        end
        function setF_max(obj,val,unit)
            obj.f_max.setValue(val,unit);
        end
        function setP(obj,val,unit)
            obj.P.setValue(val,unit);
        end
        function setQ(obj,val,unit)
            obj.Q.setValue(val,unit);
        end
        function setC(obj,val,unit)
            obj.C.setValue(val,unit);
        end
        function setN_mid_freq(obj,val,unit)
            obj.N_mid_freq.setValue(val,unit);
        end
        
        
        
        % getters
        function val = get.depthArray(obj)
            val = obj.cnaps.depths;
        end
        
        
        % function to generate turbGrid.mat
        process(obj)
        
        % function to build timeseries from turbGrid.mat
        obj =  buildTimeseries(obj)
        
        
        % turbulence generator
        val = turbulence_generator2(x1,x2,x3,x4,x5,x6,x7,x8,x9,x10);
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