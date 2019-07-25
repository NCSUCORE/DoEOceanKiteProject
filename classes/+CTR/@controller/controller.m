classdef controller < dynamicprops
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = controller
            %CONTROLLER Construct an instance of this class
            %   Detailed explanation goes here
            
        end
        
        
        function add(obj,varargin)
            p = inputParser;
            addParameter(p,'FPIDNames',{},@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'FPIDErrorUnits',{},@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'FPIDOutputUnits',{},@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'GainNames',{},@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'GainUnits',{},@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'SaturationNames',{},@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'SetpointNames',{},@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'SetpointUnits',{},@(x) all(cellfun(@(x) isa(x,'char'),x)))
            parse(p,varargin{:})
            
            % Add filtered PID controller
            if ~isempty(p.Results.FPIDNames)
                for ii = 1:numel(p.Results.FPIDNames)
                    obj.addprop(p.Results.FPIDNames{ii});
                    obj.(p.Results.FPIDNames{ii}) = CTR.FPID(p.Results.FPIDErrorUnits{ii},p.Results.FPIDOutputUnits{ii});
                end
            end
            
            % Add gains
            if ~isempty(p.Results.GainNames)
                for ii = 1:numel(p.Results.GainNames)
                    obj.addprop(p.Results.GainNames{ii});
                    obj.(p.Results.GainNames{ii}) = SIM.parameter('Unit',p.Results.GainUnits{ii});
                end
            end
            
            % Add saturations
            if ~isempty(p.Results.SaturationNames)
                for ii = 1:numel(p.Results.SaturationNames)
                    obj.addprop(p.Results.SaturationNames{ii});
                    obj.(p.Results.SaturationNames{ii}) = CTR.sat;
                end
            end
            
            % Add setpoints
            if ~isempty(p.Results.SetpointNames)
                for ii = 1:numel(p.Results.SetpointNames)
                    obj.addprop(p.Results.SetpointNames{ii});
                    obj.(p.Results.SetpointNames{ii}) = CTR.setPoint;
                end
            end
            
        end
        
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                if isa(obj.(props{ii}),'CTR.setPoint')
                    obj.(props{ii}) = obj.(props{ii}).scale(lengthScaleFactor);
                else
                    obj.(props{ii}).scale(lengthScaleFactor);
                end
            end
        end
    end
end

