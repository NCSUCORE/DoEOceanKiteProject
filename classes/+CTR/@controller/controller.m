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
            addParameter(p,'SaturationUnits',{},@(x) all(cellfun(@(x) isa(x,'char'),x)))
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
                    obj.(p.Results.SetpointNames{ii}) =...
                        SIM.parameter('Value',timeseries(0,0),'Unit',p.Results.SetpointUnits{ii});
                end
            end
            
        end
        
        function plotPath(obj,varargin)
            p = inputParser;
            addParameter(p,'azimuth',true,@islogical);
            addParameter(p,'elevation',true,@islogical);
            addParameter(p,'tether',true,@islogical);
            addParameter(p,'width',true,@islogical);
            addParameter(p,'height',true,@islogical);
            parse(p,varargin{:});
            
            pathGeom = evalin('base','PATHGEOMETRY');
            n = numel(0:0.005:1)-1;
            try
                [pg,~] = evalin('base',[pathGeom '(0:0.005:1,hiLvlCtrl.basisParams.Value,[0 0 0])']);
            catch
                basisParams = obj.initBasisParams.Value;
            end
            figure
            plot3(pg(1,:),pg(2,:),pg(3,:),'k','LineWidth',1,'DisplayName','Path Geometry')
            hold on
            grid on
            if p.Results.width
            plot3([pg(1,3*n/4) pg(1,n/4)],[max(pg(2,:)) min(pg(2,:))],[pg(3,3*n/4) pg(3,n/4)],...
                'r','LineWidth',1.5,'DisplayName','Path Width (w)')
            end
            if p.Results.height
            plot3([pg(1,3*n/8) pg(1,n/8)],[pg(2,n/8) pg(2,n/8)],[max(pg(3,:)) min(pg(3,:))],...
                'b','LineWidth',1.5,'DisplayName','Path Height (h)')
            end
            if p.Results.tether
            plot3([0 pg(1,1)],[0 pg(2,1)],[0 pg(3,1)],'k--','LineWidth',...
                1.5,'DisplayName','Tether Length (l)')
            end
            if p.Results.elevation
            plot3([0 pg(1,1) pg(1,1) 0],[0 pg(2,1) pg(2,1) 0],[0 pg(3,1) 0 0],'r:',...
                'LineWidth',1.5,'DisplayName','Elevation Angle ($\theta$)')
            end
            if p.Results.azimuth
            plot3([0 pg(1,1) pg(1,1) 0],[0 0 pg(2,1) 0],[0 0 0 0],'b:',...
                'LineWidth',1.5,'DisplayName','Azimuth Angle ($\phi$)')
            end
            axis equal
            xlim([0 inf])
            zlim([0 inf])
            xlabel 'X [m]';
            ylabel 'Y [m]';
            zlabel 'Z [m]';
            legend('Location','northeast')
            view(40,30)
        end
        
        
        
        
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end

