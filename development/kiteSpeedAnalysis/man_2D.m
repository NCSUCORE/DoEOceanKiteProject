clear
clc

%% initailize
cIn = maneuverabilityAnalysisLibrary;
cIn.aBooth = 0.9;
cIn.bBooth = 2;
cIn.tetherLength = 50;
cIn.meanElevationInRadians = 30*pi/180;

% path parameter
pathParam = linspace(0,2*pi,200);
pathRange = [1 2];

%% get equations
[x,y,K] = cIn.circular_2D_Path();
% find coordinates
for ii = 1:numel(pathParam)
    R(ii) = min(1/max(eps,K(pathParam(ii))),cIn.tetherLength);
    xx(ii) = x(pathParam(ii));
    yy(ii) = y(pathParam(ii));
end

%% plots
fig = cIn.findFigureObject('Results');
set(gcf,'Position',fig.Position.*[1 0.1 1 2]);

subplot(2,1,1);
plot(pathParam,R,'k-','linewidth',1);
grid on
hold on
xlabel('Path parameter'); ylabel('Radius of curvature (m)');

subplot(2,1,2);
plot(xx,yy,'k-','linewidth',1);
hold on
grid on
axis equal
xlabel('X (m)'); ylabel('Y (m)');

%% analyze section of plot
nIdx = pathParam>=pathRange(1) &...
    pathParam<=pathRange(2);
subplot(2,1,1)
plot(pathParam(nIdx),R(nIdx),'r-','linewidth',1);
subplot(2,1,2)
plot(xx(nIdx),yy(nIdx),'r-','linewidth',1);


