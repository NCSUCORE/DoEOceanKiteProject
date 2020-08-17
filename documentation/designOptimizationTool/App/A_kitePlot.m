function A_kitePlot(app,AR_opt,Span_opt,D_opt,L_opt)
%% Inputs 
% L_opt = 8; 
% D_opt = 0.5; 
% Span_opt = 10; 
% AR_opt = 8; 
wingPos = 0.35;                     % wing LE position along L in (%)
DrawPlot = 'KiteDes';
% ------------------------------------------%
% DrawPlot = 'KiteDes';
% main figure number  
 
% obtain Lscale for wing plotting 
Lscale = 10/AR_opt; 
[x,x_ac, us_eq, ls_eq] = airfoil_data(Lscale);
%% plotting wing  
% figure(fig) 
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,wingPos*L_opt+x,-Span_opt/2*ones(size(x)),us_eq,'k') 


app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,wingPos*L_opt+x,-Span_opt/2*ones(size(x)),ls_eq,'k') 
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,wingPos*L_opt+x,Span_opt/2*ones(size(x)),us_eq,'k') 
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,wingPos*L_opt+x,Span_opt/2*ones(size(x)),ls_eq,'k') 

app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[wingPos*L_opt wingPos*L_opt],[-Span_opt/2 Span_opt/2],[0 0],'k')
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[wingPos*L_opt+max(x) wingPos*L_opt+max(x)],[-Span_opt/2 Span_opt/2],[0 0],'k')
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[wingPos*L_opt+x_ac wingPos*L_opt+x_ac],[-Span_opt/2 Span_opt/2],[max(us_eq) max(us_eq)],'k')
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[wingPos*L_opt+x_ac wingPos*L_opt+x_ac],[-Span_opt/2 Span_opt/2],[min(ls_eq) min(ls_eq)],'k')

%% plotting fuselage  
% figure(fig) 
% fuselage rings 
nrings = 6;                     %no. of rings                      
clocs_vec = linspace(0,L_opt,nrings); 
for i = 1:nrings
    cloc = [clocs_vec(i) 0 0];      % center of circle 
    R = 0.5*D_opt ;                  % Radius of circle 
    theta=0:0.01:2*pi ;
    yring = cloc(2)+R*cos(theta);
    xring = cloc(1)+zeros(size(yring));
    zring = cloc(3)+R*sin(theta) ;
    app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,xring,yring,zring,'k')
end 

% fuselage lines  
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[0 L_opt],[-0.5*D_opt -0.5*D_opt],[0 0],'k') 
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[0 L_opt],[0.5*D_opt 0.5*D_opt],[0 0],'k')
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[0 L_opt],[0 0],[-0.5*D_opt -0.5*D_opt],'k')
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[0 L_opt],[0 0],[0.5*D_opt 0.5*D_opt],'k')

%% plotting fuselage 
% inputs  
Hspan = 4; 
HAR = 8; 
Hchord = Hspan/HAR; 
Lscale = Hchord; 
HPos = (L_opt - 1.1*Hchord)/L_opt;
[x,x_ac, us_eq, ls_eq] = airfoil_data(Lscale);

% figure(fig) 
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,HPos*L_opt+x,-Hspan/2*ones(size(x)),us_eq,'k') 

app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,HPos*L_opt+x,-Hspan/2*ones(size(x)),ls_eq,'k') 
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,HPos*L_opt+x,Hspan/2*ones(size(x)),us_eq,'k') 
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,HPos*L_opt+x,Hspan/2*ones(size(x)),ls_eq,'k') 

app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[HPos*L_opt HPos*L_opt],[-Hspan/2 Hspan/2],[0 0],'k')
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[HPos*L_opt+max(x) HPos*L_opt+max(x)],[-Hspan/2 Hspan/2],[0 0],'k')
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[HPos*L_opt+x_ac HPos*L_opt+x_ac],[-Hspan/2 Hspan/2],[max(us_eq) max(us_eq)],'k')
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[HPos*L_opt+x_ac HPos*L_opt+x_ac],[-Hspan/2 Hspan/2],[min(ls_eq) min(ls_eq)],'k')


%% plotting tail (user defined) 
Vrchord = 0.9; 
Vtchord = 0.6; 
Vspan = 1.5;
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[L_opt-Vrchord L_opt],[0 0],[D_opt/2 D_opt/2],'k') 
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[L_opt L_opt],[0 0],[D_opt/2 D_opt/2+Vspan],'k') 
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[L_opt-Vtchord L_opt],[0 0],[D_opt/2+Vspan D_opt/2+Vspan],'k')
app.Plots.DrawPlot.Plot = plot3(app.PlotAxes.DrawPlot,[L_opt-Vrchord L_opt-Vtchord],[0 0],[D_opt/2 D_opt/2+Vspan],'k') 
% app.Plots.DrawPlot.Plot = view(app.PlotAxes.DrawPlot,90,90) 

end
%% functions 

function [x,x_ac, us_eq, ls_eq] = airfoil_data(Lscale)
% clc; clear all;

% AirfoilData = readtable('seligdatfile.txt'); 
AirfoilData = readtable('aftools2412_12per.txt'); 
Airfoil = table2array(AirfoilData);

PositiveY = find(Airfoil(:,2)>0);
NegativeY = find(Airfoil(:,2)<=0);

x = linspace(0,1,101); 

% Upper surface 
us = Airfoil(PositiveY,:); 
us_x = us(:,1); 
us_y = us(:,2); 
options = fitoptions('poly9', 'Robust', 'Bisquare');
fitus = fit(us_x,us_y,'poly9',options); 

% Equation for upper surface
us_eq = fitus.p1.*x.^9 + fitus.p2.*x.^8 + fitus.p3.*x.^7 + fitus.p4.*x.^6 + fitus.p5.*x.^5 ...
    + fitus.p6.*x.^4 + fitus.p7.*x.^3 + fitus.p8.*x.^2 + fitus.p9.*x + fitus.p10 ; 


% Lower surface 
ls = Airfoil(NegativeY,:); 
ls_x = ls(:,1); 
ls_y = ls(:,2); 
options = fitoptions('poly9', 'Robust', 'Bisquare');
fitls = fit(ls_x,ls_y,'poly9',options); 

% Equation for lower surface
ls_eq = fitls.p1.*x.^9 + fitls.p2.*x.^8 + fitls.p3.*x.^7 + fitls.p4.*x.^6 + fitls.p5.*x.^5 ...
    + fitls.p6.*x.^4 + fitls.p7.*x.^3 + fitls.p8.*x.^2 + fitls.p9.*x + fitls.p10 ; 

% outputs 

x = x*Lscale; 
ls_eq = ls_eq*Lscale;
us_eq = us_eq*Lscale; 
[x_ac maxVal] = max(us_eq); 

end

