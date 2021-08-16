classdef Manta < handle
    % Manta class to hold Manta data
    properties (SetAccess = private)
        density
        startTime
        endTime
        flowVecTimeseries
        xGridPoints
        yGridPoints
        zGridPoints
        maxSpeed
        minSpeed
        month
    end
    
    properties (Hidden = true)
        % Property to hold all flow data, hidden from the user
        allFlowVecTimeseries
    end
    
    methods
        function obj = Manta(mnthIndx,varargin)
            % Input mnthIndx is a single element of [1 4 7 10] indicating
            % which month of data that you want to use, and then dayIndx
            % is the index of the day within that month that you'd like to
            % use
            p = inputParser;
            addRequired(p,'mnthIndx',@(x) mod(x,1)==0);
            addOptional(p,'ForceRecompile',false,@(x) islogical(x));
            addOptional(p,'DataSel',1,@(x) isnumeric(x));
            parse(p,mnthIndx,varargin{:})
            % Get base path to where the model is stored on your computer
            basePath = fileparts(which('OCTModel'));
            % Append path to include the location of this classdef
            dataPath = fullfile(basePath,'classes','+ENV','@Manta');
            % Get a list of all files in that location
            folders = dir(dataPath);
            % Filter list to include only directories (no .m files, etc)
            folders = folders([folders.isdir]);
            % Drop the first two, which are just . and ..
            folders = folders(3:end);
            % Build two-character string for the month and day numbers
            mnthString = sprintf('%02d',p.Results.mnthIndx);
            % Get the name of the .mat file that should contain this data
            if p.Results.DataSel == 1
                fName = fullfile(dataPath,['NewTS_FlowData_2017_',mnthString '.mat']);
            elseif p.Results.DataSel == 2
                fName = fullfile(dataPath,['NewTS_FlowData_2017a_',mnthString '.mat']);
            else
                fName = fullfile(dataPath,['TS_FlowData_2017_',mnthString '.mat']);
            end
            % If it doesn't exist, then attempt to build it
            if (~isfile(fName)) || p.Results.ForceRecompile
                % Check if the folder for that data exists
                if p.Results.DataSel == 1
                    folder = folders(contains({folders.name},[mnthString '-2017']));
                elseif p.Results.DataSel == 2
                    folder = folders(contains({folders.name},[mnthString 'a-2017']));
                else
                    folder = folders(contains({folders.name},['2017' mnthString '_hourly']));
                end
                if isempty(folder)
                    error('Unknown month')
                elseif numel(folder)>1
                    error('Multiple matching months')
                end
                % Get files in that folder
                files = dir(fullfile(folder.folder,folder.name));
                % Get files that match the specified day
                % Ignore the first 2 items
                files = files(3:end);
                % If the list of files is empty, throw an error
                if isempty(files)
                    error('Unknown day')
                end
                % Build the .mat file
                if p.Results.DataSel == 2
                    [data,xBreak,yBreak,zBreak] = obj.buildMantaMAT3(files);
                else
                    [data,xBreak,yBreak,zBreak] = obj.buildMantaMAT2(files);
                end
                save(fName,'data','xBreak','yBreak','zBreak');
            else
                load(fName);
            end
            % Build the vector of timestamps
            timeVec = 0:3:3*size(data,5)-1;
            obj.density                 = SIM.parameter('Unit','kg/m^3');
            obj.allFlowVecTimeseries    = SIM.parameter('Value',timeseries(data,3600*timeVec),'Unit','m/s');
            obj.startTime               = SIM.parameter('Value',3600*timeVec(1),'Unit','s');
            obj.endTime                 = SIM.parameter('Value',3600*timeVec(end),'Unit','s');
            obj.flowVecTimeseries       = SIM.parameter('Unit','m/s');
            obj.xGridPoints             = SIM.parameter('Value',xBreak,'Unit','m');
            obj.yGridPoints             = SIM.parameter('Value',yBreak,'Unit','m');
            obj.zGridPoints             = SIM.parameter('Value',zBreak,'Unit','m');
            obj.month                   = SIM.parameter('Value',p.Results.mnthIndx,'Unit','','NoScale',true);
            obj.crop(obj.startTime.Value,obj.endTime.Value); % Sets the 
        end
        function setDensity(obj,val,unit)
            obj.density.setValue(val,unit);
        end
        function setStartTime(obj,val,unit)
            obj.startTime.setValue(val,unit);
            obj.crop(obj.startTime.Value,obj.endTime.Value);
        end
        function setEndTime(obj,val,unit)
            obj.endTime.setValue(val,unit);
            obj.crop(obj.startTime.Value,obj.endTime.Value);
        end
        function setFlowVecTimeseries(obj,val,unit)
            obj.flowVecTimeseries.setValue(val,unit);
        end
        function setXGridPoints(obj,val,unit)
            % Might want to write code here to throw error/warning if it
            % doesn't match preexising dimensions
            obj.xGridPoints.setValue(val,unit)
        end
        function setYGridPoints(obj,val,unit)
            % Might want to write code here to throw error/warning if it
            % doesn't match preexising dimensions
            obj.yGridPoints.setValue(val,unit)
        end
        function setZGridPoints(obj,val,unit)
            % Might want to write code here to throw error/warning if it
            % doesn't match preexising dimensions
            obj.zGridPoints.setValue(val,unit);
        end
        
        function crop(obj,startTime,endTime)
            % Set endTime to max possible value
            endTime = min([endTime ...
                obj.allFlowVecTimeseries.Value.Time(end)]);
            startTime = max([startTime ...
                obj.allFlowVecTimeseries.Value.Time(1)]);
            % --Crop flow velocity vector timeseries--
            ts = getsampleusingtime(obj.allFlowVecTimeseries.Value,startTime,endTime);
            ts.Time = ts.Time-ts.Time(1);
            obj.setFlowVecTimeseries(ts,'m/s');
        end
        
        function val = get.maxSpeed(obj)
            val = max(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)),[],'all');
            val = SIM.parameter('Value',val,'Unit','m/s');
        end
        
        function val = get.minSpeed(obj)
            val = min(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)),[],'all');
            val = SIM.parameter('Value',val,'Unit','m/s');
        end
            
        %%  Methods to observe/analyze 
        function h = animateVecs(obj,varargin)
            if numel(obj.flowVecTimeseries.Value.Time)<2
                defaultTimeStep = 3600;
            else
                defaultTimeStep = obj.flowVecTimeseries.Value.Time(2)-obj.flowVecTimeseries.Value.Time(1);
            end
            
            p = inputParser;
            addParameter(p,'Cropped',true,@islogical);
            addParameter(p,'FontSize',get(0,'DefaultAxesFontSize'),@isnumeric);
            addParameter(p,'Title','Manta Flow Speed',@ischar);
            addParameter(p,'TimeUnits','s',@ischar);
            addParameter(p,'TimeStep',defaultTimeStep,@isnumeric);
            addParameter(p,'View',[40 40],@isnumeric);
            addOptional(p,'zIdx',obj.zGridPoints.Value,@isnumeric);
            parse(p,varargin{:})
            
            obj.flowVecTimeseries.Value.resample(obj.flowVecTimeseries.Value.Time(1):p.Results.TimeStep:obj.flowVecTimeseries.Value.Time(end));
            
            switch lower(p.Results.TimeUnits)
                case {'min','m'}
                    denom = 60;
                case {'hr','h'}
                    denom = 3600;
                otherwise
                    denom = 1;
            end
            timeVec = obj.flowVecTimeseries.Value.Time./denom;
            % Find water column with greatest avg flow velocity 
