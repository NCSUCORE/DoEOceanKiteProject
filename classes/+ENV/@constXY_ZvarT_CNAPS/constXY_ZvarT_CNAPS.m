classdef constXY_ZvarT_CNAPS
    %Flow profile that is constant WRT X and Y but varies with Z according
    %to CNAPS data flow.  Individual components of the flow vector can be
    %enabled or zeroed using componentEnable
    properties (SetAccess = private)
        density
        gravAccel
        startCNAPSTime
        endCNAPSTime
        componentEnable
        depthArray
        flowVecTSeries
        flowDirTSeries
    end
    
    properties (Access = private)
        cnaps
    end
    
    methods
        
        %% constructor
        function obj = constXY_ZvarT_CNAPS
            obj.gravAccel                   = SIM.parameter('Unit','m/s^2');
            obj.density                     = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.startCNAPSTime               = SIM.parameter('Value',0,'Unit','s');
            obj.endCNAPSTime                 = SIM.parameter('Value',inf,'Unit','s');
            obj.componentEnable             = SIM.parameter('Value',logical([1 1 1]),'Unit','');
            obj.cnaps = ENV.CNAPS;
            obj.flowVecTSeries                 = SIM.parameter(...
                'Value',obj.cnaps.flowVecTSeries.Value,...
                'Unit' ,obj.cnaps.flowVecTSeries.Unit);
            obj.flowDirTSeries                 = SIM.parameter(...
                'Value',obj.cnaps.flowDirTSeries.Value,...
                'Unit' ,obj.cnaps.flowDirTSeries.Unit);
        end
        
        %% Setters (Independent properties)
        function setDensity(obj,val,unit)
            obj.density.setValue(val,unit);
        end
        function setGravAccel(obj,val,unit)
            obj.gravAccel.setValue(val,unit);
        end
        function obj = setStartCNAPSTime(obj,val,unit)
            obj.startCNAPSTime.setValue(val,unit);
            
            if obj.startCNAPSTime.Value<=obj.endCNAPSTime.Value
                [vecTSeries,dirTSeries] = obj.cnaps.crop(obj.startCNAPSTime.Value,obj.endCNAPSTime.Value);
                obj.flowVecTSeries = SIM.parameter(...
                    'Value',vecTSeries,...
                    'Unit' ,vecTSeries.DataInfo.Units);
                obj.flowDirTSeries = SIM.parameter(...
                    'Value',dirTSeries,...
                    'Unit' ,dirTSeries.DataInfo.Units);
            else
                error('Start time must be <= end time')
            end
        end
        function obj = setEndCNAPSTime(obj,val,unit)
            obj.endCNAPSTime.setValue(val,unit);
            if obj.startCNAPSTime.Value<=obj.endCNAPSTime.Value
                [vecTSeries,dirTSeries] = obj.cnaps.crop(obj.startCNAPSTime.Value,obj.endCNAPSTime.Value);
                obj.flowVecTSeries = SIM.parameter(...
                    'Value',vecTSeries,...
                    'Unit' ,vecTSeries.DataInfo.Units);
                obj.flowDirTSeries = SIM.parameter(...
                    'Value',dirTSeries,...
                    'Unit' ,dirTSeries.DataInfo.Units);
            else
                error('Start time must be <= end time')
            end
        end
        function setComponentEnable(obj,val,unit)
            obj.componentEnable.setValue(logical(val),unit);
        end
        
        % Getters (Dependent Properties)
        %         function val = get.flowTSeries(obj)
        %             val = obj.cnaps.flowVecTSeries;
        %             val = getsampleusingtime(val,obj.startCNAPSTime.Value,obj.endCNAPSTime.Value);
        %             val.Time = val.Time-val.Time(1);
        %             % Zero components specified by the user
        %             val.Data(~obj.componentEnable.Value(:),:,:) = 0;
        %         end
        
        function val = get.depthArray(obj)
            val  = SIM.parameter('Value',obj.cnaps.depths.Value,'Unit','m');
        end
        
        %% Function to plot magnitude of flow
        function plotMags(obj,varargin)
            %PLOTMAGS F
            mags   = squeeze(sqrt(sum(obj.flowVecTSeries.Value.Data.^2,1)));
            mags(mags>5) = 5;
            times = repmat(obj.flowVecTSeries.Value.Time(:)./3600,[1 numel(obj.depthArray.Value)]);
            depths = repmat(obj.depthArray.Value(:)',[numel(obj.flowVecTSeries.Value.Time) 1]);
            h.surf = contourf(times,depths,mags',[0:0.25:5]);
            
            xlabel('Time [Hrs.]')
            ylabel('Dist from sea level [m]')
            h.colorbar = colorbar;
            
            h.colorbar.Label.String = 'Flow speed [m/s]';
            h.colorbar.FontSize = 18;
            set(gca,'FontSize',18)
            set(gca, 'YDir','reverse')
        end
        function animate3D(obj,varargin)
            %% Input parsing
            p = inputParser;
            
            % ---Parameters for saving a gif---
            % Switch to enable saving 0 = don't save
            addParameter(p,'SaveGif',false,@islogical)
            % Path to saved file, default is ./output
            addParameter(p,'GifPath',fullfile(fileparts(which('OCTProject.prj')),'output')); % Default output location is ./output folder
            % Name of saved file, default is flowProfileAnimation.gif
            addParameter(p,'GifFile','flowHeading.gif');
            % Time step between frames of gif, default is 30 fps
            addParameter(p,'GifTimeStep',1/30,@isnumeric)
            
            % Start time
            addParameter(p,'StartTime',0,@isnumeric)
            % End time
            addParameter(p,'EndTime',obj.flowVecTSeries.Value.Time(end),@isnumeric)
            
            % ---Parameters used for plotting---
            % Set font size
            addParameter(p,'FontSize',get(0,'defaultAxesFontSize'),@isnumeric)
            % ---Parse the output---
            parse(p,varargin{:})
            
            if p.Results.StartTime>=p.Results.EndTime
                error('StartTime must be less than EndTime')
            end
            
            % Setup some infrastructure type things
            % If the user wants to save something and the specified directory does not
            % exist, create it
            if p.Results.SaveGif && ~exist(p.Results.GifPath, 'dir')
                mkdir(p.Results.GifPath)
            end
            
            [flowTimeseries,dirTimeseries] = crop(obj.cnaps,p.Results.StartTime,p.Results.EndTime);
            
            h.fig = figure;
            hold(gca,'on')
            grid(gca,'on')
            h.allVecs = quiver3(...
                zeros(1,numel(obj.depthArray.Value)),...
                zeros(1,numel(obj.depthArray.Value)),...
                obj.depthArray.Value,...
                flowTimeseries.Data(1,:,1),...
                flowTimeseries.Data(2,:,1),...
                zeros(size( flowTimeseries.Data(2,:,1))),...
                0,...
                'DisplayName','Flow Vector',...
                'Color',[0    0.4470    0.7410]);
            hold on
            h.instantMean = quiver3(0,0,0,...
                mean(squeeze(flowTimeseries.Data(1,:,1))),...
                mean(squeeze(flowTimeseries.Data(2,:,1))),...
                zeros(size(  mean(squeeze(flowTimeseries.Data(2,:,1))))),...
                'DisplayName','Instantaneous Mean',...
                'Color','r');
            h.totalMean = quiver3(0,0,0,...
                mean(mean(flowTimeseries.Data(1,:,:))),...
                mean(mean(flowTimeseries.Data(1,:,:))),...
                0,...
                'DisplayName','All Time Mean',...
                'Color',[0 0.75 0]);
            
            axis equal
            xlabel('X')
            ylabel('Y')
            zlabel('Z')
            
            h.legend = legend;
            view([66 87])
            xlim([-2.5 2.5])
            ylim([-2.5 2.5])
            zlim([0 max(obj.depthArray.Value)])
            if strcmpi(getenv('username'),'M.Cobb') % If this is on mitchells laptop
                h.fig.Position = 1e3*[1.0178    0.0418    0.5184    0.7408];
            end
            
            if p.Results.SaveGif
                frame = getframe(h.fig);
                im = frame2im(frame);
                [imind,cm] = rgb2ind(im,256);
                imwrite(imind,cm,fullfile(p.Results.GifPath,p.Results.GifFile),'gif', 'Loopcount',inf);
            end
            
            for ii = 2:numel(flowTimeseries.Time)
                h.allVecs.UData = flowTimeseries.Data(1,:,ii);
                h.allVecs.VData = flowTimeseries.Data(2,:,ii);
                
                
                h.instantMean.UData = mean(squeeze(flowTimeseries.Data(1,:,ii)));
                h.instantMean.VData = mean(squeeze(flowTimeseries.Data(2,:,ii)));
                
                drawnow
                % Save gif of results
                if p.Results.SaveGif
                    frame = getframe(h.fig);
                    im = frame2im(frame);
                    [imind,cm] = rgb2ind(im,256);
                    imwrite(imind,cm,fullfile(p.Results.GifPath,p.Results.GifFile),'gif','WriteMode','append','DelayTime',p.Results.GifTimeStep)
                    
                end
            end
        end
        
        
        %% other methods
        % Function to scale the object
        % Might not be written correctly ENV.CNAPS needs a scale method
        % associated with it and that needs to be called from here
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = findAttrValue(obj,'SetAccess','public');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end