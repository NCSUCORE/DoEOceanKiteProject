classdef constXYZ_varT_SineWave 
    %time varying sine wave flow 
    
    properties (SetAccess = private)
        density
        amplitude
        waveBias
        gravAccel
        frequency
        phase
        azimuth
        elevation
    end
    
    methods
        
        %% contructor
        function obj = constXYZ_varT_SineWave
            obj.gravAccel                   = SIM.parameter('Unit','m/s^2');
            obj.density                     = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.amplitude                   = SIM.parameter('Unit','','NoScale',true);
            obj.waveBias                    = SIM.parameter('Unit','','NoScale',true);
            obj.frequency                   = SIM.parameter('Unit','1/s','NoScale',true);
            obj.phase                       = SIM.parameter('Unit','rad','NoScale',true);
            obj.azimuth                     = SIM.parameter('Unit','rad','NoScale',true);
            obj.elevation                   = SIM.parameter('Unit','rad','NoScale',true);
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
        
        function setAmplitude(obj,val,unit)
            obj.amplitude.setValue(val,unit);
        end
        
        function setWaveBias(obj,val,unit)
            obj.waveBias.setValue(val,unit);
        end
        function setFrequency(obj,val,unit)
            obj.frequency.setValue(val,unit);
        end
        function setPhase(obj,val,unit)
            obj.phase.setValue(val,unit);
        end
        
        function setNominal100mFlowVec(obj,val,unit)
            obj.nominal100mFlowVec.setValue(val,unit);
        end
        
        function setAzimuth(obj,val,unit)
            obj.azimuth.setValue(val,unit);
        end
        
        function setElevation(obj,val,unit)
            obj.elevation.setValue(val,unit);
        end
        
        
%         function obj = addFlow(obj,FlowNames,FlowTypes,varargin)
%             p = inputParser;
%             addRequired(p,'FlowNames',@(x) all(cellfun(@(x) isa(x,'char'),x)))
%             addRequired(p,'FlowTypes',@(x) all(cellfun(@(x) isa(x,'char'),x)))
%             addParameter(p,'FlowDensities',[],@(x) all(isnumeric(x)))
%             parse(p,FlowNames,FlowTypes,varargin{:})
%             % Create winches
%             for ii = 1:numel(p.Results.FlowNames)
%                 obj.addprop(p.Results.FlowNames{ii});
%                 obj.(p.Results.FlowNames{ii}) = ENV.(p.Results.FlowTypes{ii});
%                 if ~isempty(p.Results.FlowDensities)
%                     obj.(p.Results.FlowNames{ii}).density.setValue(p.Results.FlowDensities(ii),'kg/m^3');
%                 end
%             end
%         end
%         
%         
        
     
        
        
        %% getters
%         function val = get.speed(obj)
%             val = SIM.parameter('Value',sqrt(sum(obj.velVec.Value.^2)),...
%                 'Unit','m/s');
%         end
        
%         function val = get.elevation(obj)
%             val =  SIM.parameter('Value',acosd(obj.velVec.Value(3)./sqrt(obj.velVec.Value(1)^2+obj.velVec.Value(2).^2)),...
%                 'Unit','deg');
%             
%         end
        
%         function val = get.heading(obj)
%             val = SIM.parameter('Value',atan2d(obj.velVec.Value(2),obj.velVec.Value(1)),...
%                 'Unit','deg');
%         end
%         
      
        
    
        
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