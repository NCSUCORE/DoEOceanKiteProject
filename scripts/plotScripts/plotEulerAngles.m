function plotEulerAngles(varargin)

if nargin<1
    tsc = evalin('caller','tsc');
end

figure('Name','Euler Angles');

h.ax1 = subplot(3,1,1);

h.ax2 = subplot(3,1,2);

h.ax3 = subplot(3,1,3);

set(findall(gcf,'Type','axes'),...
    'FontSize',20,...
    'NextPlot','add',...
    'XGrid','on',...
    'YGrid','on')

h.ax1.XLabel.String = 'Time, [s]';
h.ax2.XLabel.String = 'Time, [s]';
h.ax3.XLabel.String = 'Time, [s]';

h.ax1.YLabel.String = 'Roll, [deg]';
h.ax2.YLabel.String = 'Pitch, [deg]';
h.ax3.YLabel.String = 'Yaw, [deg]';

linkaxes(findall(gcf,'Type','axes'),'x')

for ii = 1:nargin
    % Plot roll (and possibly roll setpoint)
    plot(h.ax1,...
        varargin{ii}.eulerAngles.Time,...
        squeeze(varargin{ii}.eulerAngles.Data(1,:,:))*180/pi,...
        'Color','k','LineWidth',1.5)
    try
        plot(h.ax1,tsc.rollSetpoint.Time,squeeze(tsc.rollSetpoint.Data),...
            'LineStyle','--','Color',[1 0 0] ,'LineWidth',1.5)
    catch
    end
    
    % Plot pitch (and possibly pitch setpoint)
    subplot(3,1,2)
    plot(h.ax2,...
        varargin{ii}.eulerAngles.Time,...
        squeeze(varargin{ii}.eulerAngles.Data(2,:,:))*180/pi,...
       'Color','k','LineWidth',1.5)
    
    try
        plot(h.ax2,tsc.pitchSetpoint.Time,squeeze(tsc.pitchSetpoint.Data),...
            'LineStyle','--','Color',[1 0 0] ,'LineWidth',1.5)
    catch
    end
        
    % Plot yaw
    subplot(3,1,3)
    plot(h.ax3,...
        varargin{ii}.eulerAngles.Time,...
        squeeze(varargin{ii}.eulerAngles.Data(3,:,:))*180/pi,...
        'Color','k','LineWidth',1.5)
end

