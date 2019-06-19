timeStep = 0.5;
fileName = 'animateSim.gif';

% Resample to the animation framerate
timeVec = 0:timeStep:tsc.positionVec.Time(end);
numTethers = numel(tsc.thrNodeBus);
xMin = [];
xMax = [];
yMin = [];
yMax = [];
zMin = [];
zMax = [];
for ii= 1:numTethers
    tsc.thrNodeBus(ii).nodePositions = resample(tsc.thrNodeBus(ii).nodePositions,timeVec);
    tsc.thrAttchPtAirBus(ii).posVec = resample(tsc.thrAttchPtAirBus(ii).posVec,timeVec);
    xMin = min([xMin min(min(squeeze(tsc.thrNodeBus(ii).nodePositions.Data(1,:,:))))]);
    xMax = max([xMax max(max(squeeze(tsc.thrNodeBus(ii).nodePositions.Data(1,:,:))))]);
    yMin = min([yMin min(min(squeeze(tsc.thrNodeBus(ii).nodePositions.Data(2,:,:))))]);
    yMax = max([yMax max(max(squeeze(tsc.thrNodeBus(ii).nodePositions.Data(2,:,:))))]);
    zMin = min([zMin min(min(squeeze(tsc.thrNodeBus(ii).nodePositions.Data(3,:,:))))]);
    zMax = max([zMax max(max(squeeze(tsc.thrNodeBus(ii).nodePositions.Data(3,:,:))))]);
end
tsc.positionVec = resample(tsc.positionVec,timeVec);

% Calculate plot limits
xMin = min([xMin; squeeze(tsc.positionVec.Data(1,:,:))]);
xMax = max([xMax; squeeze(tsc.positionVec.Data(1,:,:))]);
yMin = min([yMin; squeeze(tsc.positionVec.Data(2,:,:))]);
yMax = max([yMax; squeeze(tsc.positionVec.Data(2,:,:))]);
zMin = min([zMin; squeeze(tsc.positionVec.Data(3,:,:))]);
zMax = max([zMax; squeeze(tsc.positionVec.Data(3,:,:))]);

xLim = [xMin xMax];
yLim = [yMin yMax];
zLim = [zMin zMax];

xMid = (xLim(1)+xLim(2))/2;
yMid = (yLim(1)+yLim(2))/2;
zMid = (zLim(1)+zLim(2))/2;

xSpan = xLim(2)-xLim(1);
ySpan = yLim(2)-yLim(1);
zSpan = zLim(2)-zLim(1);

xLim = [xMid-1.1*xSpan/2 xMid+1.1*xSpan/2];
yLim = [yMid-1.1*ySpan/2 yMid+1.1*ySpan/2];
zLim = [zMid-1.1*zSpan/2 zMid+1.1*zSpan/2];


h.fig = figure('Position',[1          41        1920         963]);
for ii = 1:numTethers
    h.thr(ii) = plot3(...
        squeeze(tsc.thrNodeBus(ii).nodePositions.Data(1,:,1)),...
        squeeze(tsc.thrNodeBus(ii).nodePositions.Data(2,:,1)),....
        squeeze(tsc.thrNodeBus(ii).nodePositions.Data(3,:,1)),...
        'LineWidth',1.5,'LineStyle','--','Color','k','Marker','x');
    hold on
    grid on
    axis equal
    h.thrAtch(ii) = plot3(...
        [tsc.positionVec.Data(1,:,1) tsc.thrAttchPtAirBus(ii).posVec.Data(1,:,1)],...
        [tsc.positionVec.Data(2,:,1) tsc.thrAttchPtAirBus(ii).posVec.Data(2,:,1)],...
        [tsc.positionVec.Data(3,:,1) tsc.thrAttchPtAirBus(ii).posVec.Data(3,:,1)],...
        'LineWidth',1.5,'LineStyle','-','Color','r','Marker','o');
    
    hold on
    xlim(xLim)
    ylim(yLim)
    zlim(zLim)
end
h.title = title('Time = 0 s');
h.origin = scatter3(0,0,0,'Marker','o','CData',[0 0 1])
set(gca,'FontSize',24')

frame = getframe(h.fig );
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);

imwrite(imind,cm,fileName,'gif', 'Loopcount',inf);

for ii = 2:length(timeVec)
    h.title.String = sprintf('Time = %.0f',timeVec(ii));
    for jj = 1:numTethers
        h.thr(jj).XData = tsc.thrNodeBus(jj).nodePositions.Data(1,:,ii);
        h.thr(jj).YData = tsc.thrNodeBus(jj).nodePositions.Data(2,:,ii);
        h.thr(jj).ZData = tsc.thrNodeBus(jj).nodePositions.Data(3,:,ii);
        
        h.thrAtch(jj).XData = [tsc.positionVec.Data(1,:,ii) tsc.thrAttchPtAirBus(jj).posVec.Data(1,:,ii)];
        h.thrAtch(jj).YData = [tsc.positionVec.Data(2,:,ii) tsc.thrAttchPtAirBus(jj).posVec.Data(2,:,ii)];
        h.thrAtch(jj).ZData = [tsc.positionVec.Data(3,:,ii) tsc.thrAttchPtAirBus(jj).posVec.Data(3,:,ii)];
        
    end
    xlim(xLim)
    ylim(yLim)
    zlim(zLim)
    drawnow
    frame = getframe(h.fig );
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,fileName,'gif','WriteMode','append');
end