%             [xIdx,yIdx] = obj.colOpt;
            xIdx = 1:7; yIdx = 1:7;
            numTimeSteps = numel(timeVec);
            zIdx = p.Results.zIdx;
            % Plot the initial data
            [x,y,z] = meshgrid(...
                obj.xGridPoints.Value(xIdx),...
                obj.yGridPoints.Value(yIdx),...
                obj.zGridPoints.Value(zIdx));
            x = squeeze(permute(x,[2 1 3]));
            y = squeeze(permute(y,[2 1 3]));
            z = squeeze(permute(z,[2 1 3]));
            figure('units','normalized','outerposition',[0 0 1 1])
            h.vecPlot = quiver3(...
                x,y,z,...
                squeeze(obj.flowVecTimeseries.Value.Data(xIdx,xIdx,zIdx,1,1)),...
                squeeze(obj.flowVecTimeseries.Value.Data(xIdx,xIdx,zIdx,2,1)),...
                squeeze(obj.flowVecTimeseries.Value.Data(xIdx,xIdx,zIdx,3,1)));
            %             daspect([1 1 1])
            xlabel('x [m]')
            ylabel('y [m]')
            zlabel('z [m]')
%             xlim([obj.xGridPoints.Value(xIdx)-500 obj.xGridPoints.Value(xIdx)+500])
%             ylim([obj.yGridPoints.Value(yIdx)-500 obj.yGridPoints.Value(yIdx)+500])
            zlim([-350 0])
            h.title = title(sprintf('Time: %.0f %s',timeVec(1),p.Results.TimeUnits));
            set(findall(gcf,'Type','axes'),'FontSize',p.Results.FontSize);
            view(p.Results.View) % Set view angle azimuth and elevation
            for ii = 2:numTimeSteps
                h.vecPlot.UData = squeeze(obj.flowVecTimeseries.Value.Data(xIdx,xIdx,zIdx,1,ii));
                h.vecPlot.VData = squeeze(obj.flowVecTimeseries.Value.Data(xIdx,xIdx,zIdx,2,ii));
                h.vecPlot.WData = squeeze(obj.flowVecTimeseries.Value.Data(xIdx,xIdx,zIdx,3,ii));
                h.title.String = sprintf('Time: %.0f %s',timeVec(ii),p.Results.TimeUnits);
                drawnow
                pause(.1)
            end
        end
        function h = animateVecs2D(obj,zIdx,varargin)
            if numel(obj.flowVecTimeseries.Value.Time)<2
                defaultTimeStep = 3600;
            else
                defaultTimeStep = obj.flowVecTimeseries.Value.Time(2)-obj.flowVecTimeseries.Value.Time(1);
            end
            
            p = inputParser;
            addParameter(p,'Cropped',true,@islogical);
            addParameter(p,'FontSize',get(0,'DefaultAxesFontSize'),@isnumeric);
            addParameter(p,'Title','Manta Flow Speed',@ischar);
            addParameter(p,'TimeUnits','s',@ischar);
            addParameter(p,'TimeStep',defaultTimeStep,@isnumeric);
            addParameter(p,'View',[40 40],@isnumeric);
            addParameter(p,'GifFile','animation.gif');

            parse(p,varargin{:})
            filename = sprintf('Flow Direction for Month %d.gif',obj.month.Value);
            obj.flowVecTimeseries.Value.resample(obj.flowVecTimeseries.Value.Time(1):p.Results.TimeStep:obj.flowVecTimeseries.Value.Time(end));
            
            switch lower(p.Results.TimeUnits)
                case {'min','m'}
                    denom = 60;
                case {'hr','h'}
                    denom = 3600;
                otherwise
                    denom = 1;
            end
            timeVec = obj.flowVecTimeseries.Value.Time./denom;
            numTimeSteps = numel(timeVec);
            % Plot the initial data
            [x,y] = meshgrid(obj.xGridPoints.Value,obj.yGridPoints.Value);
            x = squeeze(permute(x,[2 1 3]));
            y = squeeze(permute(y,[2 1 3]));
            x = x*1e-3; y = y*1e-3;
            figure()
            set(gcf,'Position',[1 250 1300 420])
            a1 = subplot(1,3,1);
            h.vecPlot = quiver(x,y,...
                squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx(1),1,1)),...
                squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx(1),2,1)),'b');
            xlabel('x [km]');   ylabel('y [km]');
            xlim([-8 8]);       ylim([-8 8]);
            h.title = title( sprintf('Depth: %d m, Time: %.0f %s',...
                    -obj.zGridPoints.Value(zIdx(1)),timeVec(1),p.Results.TimeUnits));
            a2 = subplot(1,3,2);
            h1.vecPlot = quiver(x,y,...
                squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx(2),1,1)),...
                squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx(2),2,1)),'b');
            xlabel('x [km]');   ylabel('y [km]');
            xlim([-8 8]);       ylim([-8 8]);
            h1.title = title( sprintf('Depth: %d m, Time: %.0f %s',...
                    -obj.zGridPoints.Value(zIdx(2)),timeVec(1),p.Results.TimeUnits));
            a3 = subplot(1,3,3);
            h2.vecPlot = quiver(x,y,...
                squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx(3),1,1)),...
                squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx(3),2,1)),'b');
            xlabel('x [km]');   ylabel('y [km]');
            xlim([-8 8]);       ylim([-8 8]);
            h2.title = title( sprintf('Depth: %d m, Time: %.0f %s',...
                    -obj.zGridPoints.Value(zIdx(3)),timeVec(1),p.Results.TimeUnits));
            set(findall(gcf,'Type','axes'),'FontSize',p.Results.FontSize);
            a1.Position = [0.05 0.11 0.27 0.815];
            a2.Position = [0.37 0.11 0.27 0.815];
            a3.Position = [0.69 0.11 0.27 0.815];
            for ii = 1:numTimeSteps
                h.vecPlot.UData = squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx(1),1,ii));
                h.vecPlot.VData = squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx(1),2,ii));
                h1.vecPlot.UData = squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx(2),1,ii));
                h1.vecPlot.VData = squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx(2),2,ii));
                h2.vecPlot.UData = squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx(3),1,ii));
                h2.vecPlot.VData = squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx(3),2,ii));
                h.title.String = sprintf('Depth: %d m, Time: %.0f %s',...
                    -obj.zGridPoints.Value(zIdx(1)),timeVec(ii),p.Results.TimeUnits);
                h1.title.String = sprintf('Depth: %d m, Time: %.0f %s',...
                    -obj.zGridPoints.Value(zIdx(2)),timeVec(ii),p.Results.TimeUnits);
                h2.title.String = sprintf('Depth: %d m, Time: %.0f %s',...
                    -obj.zGridPoints.Value(zIdx(3)),timeVec(ii),p.Results.TimeUnits);
                drawnow
                % Capture the plot as an image
                frame       = getframe(gcf);
                im          = frame2im(frame);
                [imind,cm]  = rgb2ind(im,256);
                % Write to the GIF File
                if ii == 1
                    imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
                else
                    imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',.1);
                end
            end
        end
        function h = animateVecs2Da(obj,zIdx,varargin)
            if numel(obj.flowVecTimeseries.Value.Time)<2
                defaultTimeStep = 3600;
            else
                defaultTimeStep = obj.flowVecTimeseries.Value.Time(2)-obj.flowVecTimeseries.Value.Time(1);
            end
            
            p = inputParser;
            addParameter(p,'Cropped',true,@islogical);
            addParameter(p,'FontSize',get(0,'DefaultAxesFontSize'),@isnumeric);
            addParameter(p,'Title','Manta Flow Speed',@ischar);
            addParameter(p,'TimeUnits','s',@ischar);
            addParameter(p,'TimeStep',defaultTimeStep,@isnumeric);
            addParameter(p,'View',[40 40],@isnumeric);
            addParameter(p,'GifFile','animation.gif');

            parse(p,varargin{:})
            filename = sprintf('Flow Direction at %d m depth for Month %d.gif',-obj.zGridPoints.Value(zIdx),obj.month.Value);
            obj.flowVecTimeseries.Value.resample(obj.flowVecTimeseries.Value.Time(1):p.Results.TimeStep:obj.flowVecTimeseries.Value.Time(end));
            
            switch lower(p.Results.TimeUnits)
                case {'min','m'}
                    denom = 60;
                case {'hr','h'}
                    denom = 3600;
                otherwise
                    denom = 1;
            end
            timeVec = obj.flowVecTimeseries.Value.Time./denom;
            numTimeSteps = numel(timeVec);
            % Plot the initial data
            [x,y] = meshgrid(obj.xGridPoints.Value,obj.yGridPoints.Value);
            x = squeeze(permute(x,[2 1 3]));
            y = squeeze(permute(y,[2 1 3]));
            figure()
            h.vecPlot = quiver(x,y,...
                squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx,1,1)),...
                squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx,2,1)),'b');
            xlabel('x [m]')
            ylabel('y [m]')
            xlim([-8000 8000])
            ylim([-8000 8000])
            h.title = title(sprintf('Time: %.0f %s',timeVec(1),p.Results.TimeUnits));
            set(findall(gcf,'Type','axes'),'FontSize',p.Results.FontSize);
            for ii = 1:numTimeSteps
                h.vecPlot.UData = squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx,1,ii));
                h.vecPlot.VData = squeeze(obj.flowVecTimeseries.Value.Data(:,:,zIdx,2,ii));
                h.title.String = sprintf('Month: %d, Depth: %d, Time: %.0f %s',obj.month.Value,-obj.zGridPoints.Value(zIdx),timeVec(ii),p.Results.TimeUnits);
                drawnow
                % Capture the plot as an image
                frame       = getframe(gcf);
                im          = frame2im(frame);
                [imind,cm]  = rgb2ind(im,256);
                % Write to the GIF File
                if ii == 1
                    imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
                else
                    imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',.1);
                end
            end
        end
        function h = capFactor(obj,vRated,vCutIn,varargin)
            % Parse optional input arguments
            p = inputParser;
            addParameter(p,'BinSize',0.1,@(x) x>0)
            addParameter(p,'NumOfColorBands',5,@(x) mod(x,1)==0);
            addRequired(p,'vRated',@(x) x>0);
            addRequired(p,'vCutIn',@(x) x>0);
            parse(p,vRated,vCutIn,varargin{:})
            % Define the bin edges for the histogram
            binsEdges = 0:p.Results.BinSize:obj.maxSpeed.Value+p.Results.BinSize;
            % Degine the center point of the bins for the histograms
            binCents = (binsEdges(1:end-1)+binsEdges(2:end))/2;
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Loop through every grid point
            CF = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,3));
            avg = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,3));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    for kk = 1:size(flowSpeeds,3)
                        % Get the flow speeds at this grid point
                        vFlows  = squeeze(flowSpeeds(ii,jj,kk,:));
                        vFlows(vFlows<p.Results.vCutIn) = 0;
                        % Calculate the histogram
                        pdf    = histcounts(vFlows,binsEdges,'Normalization','pdf');
                        intArg  = min(binCents.^3,p.Results.vRated.^3).*pdf;
                        CF(ii,jj,kk) = trapz(binCents,intArg)./p.Results.vRated.^3;
                        avg(ii,jj,kk) = mean(vFlows);
                    end
                end
            end
            % Set up meshgrid for plots
            [x,y,z] = meshgrid(...
                obj.xGridPoints.Value,...
                obj.yGridPoints.Value,...
                obj.zGridPoints.Value);
            % Set the colorbands
            colormap([linspace(0,1,p.Results.NumOfColorBands)' zeros(p.Results.NumOfColorBands,1) linspace(1,0,p.Results.NumOfColorBands)'])
            h.scatter3 = scatter3(x(:),y(:),z(:),40,CF(:),'filled');
            h.colorbar = colorbar;
            set(gca,'FontSize',14)
            xlabel('x, [m]')
            ylabel('y, [m]')
            zlabel('z, [m]')
            h.colorbar.Label.String = 'Capacity Factor';
            h.title = title({'Capacity Factor',sprintf('Month %d Day %d',obj.month.Value,obj.day.Value)});
        end
        function h = velFieldAvg(obj,varargin)
            % Parse optional input arguments
            p = inputParser;
            addParameter(p,'BinSize',0.1,@(x) x>0)
            addParameter(p,'NumOfColorBands',20,@(x) mod(x,1)==0);
            parse(p,varargin{:})
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Loop through every grid point
            vFlows = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,3));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    for kk = 1:size(flowSpeeds,3)
                        % Get the flow speeds at this grid point
                        vFlows(ii,jj,kk) = mean(squeeze(flowSpeeds(ii,jj,kk,:)));
                    end
                end
            end
            vFlows(vFlows > 1) = NaN;
            % Set up meshgrid for plots
            [x,y,z] = meshgrid(...
                obj.xGridPoints.Value*1e-3,...
                obj.yGridPoints.Value*1e-3,...
                obj.zGridPoints.Value);
            % Set the colorbands
            colormap([linspace(0,1,p.Results.NumOfColorBands)' zeros(p.Results.NumOfColorBands,1) linspace(1,0,p.Results.NumOfColorBands)'])
            h.scatter3 = scatter3(x(:),y(:),z(:),40,vFlows(:),'filled');
            h.colorbar = colorbar;
            set(gca,'FontSize',14)
            xlabel('x [km]')
            ylabel('y [km]')
            zlabel('z [m]')
            h.colorbar.Label.String = 'Flow Speed [m/s]';
            caxis([0 0.5]);
            h.color.limits = [0 0.5];
            set(gca,'View',[-7 30])
