clear
clc
% close all

%% initailize
cIn = maneuverabilityAnalysisLibrary;
cIn.aBooth = 0.3491;
cIn.bBooth = 0.6391;
cIn.tetherLength = 400;
cIn.meanElevationInRadians = 30*pi/180;

% path parameter
pathParam = linspace(0,2*pi,200);
pathRange = pi*[0.5 1.5];

%% get equations
[x,y,z,K] = cIn.derive_3D_Equations();
% find coordinates
for ii = 1:numel(pathParam)
    R(ii) = min(1/max(eps,K(pathParam(ii))),cIn.tetherLength);
    xx(ii) = x(pathParam(ii));
    yy(ii) = y(pathParam(ii));
    zz(ii) = z(pathParam(ii));
end

%% plots
% fig = cIn.findFigureObject('Results');
figure
set(gcf,'Position',[100 0.1 560 2*420]);

subplot(2,1,1);
plot(pathParam,R,'k-','linewidth',1);
grid on
hold on
xlabel('path parameter'); ylabel('R');

subplot(2,1,2);
plot3(xx,yy,zz,'k-','linewidth',1);
hold on
grid on
axis equal
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
cIn.plotDome;
view(100,35);


%% analyze section of plot
nIdx = pathParam>=pathRange(1) &...
    pathParam<=pathRange(2);
subplot(2,1,1)
plot(pathParam(nIdx),R(nIdx),'r-','linewidth',1);
subplot(2,1,2)
plot3(xx(nIdx),yy(nIdx),zz(nIdx),'r-','linewidth',1);


