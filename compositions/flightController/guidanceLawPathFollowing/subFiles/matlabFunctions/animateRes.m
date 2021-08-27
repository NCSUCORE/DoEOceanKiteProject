function val = animateRes(tsc,cIn)


cIn.tetherLength = 1;
cIn.plotDome; hold on; grid on; view(110,20);
axis equal;
axObj = gca;
xlim(axObj.XLim);
ylim(axObj.YLim);
zlim(axObj.ZLim);

% rgb colors
cols = [228,26,28; 77,175,74; 55,126,184]./255;

%% dummy local variables
tVec = tsc.positionVec.Time(:)';
eulerAng_deg    = squeeze(tsc.eulerAngles.Data)*180/pi;
O_rKite         = squeeze(tsc.positionVec.Data);
O_vKite         = squeeze(tsc.velocityVec.Data);
sphericalCoords = squeeze(tsc.sphericalCoords.Data)';
O_rTarget_n     = squeeze(tsc.rTarget_norm.Data)';
% first time step
% body frame axes
bfAxes = gobjects(3,1);
OcB = calcBcO(eulerAng_deg(:,1)*pi/180)';
n_O_rKite = squeeze(O_rKite)./vecnorm(squeeze(O_rKite));

vecScale = 0.25;
for bxc = 1:3
    bfAxes(bxc) = quiver3(n_O_rKite(1,1),n_O_rKite(2,1),n_O_rKite(3,1),...
        OcB(1,bxc),OcB(2,bxc),OcB(3,bxc),vecScale,'color',cols(bxc,:));
end

% path
O_path = pathCoordEqn(cIn.pathWidth,cIn.pathHeight,cIn.meanElevationInRadians*180/pi,1);
pPath  = plot3(O_path(1,:),O_path(2,:),O_path(3,:),'k-');


% North East Down frame axes
nedAxes = gobjects(3,1);
OcT = calcTcO(sphericalCoords(1,1),sphericalCoords(2,1))';
for nxc = 1:3
    nedAxes(nxc) = quiver3(n_O_rKite(1,1),n_O_rKite(2,1),n_O_rKite(3,1),...
        OcT(1,nxc),OcT(2,nxc),OcT(3,nxc),vecScale,'linestyle','--','color',cols(nxc,:));
end

% velocity
n_O_vKite = squeeze(O_vKite)./vecnorm(squeeze(O_vKite));
pV = quiver3(n_O_rKite(1,1),n_O_rKite(2,1),n_O_rKite(3,1),...
    n_O_vKite(1),n_O_vKite(2),n_O_vKite(3),vecScale,'k-','linewidth',1,...
    'MaxHeadSize',1);

% target point
n_O_rTarg = squeeze(O_rTarget_n)./vecnorm(squeeze(O_rTarget_n));
pTarg = plot3(n_O_rTarg(1,1),n_O_rTarg(2,1),n_O_rTarg(3,1),'m*');

% trajectory
pTraj = animatedline(n_O_rKite(1,1),n_O_rKite(2,1),n_O_rKite(3,1),'color','r');

% title
titleObj = title(sprintf('Time = %.1f sec, Speed = %.2f m/s',...
        [tVec(1),norm(O_vKite(:,1))]));

    waitforbuttonpress;


%% loop over time
for tc = 1:length(tVec)
    
    % update body frame axes
    OcB = calcBcO(eulerAng_deg(:,tc)*pi/180)';
    for bxc = 1:3
        bfAxes(bxc).XData = n_O_rKite(1,tc);
        bfAxes(bxc).YData = n_O_rKite(2,tc);
        bfAxes(bxc).ZData = n_O_rKite(3,tc);
        bfAxes(bxc).UData = OcB(1,bxc);
        bfAxes(bxc).VData = OcB(2,bxc);
        bfAxes(bxc).WData = OcB(3,bxc);
    end
    
    % update path
    O_path = pathCoordEqn(cIn.pathWidth,cIn.pathHeight,cIn.meanElevationInRadians*180/pi,1);
    pPath.XData = O_path(1,:);
    pPath.YData = O_path(2,:);
    pPath.ZData = O_path(3,:);
    
    % update NED axes
    OcT = calcTcO(sphericalCoords(1,tc),sphericalCoords(2,tc))';
    for nxc = 1:3
        nedAxes(nxc).XData = n_O_rKite(1,tc);
        nedAxes(nxc).YData = n_O_rKite(2,tc);
        nedAxes(nxc).ZData = n_O_rKite(3,tc);
        nedAxes(nxc).UData = OcT(1,nxc);
        nedAxes(nxc).VData = OcT(2,nxc);
        nedAxes(nxc).WData = OcT(3,nxc);
    end
    
    % update velocity vec
    pV.XData = n_O_rKite(1,tc);
    pV.YData = n_O_rKite(2,tc);
    pV.ZData = n_O_rKite(3,tc);
    pV.UData = n_O_vKite(1,tc);
    pV.VData = n_O_vKite(2,tc);
    pV.WData = n_O_vKite(3,tc);
    
    % update target
    pTarg.XData = n_O_rTarg(1,tc);
    pTarg.YData = n_O_rTarg(2,tc);
    pTarg.ZData = n_O_rTarg(3,tc);
    
    % update trajectory
    addpoints(pTraj,n_O_rKite(1,tc),n_O_rKite(2,tc),n_O_rKite(3,tc));
    
    % update title
    timeStr = sprintf('Time = %.1f sec',tVec(tc));
    speedStr = sprintf('Speed = %.2f m/s',norm(O_vKite(:,tc)));

    windStr = '';
    
    titleObj.String = [timeStr,', ',speedStr,', ',windStr];
    
    waitforbuttonpress;
    
    
end



end