%             h.title = title(['Average Flow Speeds $-$ ',sprintf('Month %d',obj.month.Value)]);
        end
        function h = velField(obj,varargin)
            % Parse optional input arguments
            p = inputParser;
            addParameter(p,'BinSize',0.1,@(x) x>0)
            addParameter(p,'NumOfColorBands',20,@(x) mod(x,1)==0);
            parse(p,varargin{:})
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Loop through every grid point
            vFlows = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,3));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    for kk = 1:size(flowSpeeds,3)
                        % Get the flow speeds at this grid point
                        vFlows(ii,jj,kk) = mean(squeeze(flowSpeeds(ii,jj,kk,:)));
                    end
                end
            end
            vFlows1 = vFlows(:,:,23:27);
            % Set up meshgrid for plots
            [x1,y1,z1] = meshgrid(obj.xGridPoints.Value*1e-3,obj.yGridPoints.Value*1e-3,obj.zGridPoints.Value(1:22));
            [x2,y2,z2] = meshgrid(obj.xGridPoints.Value*1e-3,obj.yGridPoints.Value*1e-3,obj.zGridPoints.Value(28));
            [x,y,z] = meshgrid(obj.xGridPoints.Value*1e-3,obj.yGridPoints.Value*1e-3,obj.zGridPoints.Value(23:27));
            % Set the colorbands
