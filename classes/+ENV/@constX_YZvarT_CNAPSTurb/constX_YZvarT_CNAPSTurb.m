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
            
%             [flowTimeseries,dirTimeseries] = crop(obj.cnaps,p.Results.StartTime,p.Results.EndTime);
            
            h.fig = figure;
            hold(gca,'on')
            grid(gca,'on')
            h.allVecs = quiver3(...
                zeros(1,numel(obj.depthArray.Value)),...
                zeros(1,numel(obj.depthArray.Value)),...
                obj.depthArray.Value,...
                obj.flowTSX.Data(:,1,1)',...
                obj.flowTSY.Data(:,1,1)',...
                obj.flowTSZ.Data(:,1,1)',...
                0,...
                'DisplayName','Flw Vec. 1 (m/s)',...
                'Color',[0    0.4470    0.7410]);
            hold on
             h.allVecs1 = quiver3(...
                zeros(1,numel(obj.depthArray.Value)),...
                ones(1,numel(obj.depthArray.Value)),...
                obj.depthArray.Value,...
                obj.flowTSX.Data(:,2,1)',...
                obj.flowTSY.Data(:,2,1)',...
                obj.flowTSZ.Data(:,2,1)',...
                0,...
                'DisplayName','Flw Vec. 2 (m/s)',...
                'Color',[.5    0.6    0.7]);
             h.allVecs2 = quiver3(...
                zeros(1,numel(obj.depthArray.Value)),...
                2*ones(1,numel(obj.depthArray.Value)),...
                obj.depthArray.Value,...
                obj.flowTSX.Data(:,3,1)',...
                obj.flowTSY.Data(:,3,1)',...
                obj.flowTSZ.Data(:,3,1)',...
                0,...
                'DisplayName','Flw Vec. 3 (m/s)',...
                'Color',[.8    0.1    0.7410]);
            h.allVecs3 = quiver3(...
                zeros(1,numel(obj.depthArray.Value)),...
                3*ones(1,numel(obj.depthArray.Value)),...
                obj.depthArray.Value,...
                obj.flowTSX.Data(:,4,1)',...
                obj.flowTSY.Data(:,4,1)',...
                obj.flowTSZ.Data(:,4,1)',...
                0,...
                'DisplayName','Flw Vec. 4 (m/s)',...
                'Color',[1    0.6    0.74]);
            h.allVecs4 = quiver3(...
                zeros(1,numel(obj.depthArray.Value)),...
                4*ones(1,numel(obj.depthArray.Value)),...
                obj.depthArray.Value,...
                obj.flowTSX.Data(:,5,1)',...
                obj.flowTSY.Data(:,5,1)',...
                obj.flowTSZ.Data(:,5,1)',...
                0,...
                'DisplayName','Flw Vec. 5 (m/s)',...
                'Color',[.4    0.8    0.1]);
%             h.instantMean = quiver3(0,0,0,...
%                 mean(squeeze(obj.flowTSX.Data(:,1,1)')),...
%                 mean(squeeze(obj.flowTSY.Data(:,1,1)')),...
%                 mean(squeeze(obj.flowTSZ.Data(:,1,1)')),...,...
%                 'DisplayName','Instantaneous Mean',...
%                 'Color','r');
%             h.totalMean = quiver3(0,0,0,...
%                 mean(mean(obj.flowTSX.Data(:,1,:))),...
%                 mean(mean(obj.flowTSY.Data(:,1,:))),...
%                 mean(mean(obj.flowTSZ.Data(:,1,:))),...
%                 'DisplayName','All Time Mean',...
%                 'Color',[0 0.75 0]);
            
            axis equal
            xlabel('X')
            ylabel('Y')
            zlabel('Depth')
            title('CNAPS MODEL + Turbulence')
            set(gca, 'ZDir','reverse')
            h.legend = legend;
            view([66 87])
            xlim([-2.5 2.5])
            ylim([0 5])
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
            
            for ii = 2:250 %numel(obj.flowTSX.Time)

                h.allVecs.UData = obj.flowTSX.Data(:,1,ii)';
                h.allVecs.VData = obj.flowTSY.Data(:,1,ii)';
                h.allVecs.WData = obj.flowTSZ.Data(:,1,ii)';
                h.allVecs1.UData = obj.flowTSX.Data(:,2,ii)';
                h.allVecs1.VData = obj.flowTSY.Data(:,2,ii)';
                h.allVecs1.WData = obj.flowTSZ.Data(:,2,ii)';
                h.allVecs2.UData = obj.flowTSX.Data(:,3,ii)';
                h.allVecs2.VData = obj.flowTSY.Data(:,3,ii)';
                h.allVecs2.WData = obj.flowTSZ.Data(:,3,ii)';
                h.allVecs3.UData = obj.flowTSX.Data(:,4,ii)';
                h.allVecs3.VData = obj.flowTSY.Data(:,4,ii)';
                h.allVecs3.WData = obj.flowTSZ.Data(:,4,ii)';
                h.allVecs4.UData = obj.flowTSX.Data(:,5,ii)';
                h.allVecs4.VData = obj.flowTSY.Data(:,5,ii)';
                h.allVecs4.WData = obj.flowTSZ.Data(:,5,ii)';
%                 
%                 h.instantMean.UData = mean(squeeze(obj.flowTSX.Data(:,1,ii)'));
%                 h.instantMean.VData = mean(squeeze(obj.flowTSY.Data(:,1,ii)'));
%                 h.instantMean.WData = mean(squeeze(obj.flowTSZ.Data(:,1,ii)'));
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
          function makeTurbVid(obj,vidLength)
              colormap(jet);
              timeStep = 1;
              frame_rate = 10*1/timeStep;
              video = VideoWriter('vid_Test3', 'Motion JPEG AVI');
              video.FrameRate = frame_rate;
              num_frames = length(obj.flowTSX.time);
              
              mov(1:length(obj.flowTSX.time))=struct('cdata',[],'colormap',[]);
              set(gca,'nextplot','replacechildren')
              
              for i = 1:vidLength%length(env.water.flowTSY.time)
                  
                  figure(1)
                  colormap(jet);
                  contourf(obj.yBreakPoints.Value,obj.depthArray.Value,obj.flowTSX.data(:,:,i))
                  
                  
                  h1 = colorbar
                  h1.Label.String= '[m/s]'
                  %     ('Ticks',1:0.2:1.8)
                  
                  xlabel('Y (m)')
                  ylabel('Depth (m)')
                  title(['U Component of Turbulent Flow at Y Z plane. Time = ',sprintf('%0.2f', obj.flowTSX.time(i)),' s'])
                  %     h1 = axis;
                  %     set(h1, 'Ydir', 'reverse')
                  ax6 = gca;
                  ax6.FontSize = 16;
                  %  h6.LineWidth = 1.5
                  %  h6.Color = [0, 0 ,0]
                  set(gca, 'YDir','reverse')
                  x0=100;
                  y0=100;
                  width=700;
                  height= 500;
                  set(gcf,'position',[x0,y0,width,height])
                  F(i) = getframe(gcf);
                  
              end
              
              
              open(video)
              for i = 1:length(F)
                  writeVideo(video, F(i));
              end
              close(video)
              
          end
    end
end