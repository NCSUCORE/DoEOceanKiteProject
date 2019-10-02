classdef ADCP
    %ADCP
    %   Documentation on 'ADCP.mat' is located in the documentation folder
    %   under ADCP_data_README.pdf
    
    properties
        dateTimes
        timeVec
        flowVecTSeries
        flowDirTSeries
        depths
    end
    
    methods
        function obj = ADCP % Constructor
            load(fullfile(which('ADCPData.mat')));
            % Create vector of datetimes, t = datetime(Y,M,D,H,MI,S), see
            % https://www.mathworks.com/help/matlab/ref/datetime.html#d117e274976
            obj.dateTimes = datetime(SerYear+2000,SerMon,SerDay,SerHour,SerMin,SerSec,SerHund*0.1);
            % Get time steps
            obj.timeVec   = seconds(obj.dateTimes-obj.dateTimes(1));
            data = cat(3,SerEmmpersec./1000,SerNmmpersec./1000,SerVmmpersec./1000);
            data = permute(data,[3 2 1]);
            obj.flowVecTSeries = timeseries(data,obj.timeVec);
            obj.flowVecTSeries.UserData.Description = 'At each time step 3x62 matrix.  Columns correspond to depths, rows correspond to east, north and up directions.';
            obj.flowDirTSeries = timeseries(SerDir10thDeg',obj.timeVec);
            obj.depths = RDIBin1Mid-RDIBinSize/2:RDIBinSize:RDIBin1Mid+RDIBinSize*(SerBins(end)-1)-RDIBinSize/2;
        end
        
        function animate(obj)
            figure
            subplot(1,4,1);
            h.magPlot = plot(sqrt(sum(obj.flowVecTSeries.Data(:,:,1).^2)),obj.depths,...
                'LineWidth',1.5,'Color','k');
            grid on
            xlabel('Speed [m/s]')
            ylabel('Height from sea floor [m]')
            
            subplot(1,4,2);
            h.EPlot = plot(obj.flowVecTSeries.Data(1,:,1),obj.depths,...
                'LineWidth',1.5,'Color','k');
            grid on
            xlabel('$v_x$ [m/s]')
            ylabel('Height from sea floor [m]')
            
            subplot(1,4,3);
            h.NPlot = plot(obj.flowVecTSeries.Data(2,:,1),obj.depths,...
                'LineWidth',1.5,'Color','k');
            grid on
            xlabel('$v_y$ [m/s]')
            ylabel('Height from sea floor [m]')
            
            subplot(1,4,4);
            h.ZPlot = plot(obj.flowVecTSeries.Data(3,:,1),obj.depths,...
                'LineWidth',1.5,'Color','k');
            grid on
            xlabel('$v_z$ [m/s]')
            ylabel('Height from sea floor [m]')
            
            h.title = annotation('textbox', [0 0.875 1 0.1], ...
                'String', datestr(obj.dateTimes(1),'dd-mmm-yyyy HH:MM:SS'), ...
                'EdgeColor', 'none', ...
                'HorizontalAlignment', 'center',...
                'FontSize',22);
            
            linkaxes(findall(gcf,'Type','axes'),'xy')
            xlim([-5 5])
            set(findall(gcf,'Type','axes'),'FontSize',16)
            
            for ii = 2:size(obj.flowVecTSeries.Data,3)
                h.title.String = datestr(obj.dateTimes(ii),'dd-mmm-yyyy HH:MM:SS');
                h.magPlot.XData = sqrt(sum(obj.flowVecTSeries.Data(:,:,ii).^2));
                h.EPlot.XData = obj.flowVecTSeries.Data(1,:,ii);
                h.NPlot.XData = obj.flowVecTSeries.Data(2,:,ii);
                h.ZPlot.XData = obj.flowVecTSeries.Data(3,:,ii);
                drawnow
            end
        end
        
    end
end