%             colormap([linspace(0,1,p.Results.NumOfColorBands)' zeros(p.Results.NumOfColorBands,1) linspace(1,0,p.Results.NumOfColorBands)'])
            colormap([zeros(p.Results.NumOfColorBands,1) zeros(p.Results.NumOfColorBands,1) linspace(1,0,p.Results.NumOfColorBands)'])
            scatter3(x1(:),y1(:),z1(:),40,[.75 .75 .75],'filled'); hold on
            scatter3(x2(:),y2(:),z2(:),40,[0 0 0],'filled'); hold on
            scatter3(x(:),y(:),z(:),40,vFlows1(:),'filled');
%             h.colorbar = colorbar;
            set(gca,'FontSize',14)
            xlabel('x [km]')
            ylabel('y [km]')
            zlabel('z [m]')
            zlim([-500 0])
            h.colorbar.Label.String = 'Flow Speed [m/s]';
%             h.title = title(['Average Flow Speeds $-$ ',sprintf('Month %d',obj.month.Value)]);
        end
        function h = velPDF(obj,xIdx,yIdx,varargin)
            % Parse optional input arguments
            p = inputParser;
            addParameter(p,'BinSize',0.1,@(x) x>0)
            addParameter(p,'NumOfColorBands',10,@(x) mod(x,1)==0);
            parse(p,varargin{:})
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Get mean flow velocity along each column
            colAvg = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    colAvg(ii,jj) = mean(squeeze(flowSpeeds(ii,jj,:,:)),'all');
                end
            end
            % Get velocities at the grid points of interest 
            zIdx = [15 20 22 23 24 25];
            colVel = squeeze(flowSpeeds(xIdx,yIdx,zIdx,:));
            % Plot Histograms
            h = figure();
            for ii = 1:6
                subplot(3,2,ii);
                hold on;    grid on 
                b = histogram(colVel(ii,:),20,'Normalization','probability');
                set(b,'FaceColor','b'); set(b,'EdgeColor','b')
                set(gca,'FontSize',12)
                YL = get(gca,'YLim');
                plot([mean(colVel(ii,:)) mean(colVel(ii,:))],[0 50],'r-','linewidth',2)
                set(gca,'YLim',YL)
                if ii >= 5
                    xlabel('Velocity [m/s]');
                end
                title(['Depth = ',num2str(-obj.zGridPoints.Value(zIdx(ii))),' m'])
            end
        end
        function h = velPDFstar(obj,varargin)
            % Parse optional input arguments
            p = inputParser;
            addParameter(p,'BinSize',0.1,@(x) x>0)
            addParameter(p,'NumOfColorBands',10,@(x) mod(x,1)==0);
            addOptional(p,'zIdx',23:25,@(x) isnumeric(x));
            addOptional(p,'newFig',true,@(x) islogical(x));
            addOptional(p,'title',true,@(x) islogical(x));
            parse(p,varargin{:})
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Find water column with greatest avg flow velocity 
            [xIdx,yIdx] = obj.colOpt;
            % Get velocities at the grid points of interest 
            zIdx = p.Results.zIdx;
            colVels = squeeze(flowSpeeds(xIdx,yIdx,zIdx,:));
            % Plot Histograms
            if p.Results.newFig
                h = figure();
            else
                h = gca;
            end
            for ii = 1:numel(zIdx)
                if p.Results.newFig
                    subplot(numel(zIdx),1,ii);
                end
                hold on;    grid on 
                if numel(zIdx) == 1
                    r = histogram(colVels(:),20,'Normalization','probability');
                    Vavg = mean(colVels(:));
                else
                    r = histogram(colVels(ii,:),20,'Normalization','probability');
                    Vavg = mean(colVels(ii,:));
                end
                set(r,'FaceColor','b'); set(r,'EdgeColor','b')
                set(gca,'FontSize',12)
                YL = get(gca,'YLim');
                plot([Vavg Vavg],[0 50],'r-','linewidth',2)
                set(gca,'YLim',[0 0.5]); set(gca,'XLim',[0 0.5]); set(gca,'XTick',[0:.1:.5])
                ylabel('Probability')
                if ii >= numel(zIdx)
                    xlabel('Velocity [m/s]');
                end
                if p.Results.title
                    title(['Depth = ',num2str(-obj.zGridPoints.Value(zIdx(ii))),' m'])
                end
            end
        end
        function h = timeScale(obj,varargin)
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Find water column with greatest avg flow velocity 
            [xIdx,yIdx] = obj.colOpt;
            zIdx = [20 23 25];
            % Get velocities at the grid points of interest 
            Vel = squeeze(flowSpeeds(xIdx,yIdx,zIdx,:));
            Time = linspace(obj.startTime.Value,obj.endTime.Value,length(Vel(1,:)))/3600;
            % Plot FFT results
            h = figure();
            for ii = 1:numel(zIdx)
                subplot(2,3,ii);    hold on;    grid on;
                plot(Time,Vel(ii,:),'b-');     xlabel('Time [hr]');
                if ii == 1
                    ylabel('$v_w$ [m/s]');  
                end
                set(gca,'FontSize',12)
                title(['Depth = ',num2str(-obj.zGridPoints.Value(zIdx(ii))),' m'])
                %%%% Matlab FFT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                N = length(Vel(ii,:));  fs = 1/3600;
                X = fft(Vel(ii,:),N);   df = fs/N;
                sampleIndex = 0:N-1;    f1 = sampleIndex*df;
                subplot(2,3,ii+3);    hold on;    grid on
                plot(1./f1/3600,abs(X),'b-');
                xlabel('$1/\omega$/3600 [hr]');
                set(gca,'FontSize',12)
                if ii == 1 
                    ylabel('$|\mathrm{DFT}(v_w)|$');
                end
            end
        end
        function h = velXYZ(obj,varargin)
            % Find water column with greatest avg flow velocity 
            [xIdx,yIdx] = obj.colOpt;
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            xFlow = squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,1,:));
            yFlow = squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,2,:));
            zFlow = squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,3,:));
            zIdx = [20 23 25];
            % Get velocities at the grid points of interest 
            Vel = squeeze(flowSpeeds(xIdx,yIdx,zIdx,:));
            xVel = squeeze(xFlow(xIdx,yIdx,zIdx,:));
            yVel = squeeze(yFlow(xIdx,yIdx,zIdx,:));
            zVel = squeeze(zFlow(xIdx,yIdx,zIdx,:));
            Time = linspace(obj.startTime.Value,obj.endTime.Value,length(Vel(1,:)))/3600;
            % Plot FFT results
            h = figure();
            for ii = 1:length(zIdx)
                subplot(3,3,ii);    hold on;    grid on;
                plot(Time,xVel(ii,:),'b-');
                ylabel('$v_x$ [m/s]');
                title(['Depth = ',num2str(-obj.zGridPoints.Value(zIdx(ii))),' m'])
                subplot(3,3,ii+3);    hold on;    grid on;
                plot(Time,yVel(ii,:),'b-');
                ylabel('$v_y$ [m/s]');
                subplot(3,3,ii+6);    hold on;    grid on;
                plot(Time,zVel(ii,:),'b-');
                ylabel('$v_z$ [m/s]');
                xlabel('Time [hr]');
            end
        end
        function [xIdx,yIdx] = colOpt(obj,varargin)
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Get mean flow velocity along each column
            colAvg = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    colAvg(ii,jj) = mean(squeeze(flowSpeeds(ii,jj,:,:)),'all');
                end
            end
            [xIdx,yIdx] = find(max(max(colAvg))==colAvg);
        end
        function h = velVec(obj,zIdx,varargin)
            % Calculate flow speed at every point in the grid
            xFlow = squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,1,:));
            yFlow = squeeze(obj.flowVecTimeseries.Value.Data(:,:,:,2,:));
            % Find water column with greatest avg flow velocity 
            [xIdx,yIdx] = obj.colOpt;
            tIdx = (1:3:25)+0;
            % Get velocities at the grid points of interest 
            X = obj.xGridPoints.Value*1e-3;
            Y = obj.xGridPoints.Value*1e-3;
            U = squeeze(xFlow(:,:,zIdx,tIdx));
            V = squeeze(yFlow(:,:,zIdx,tIdx));
            % Plot velocity vectors
            h = figure();
            for ii = 1:length(tIdx)
                subplot(3,3,ii);    hold on;    grid on;
                quiver(X,Y,U(:,:,ii),V(:,:,ii),'b');
                title(['Hour ',num2str(tIdx(ii))])
                if ii > 6
                    xlabel('X [km]');
                end
                if ii == 1 || ii == 4 || ii == 7
                    ylabel('Y [km]');
                end
                xlim([X(xIdx)-2 X(xIdx)+2]);    ylim([Y(yIdx)-2 Y(yIdx)+2])
