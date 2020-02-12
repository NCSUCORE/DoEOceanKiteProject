classdef planarWaves < dynamicprops
    
    
    properties (SetAccess = private)
        numWaves
        waveParamMat
    end
    
    methods
        function obj = planarWaves
            obj.numWaves          = SIM.parameter('NoScale',true);
            obj.waveParamMat      = SIM.parameter('NoScale',true);
        end
        
        
        function obj = setNumWaves(obj,val,units)
            obj.numWaves.setValue(val,units);
        end
        
         function obj = setWaveParamMat(obj,val,units)
            obj.waveParamMat.setValue(val,units);
        end
        
        function obj = build(obj,varargin)
            defWaveName = {};
            for ii = 1:obj.numWaves.Value
                defWaveName{ii} = sprintf('wave%d',ii);
            end
            
            p = inputParser;
            addParameter(p,'WaveNames',defWaveName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            parse(p,varargin{:})
            
            % Create wave
            for ii = 1:obj.numWaves.Value
                obj.addprop(p.Results.WaveNames{ii});
                obj.(p.Results.WaveNames{ii}) = ENV.planarWaveModel;
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
        
        function val = structAssem(obj)
            
            %defining matrix to keep all the wave param data 
            
            %          WaveNumber | Frequency | Amplitude | phase
            % wave 1 |
            % wave 2 |
            % ...    |
            % wave n |
            
            
            
            for i = 1: obj.numWaves.Value
            val(i,:) = [obj.(sprintf('wave%d',i)).waveNumber.Value,...
                obj.(sprintf('wave%d',i)).frequency.Value,obj.(sprintf('wave%d',i)).amplitude.Value,obj.(sprintf('wave%d',i)).phase.Value];
            
            
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
        
        
        
    end
    
    
end



