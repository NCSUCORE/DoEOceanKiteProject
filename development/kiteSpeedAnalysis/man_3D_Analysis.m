clear
clc
close all
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');

%% make instance of class to use its methods
cIn = maneuverabilityAnalysisLibrary;

cIn.aBooth = 0.8;
cIn.bBooth = 1.6;
cIn.tetherLength = 50;
cIn.meanElevationInRadians = 30*pi/180;

res = cIn.analyseFlatEarthRes([1 2]);

subplot(3,1,1)


%% calculate max achievable radius
mass = 3e3;
CL = 0.8;
rho = 1e3;
Aref = 10;
maxTangentRollAngle = [5,10,15,20];

staticVal = mass/(0.5*CL*rho*Aref);
minR = staticVal./sind(maxTangentRollAngle);

colors = 1/255*[55,126,184
    77,175,74
    152,78,163
    255,127,0
    255,255,51];
        
H = gobjects(numel(maxTangentRollAngle),1);
S = strings(numel(maxTangentRollAngle),1);
for ii = 1:numel(maxTangentRollAngle)
    
    
    subplot(3,1,3)
    H(ii)=yline(minR(ii),'--','linewidth',1,...
        'color',colors(ii,:));
    S(ii,:) = strcat("$\phi=$ ",num2str(maxTangentRollAngle(ii)));
end
legend(H(1:end),S(1:end));

set(findobj('-property','FontSize'),'FontSize',11)