%                 xlim([X(xIdx)-2 X(xIdx)+2]);    ylim([Y(yIdx)-2 Y(yIdx)+2])
            end
        end
        function h = velPDFstar1(obj,varargin)
            % Parse optional input arguments
            p = inputParser;
            addParameter(p,'BinSize',0.1,@(x) x>0)
            addParameter(p,'NumOfColorBands',10,@(x) mod(x,1)==0);
            parse(p,varargin{:})
            % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Find water column with greatest avg flow velocity 
            [xIdx,yIdx] = obj.colOpt;
            % Get velocities at the grid points of interest 
            zIdx = [20 23 25];
            colVels = squeeze(flowSpeeds(xIdx,yIdx,zIdx,:));
            % Plot Histograms
            h = figure();
            for ii = 1:3
                subplot(1,3,ii);
                hold on;    grid on 
                r = histogram(colVels(ii,:),20,'Normalization','probability');
                set(r,'FaceColor','b'); set(r,'EdgeColor','b')
                set(gca,'FontSize',12)
                plot([mean(colVels(ii,:)) mean(colVels(ii,:))],[0 50],'r-','linewidth',2)
                set(gca,'XLim',[0 .5])
                set(gca,'YLim',[0 .15])
                xlabel('Velocity [m/s]');
                title(['Depth = ',num2str(-obj.zGridPoints.Value(zIdx(ii))),' m'])
                if ii == 1
                    ylabel('Probability')
                end
            end
        end
        function [h,dOpt] = powPDFconstDepth(obj,vC,pC,aC,dC,varargin)
            p = inputParser;
            addParameter(p,'xLim',[0 inf],@isnumeric);
            addParameter(p,'yLim',[0 1],@isnumeric);
            addParameter(p,'mon',1,@isnumeric);
            parse(p,varargin{:})
            N = numel(obj.flowVecTimeseries.Value.Data(1,1,1,1,:));
             % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Loop through every grid point
            pow = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,3),N);
            vel = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,3),N);
            pAvg = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,3));
            pMax = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            dOpt = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    for kk = 1:size(flowSpeeds,3)
                        alt = dC(ii,jj)+obj.zGridPoints.Value(kk);
                        if alt > 0 && alt <= 300 && obj.zGridPoints.Value(kk) <= -200 && dC(ii,jj) 
                            for ll = 1:N
                                vel(ii,jj,kk,ll) = sqrt(sum(obj.flowVecTimeseries.Value.Data(ii,jj,kk,:,ll).^2));
                                pow(ii,jj,kk,ll) = interp1(vC,pC(:,aC==alt),vel(ii,jj,kk,ll),'linear','extrap');
                            end
                            pAvg(ii,jj,kk) = mean(pow(ii,jj,kk,:));
                        else
                            vel(ii,jj,kk,:) = NaN;
                            pow(ii,jj,kk,:) = NaN;
                            pAvg(ii,jj,kk) = NaN;
                        end
                    end
                    pMax(ii,jj) = max(pAvg(ii,jj,:));
                    dOpt(ii,jj) = -obj.zGridPoints.Value(pAvg(ii,jj,:)==pMax(ii,jj));
                end
            end
            p25 = prctile(pMax,25,'all');
            p50 = prctile(pMax,50,'all');
            p75 = prctile(pMax,75,'all');
            p95 = prctile(pMax,95,'all');
            hold on; grid on;
            h = histogram(pMax,'Normalization','probability');  h.FaceColor = [0,0,1];
            plot([p25 p25],[0 1],'r-')
            plot([p50 p50],[0 1],'r-')
            plot([p75 p75],[0 1],'r-')
            plot([p95 p95],[0 1],'r-')
            xlabel('Power [kW]');  ylabel('Probability');  xlim(p.Results.xLim);  ylim(p.Results.yLim);
            Title = {'January','February','March','April','May','June','July','August','September','October','November','December'};
            mon = Title{p.Results.mon};
            title(sprintf('%s',mon));
        end
        function [h,vMax,dMax,aMax,pMax,Pct] = powPDFinstDepth(obj,vC,pC,aC,dC,varargin)
            p = inputParser;
            addParameter(p,'xLim',[0 inf],@isnumeric);
            addParameter(p,'yLim',[0 1],@isnumeric);
            addParameter(p,'mon',1,@isnumeric);
            parse(p,varargin{:})
            N = numel(obj.flowVecTimeseries.Value.Data(1,1,1,1,:));
             % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Loop through every grid point
            pow = zeros(size(flowSpeeds,1),size(flowSpeeds,2),N,size(flowSpeeds,3));
            vel = zeros(size(flowSpeeds,1),size(flowSpeeds,2),N,size(flowSpeeds,3));
            pAvg = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            pMax = zeros(size(flowSpeeds,1),size(flowSpeeds,2),N);
            vMax = zeros(size(flowSpeeds,1),size(flowSpeeds,2),N);
            dMax = zeros(size(flowSpeeds,1),size(flowSpeeds,2),N);
            aMax = zeros(size(flowSpeeds,1),size(flowSpeeds,2),N);
            for ii = 1:7
                for jj = 1:7
                    for ll = 1:336
                        for kk = 1:numel(obj.zGridPoints.Value)
                            alt = dC(ii,jj)+obj.zGridPoints.Value(kk);
                            if alt > 0 && alt <= 300 && obj.zGridPoints.Value(kk) <= -200
                                vel(ii,jj,ll,kk) = sqrt(sum(obj.flowVecTimeseries.Value.Data(ii,jj,kk,:,ll).^2));
                                pow(ii,jj,ll,kk) = interp1(vC,pC(:,aC==alt),vel(ii,jj,ll,kk),'linear','extrap');
                            else
                                vel(ii,jj,ll,kk) = NaN;
                                pow(ii,jj,ll,kk) = NaN;
                            end
                        end
                        pMax(ii,jj,ll) = max(pow(ii,jj,ll,:));
                        vMax(ii,jj,ll) = vel(ii,jj,ll,pMax(ii,jj,ll)==pow(ii,jj,ll,:));
                        dMax(ii,jj,ll) = -obj.zGridPoints.Value(pMax(ii,jj,ll)==pow(ii,jj,ll,:));
                        aMax(ii,jj,ll) = dC(ii,jj)-dMax(ii,jj,ll);
                    end
                    pAvg(ii,jj) = squeeze(mean(pMax(ii,jj,:)));
                end
            end
            p25 = prctile(pAvg,25,'all');
            p50 = prctile(pAvg,50,'all');
            p75 = prctile(pAvg,75,'all');
            p95 = prctile(pAvg,95,'all');
            Pct = [p25;p50;p75;p95];
            h = 0;
