function h = plotVehiclePolars(obj,thr,thrL,varargin)
p = inputParser;
addParameter(p,'pMom',false,@islogical);
addParameter(p,'xLim',[-20 20],@isnumeric);
addParameter(p,'color',[0,0,1],@isnumeric);
addParameter(p,'lineStyle','-',@ischar);
addParameter(p,'marker','none',@ischar);
addParameter(p,'fig',21,@isnumeric);
addParameter(p,'sub',1,@isnumeric);
addParameter(p,'vBdy',[0;0;0],@isnumeric);
addParameter(p,'vFlow',[.25;0;0],@isnumeric);
addParameter(p,'theta',-15:.5:15,@isnumeric);
addParameter(p,'phi',90,@isnumeric);
addParameter(p,'elevation',30,@isnumeric);
addParameter(p,'azimuth',0,@isnumeric);
addParameter(p,'heading',90,@isnumeric);
addParameter(p,'fuseFactor',1,@isnumeric);
parse(p,varargin{:});

fig = p.Results.fig;
fuseFactor = p.Results.fuseFactor;

[CL,CD] = obj.getCLCD(thr,thrL);
alpha = obj.portWing.alpha.Value;

h = figure(fig);
subplot(2,2,1);hold on;grid on;
plot(alpha,CL,'color',p.Results.color,'LineStyle',p.Results.lineStyle,'Marker',p.Results.marker);
xlabel('$\alpha$ [deg]');  ylabel('$\mathrm{C_L}$');  xlim(p.Results.xLim);
set(gca,'FontSize',12);

subplot(2,2,2);hold on;grid on;
plot(alpha,CD.kite,'color',p.Results.color,'LineStyle',p.Results.lineStyle,'Marker',p.Results.marker);
plot(alpha,CD.kiteTurb,'color',p.Results.color,'LineStyle','--','Marker',p.Results.marker);
plot(alpha,CD.sys,'color',p.Results.color,'LineStyle',':','Marker',p.Results.marker);
xlabel('$\alpha$ [deg]');  ylabel('$\mathrm{C_D}$');  xlim(p.Results.xLim);
legend('Kite','Kite+Turb','Sys')
set(gca,'FontSize',12);

subplot(2,2,3);hold on;grid on; 
plot(alpha,CL.^3./CD.kite.^2,'color',p.Results.color,'LineStyle',p.Results.lineStyle,'Marker',p.Results.marker);
plot(alpha,CL.^3./CD.kiteTurb.^2,'color',p.Results.color,'LineStyle','--','Marker',p.Results.marker);
plot(alpha,CL.^3./CD.sys.^2,'color',p.Results.color,'LineStyle',':','Marker',p.Results.marker);
xlabel('$\alpha$ [deg]');  ylabel('$\mathrm{C_L^3/C_D^2}$');  xlim(p.Results.xLim);
set(gca,'FontSize',12);

subplot(2,2,4);hold on;grid on;
plot(alpha,CL./CD.kite,'color',p.Results.color,'LineStyle',p.Results.lineStyle,'Marker',p.Results.marker);
plot(alpha,CL./CD.kiteTurb,'color',p.Results.color,'LineStyle','--','Marker',p.Results.marker);
plot(alpha,CL./CD.sys,'color',p.Results.color,'LineStyle',':','Marker',p.Results.marker);
xlabel('$\alpha$ [deg]');  ylabel('$\mathrm{C_L/C_D}$');  xlim(p.Results.xLim);
set(gca,'FontSize',12);

end