timeStep = 1;
fileName = 'animateSim.gif';

timeVec = 0:timeStep:tsc.winchSpeedCommands.Time(end);

numTethers = numel(tsc.thrNodeBus);
for ii= 1:numTethers
    tsc.thrNodeBus(ii).nodePositions = resample(tsc.thrNodeBus(ii).nodePositions,timeVec);
    tsc.thrAttchPtAirBus(ii).posVec = resample(tsc.thrAttchPtAirBus(ii).posVec,timeVec);
end
tsc.positionVec = resample(tsc.positionVec,timeVec);

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
    zlim([0 205])
    xlim([-10 70])
    ylim([-25 25])
end

set(gca,'FontSize',24')

frame = getframe(h.fig );
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);

imwrite(imind,cm,fileName,'gif', 'Loopcount',inf);

for ii = 2:length(timeVec)
    h.title.String = {caseDescriptor{1},[caseDescriptor{2} sprintf('Time = %.0f',timeVec(ii))]};
    for jj = 1:numTethers
        h.thr(jj).XData = tsc.thrNodeBus(jj).nodePositions.Data(1,:,ii);
        h.thr(jj).YData = tsc.thrNodeBus(jj).nodePositions.Data(2,:,ii);
        h.thr(jj).ZData = tsc.thrNodeBus(jj).nodePositions.Data(3,:,ii);
        
        h.thrAtch(jj).XData = [tsc.positionVec.Data(1,:,ii) tsc.thrAttchPtAirBus(jj).posVec.Data(1,:,ii)];
        h.thrAtch(jj).YData = [tsc.positionVec.Data(2,:,ii) tsc.thrAttchPtAirBus(jj).posVec.Data(2,:,ii)];
        h.thrAtch(jj).ZData = [tsc.positionVec.Data(3,:,ii) tsc.thrAttchPtAirBus(jj).posVec.Data(3,:,ii)];
        
    end
    zlim([0 205])
    xlim([-10 70])
    ylim([-25 25])
    drawnow
    frame = getframe(h.fig );
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,fileName,'gif','WriteMode','append');
end