%             hold on; grid on;
%             h = histogram(pAvg,'Normalization','probability');  h.FaceColor = [0,0,1];
%             plot([p25 p25],[0 1],'r-')
%             plot([p50 p50],[0 1],'r-')
%             plot([p75 p75],[0 1],'r-')
%             plot([p95 p95],[0 1],'r-')
%             xlabel('Power [kW]');  ylabel('Probability');  xlim(p.Results.xLim);  ylim(p.Results.yLim);
%             Title = {'January','February','March','April','May','June','July','August','September','October','November','December'};
%             mon = Title{p.Results.mon};
%             title(sprintf('%s',mon));
        end
        function h = powPDFoptDepth(obj,Odepth,vC,pC,aC,varargin)
            p = inputParser;
            addParameter(p,'xLim',[0 inf],@isnumeric);
            addParameter(p,'yLim',[0 1],@isnumeric);
            parse(p,varargin{:})
             % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Loop through every grid point
            D = [200 250 300];  
            vFlows = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,4));
            Dopt = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,4));
            Popt = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,4));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    for kk = 1:size(flowSpeeds,4)
                        vD = squeeze(flowSpeeds(ii,jj,23:25,kk));
                        for ll = 1:3
                            alt0 = Odepth+obj.zGridPoints.Value(22+ll);
                            v = vD(ll);
                            if v < 0.1
                                Pt(ll) = 0;
                            elseif v > 0.5
                                Pt(ll) = max(pC(:,aC==alt0));
                            else
                                Pt(ll) = interp1(vC,pC(:,aC==alt0),v,'linear','extrap');
                            end
                        end
                        Dopt(ii,jj,kk) = min(D(max(Pt)==Pt));
                        vFlows(ii,jj,kk) = min(vD(max(Pt)==Pt));
                        Popt(ii,jj,kk) = min(Pt(max(Pt)==Pt));
                    end
                end
            end
            vAvg = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            Pavg = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    vAvg(ii,jj) = mean(vFlows(ii,jj,:));
                    Pavg(ii,jj) = mean(Popt(ii,jj,:));
                end
            end

            p50 = prctile(Pavg,50,'all');
            p75 = prctile(Pavg,75,'all');
            p95 = prctile(Pavg,95,'all');
            hold on; grid on;
            h = histogram(Pavg,'Normalization','probability');  h.FaceColor = [0,0,1];
            plot([p50 p50],[0 1],'r-')
            plot([p75 p75],[0 1],'r-')
            plot([p95 p95],[0 1],'r-')
            xlabel('Power [kW]');  ylabel('Probability');  xlim(p.Results.xLim);  ylim(p.Results.yLim);
