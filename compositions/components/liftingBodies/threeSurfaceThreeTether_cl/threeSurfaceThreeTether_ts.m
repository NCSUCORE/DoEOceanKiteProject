close all;clear;clc
format compact

% External influences
ailDefl = -1*pi/180;
elevDefl = 1*pi/180;
rudDefl = 1*pi/180;

thr1TenVec = [0 0 0];
thr2TenVec = [0 0 0];
thr3TenVec = [0 0 0];

vWindVec = [1 0 -0.1];

% Plant parameters
fuselageLength = 10;
span = 10;

rho = 1000;
vol = 1;
grav = 9.81;

thr1Pt = [1 0 0];
thr2Pt = [0 1 0];
thr3Pt = [0 -1 0];
cm2cbVec = [0.5 0 0];

mass = 1;

intertiaMatrix = eye(3);

initPos = [0 0 0];
initVel = [0 0 0];
initEul = [45 0 0]*pi/180;
initEulRate = [0 0 0];

prtAC = [0 -span/2 0];
prtRotVec = [0 1 0];
prtChord = [1 0 0];
prtRefArea = 1;
prtLiftCoeffFitParams = [(1/10)*2*pi 0];
prtDragCoeffFitParams = [0.05/((15*2*pi/180)^2) 0 0.01];

sbdAC = [0 span/2 0];
sbdRotVec = [0 1 0];
sbdChord = [1 0 0];
sbdRefArea = 1;
sbdLiftCoeffFitParams = [(1/10)*2*pi 0];
sbdDragCoeffFitParams = [0.05/((15*2*pi/180)^2) 0 0.01];

hStabAC = [fuselageLength 0 0];
hStabRotVec = [0 1 0];
hStabChord = [1 0 0];
hStabRefArea = 1;
hStabLiftCoeffFitParams = [(1/10)*2*pi 0];
hStabDragCoeffFitParams = [0.05/((15*2*pi/180)^2) 0 0.01];

vStabAC = [fuselageLength 0 0.5];
vStabRotVec = [0 0 1];
vStabChord = [1 0 0];
vStabRefArea = 1;
vStabLiftCoeffFitParams = [(1/10)*2*pi 0];
vStabDragCoeffFitParams = [0.05/((15*pi/180)^2) 0 0.01];

%%
sim('threeSurfaceThreeTether_th')
%%


prtLiftVec = logsout.getElement('prtLiftVec').Values.Data;
prtDragVec = logsout.getElement('prtDragVec').Values.Data;

sbdLiftVec = logsout.getElement('sbdLiftVec').Values.Data;
sbdDragVec = logsout.getElement('sbdDragVec').Values.Data;

hStabLiftVec = logsout.getElement('hStabLiftVec').Values.Data;
hStabDragVec = logsout.getElement('hStabDragVec').Values.Data;

vStabLiftVec = logsout.getElement('vStabLiftVec').Values.Data;
vStabDragVec = logsout.getElement('vStabDragVec').Values.Data;

FBuoy = logsout.getElement('FBuoy').Values.Data;
FNetGrav = logsout.getElement('FNetGrav').Values.Data;
vWindBdy = logsout.getElement('vWindBdy').Values.Data;


figure('Position',[0    0.0370    1.0000    0.8917])

plot3(...
    [prtAC(1) prtAC(1) + prtLiftVec(1)],...
    [prtAC(2) prtAC(2) + prtLiftVec(2)],...
    [prtAC(3) prtAC(3) + prtLiftVec(3)],'Color',[0 0.5 0],'LineWidth',2,...
    'LineStyle','-');
grid on
hold on
plot3(...
    [sbdAC(1) sbdAC(1) + sbdLiftVec(1)],...
    [sbdAC(2) sbdAC(2) + sbdLiftVec(2)],...
    [sbdAC(3) sbdAC(3) + sbdLiftVec(3)],'Color',[0 0.5 0],'LineWidth',2,...
    'LineStyle','-');
plot3(...
    [vStabAC(1) vStabAC(1) + vStabLiftVec(1)],...
    [vStabAC(2) vStabAC(2) + vStabLiftVec(2)],...
    [vStabAC(3) vStabAC(3) + vStabLiftVec(3)],'Color',[0 0.5 0],'LineWidth',2,...
    'LineStyle','-');

plot3(...
    [hStabAC(1) hStabAC(1) + hStabLiftVec(1)],...
    [hStabAC(2) hStabAC(2) + hStabLiftVec(2)],...
    [hStabAC(3) hStabAC(3) + hStabLiftVec(3)],'Color',[0 0.5 0],'LineWidth',2,...
    'LineStyle','-');

plot3(...
    [prtAC(1) prtAC(1) + prtDragVec(1)],...
    [prtAC(2) prtAC(2) + prtDragVec(2)],...
    [prtAC(3) prtAC(3) + prtDragVec(3)],'Color',[1 0 0],'LineWidth',2,...
    'LineStyle','-');

plot3(...
    [sbdAC(1) sbdAC(1) + sbdDragVec(1)],...
    [sbdAC(2) sbdAC(2) + sbdDragVec(2)],...
    [sbdAC(3) sbdAC(3) + sbdDragVec(3)],'Color',[1 0 0],'LineWidth',2,...
    'LineStyle','-');
plot3(...
    [vStabAC(1) vStabAC(1) + vStabDragVec(1)],...
    [vStabAC(2) vStabAC(2) + vStabDragVec(2)],...
    [vStabAC(3) vStabAC(3) + vStabDragVec(3)],'Color',[1 0 0],'LineWidth',2,...
    'LineStyle','-');

plot3(...
    [hStabAC(1) hStabAC(1) + hStabDragVec(1)],...
    [hStabAC(2) hStabAC(2) + hStabDragVec(2)],...
    [hStabAC(3) hStabAC(3) + hStabDragVec(3)],'Color',[1 0 0],'LineWidth',2,...
    'LineStyle','-');

plot3(...
    [0 FNetGrav(1)/sqrt(sum(FNetGrav.^2))],...
    [0 FNetGrav(2)/sqrt(sum(FNetGrav.^2))],...
    [0 FNetGrav(3)/sqrt(sum(FNetGrav.^2))],...
    'Color',[0 0 0],'LineWidth',2,'LineStyle','-');
plot3(...
    [cm2cbVec(1) cm2cbVec(1) + FBuoy(1)/sqrt(sum(FBuoy.^2))],...
    [cm2cbVec(2) cm2cbVec(2) + FBuoy(2)/sqrt(sum(FBuoy.^2))],...
    [cm2cbVec(3) cm2cbVec(3) + FBuoy(3)/sqrt(sum(FBuoy.^2))],...
    'Color',[0 0 0],'LineWidth',2,'LineStyle','--');

plot3(...
    [-5*vWindBdy(1) 0],...
    [-5*vWindBdy(2) 0],...
    [-5*vWindBdy(3) 0],...
    'Color',[0 0 1],'LineWidth',2,'LineStyle','--');


axis equal
axis square