%             if obj.month.Value == 1
%                 mon = 'January';
%             elseif obj.month.Value == 4
%                 mon = 'April';
%             elseif obj.month.Value == 7
%                 mon = 'July';
%             elseif obj.month.Value == 10
%                 mon = 'October';
%             end
%             title(sprintf('%s',mon));

        end
        function [Pout,vout,Dout] = powOptDepth(obj,vC,pC,aC,varargin)
            p = inputParser;
            addParameter(p,'pct',95,@isnumeric);
            parse(p,varargin{:})
             % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Loop through every grid point
            vFlows1 = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,3));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    for kk = 1:size(flowSpeeds,3)
                        % Get the flow speeds at this grid point
                        vFlows1(ii,jj,kk) = mean(squeeze(flowSpeeds(ii,jj,kk,:)));
                    end
                end
            end
            vFlows1(vFlows1 > 1) = NaN;
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    vCol = squeeze(vFlows1(ii,jj,:));
                    if isempty(find(isnan(vCol),1,'first'))
                        iBot(ii,jj) = length(obj.zGridPoints.Value)+1;
                        Odepth(ii,jj) = min(obj.zGridPoints.Value);
                    else
                        iBot(ii,jj) = find(isnan(vCol),1,'first');
                        Odepth(ii,jj) = obj.zGridPoints.Value(iBot(ii,jj));
                    end
                end
            end
            % Loop through every grid point
            vFlows = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,4));
            Dopt = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,4));
            Popt = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,4));
            altMax = find(obj.zGridPoints.Value==-200);
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    for kk = 1:size(flowSpeeds,4)
                        ran = altMax:iBot(ii,jj)-1;
                        vD = squeeze(flowSpeeds(ii,jj,ran,kk));
                        for ll = 1:length(vD)
                            alt0(ll) = obj.zGridPoints.Value(altMax-1+ll)-Odepth(ii,jj);
                            v = vD(ll);
                            if v < 0.1 || alt0(ll)<aC(1)
                                Pt(ll) = 0;
                            elseif v > 0.5
                                Pt(ll) = max(pC(:,aC==alt0(ll)));
                            else
                                Pt(ll) = interp1(vC,pC(:,aC==alt0(ll)),v,'linear','extrap');
                            end
                        end
                        
                        Dopt(ii,jj,kk) = min(alt0(max(Pt)==Pt));
                        vFlows(ii,jj,kk) = min(vD(max(Pt)==Pt));
                        Popt(ii,jj,kk) = min(Pt(max(Pt)==Pt));
                    end
                end
            end
            vAvg = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            Pavg = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    vAvg(ii,jj) = mean(vFlows(ii,jj,:));
                    Pavg(ii,jj) = mean(Popt(ii,jj,:));
                end
            end
            
            Pout = prctile(Pavg,p.Results.pct,'all');
            row = [];   thresh = 0.0001;
            while isempty(row)
                [row,col] = find(abs(Pavg-Pout)<=thresh,1,'first');
                if thresh <= 0.01
                    thresh = thresh*10;
                else
                    thresh = thresh+.01;
                end
            end
            vout = vAvg(row,col);
            Dout = [row;col];
        end
        function [Pavg,vAvg] = powOptInstDepth(obj,vC,pC,aC,varargin)
            p = inputParser;
            addParameter(p,'pct',95,@isnumeric);
            parse(p,varargin{:})
             % Calculate flow speed at every point in the grid
            flowSpeeds = squeeze(sqrt(sum(obj.flowVecTimeseries.Value.Data.^2,4)));
            % Loop through every grid point
            vFlows1 = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,3));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    for kk = 1:size(flowSpeeds,3)
                        % Get the flow speeds at this grid point
                        vFlows1(ii,jj,kk) = mean(squeeze(flowSpeeds(ii,jj,kk,:)));
                    end
                end
            end
            vFlows1(vFlows1 > 1) = NaN;
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    vCol = squeeze(vFlows1(ii,jj,:));
                    if isempty(find(isnan(vCol),1,'first'))
                        iBot(ii,jj) = length(obj.zGridPoints.Value)+1;
                        Odepth(ii,jj) = min(obj.zGridPoints.Value);
                    else
                        iBot(ii,jj) = find(isnan(vCol),1,'first');
                        Odepth(ii,jj) = obj.zGridPoints.Value(iBot(ii,jj));
                    end
                end
            end
            % Loop through every grid point
            vFlows = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,4));
            Dopt = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,4));
            Popt = zeros(size(flowSpeeds,1),size(flowSpeeds,2),size(flowSpeeds,4));
            altMax = find(obj.zGridPoints.Value==-200);
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    for kk = 1:size(flowSpeeds,4)
                        ran = altMax:iBot(ii,jj)-1;
                        vD = squeeze(flowSpeeds(ii,jj,ran,kk));
                        for ll = 1:length(vD)
                            alt0(ll) = obj.zGridPoints.Value(altMax-1+ll)-Odepth(ii,jj);
                            v = vD(ll);
                            if v < 0.1 || alt0(ll)<aC(1)
                                Pt(ll) = 0;
                            elseif v > 0.5
                                Pt(ll) = max(pC(:,aC==alt0(ll)));
                            else
                                Pt(ll) = interp1(vC,pC(:,aC==alt0(ll)),v,'linear','extrap');
                            end
                        end
                        
                        Dopt(ii,jj,kk) = min(alt0(max(Pt)==Pt));
                        vFlows(ii,jj,kk) = min(vD(max(Pt)==Pt));
                        Popt(ii,jj,kk) = min(Pt(max(Pt)==Pt));
                    end
                end
            end
            vAvg = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            Pavg = zeros(size(flowSpeeds,1),size(flowSpeeds,2));
            for ii = 1:size(flowSpeeds,1)
                for jj = 1:size(flowSpeeds,2)
                    vAvg(ii,jj) = mean(vFlows(ii,jj,:));
                    Pavg(ii,jj) = mean(Popt(ii,jj,:));
                end
            end
            
            Pout = prctile(Pavg,p.Results.pct,'all');
            row = [];   thresh = 0.0001;
            while isempty(row)
                [row,col] = find(abs(Pavg-Pout)<=thresh,1,'first');
                if thresh <= 0.01
                    thresh = thresh*10;
                else
                    thresh = thresh+.01;
                end
            end
            vout = vAvg(row,col);
            Dout = [row;col];
        end
    end
end

