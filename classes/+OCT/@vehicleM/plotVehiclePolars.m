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
parse(p,varargin{:})

fig = p.Results.fig;
fuseFactor = p.Results.fuseFactor;

alpha = obj.portWing.alpha.Value;
alpha1 = obj.hStab.alpha.Value;
Aref = obj.fluidRefArea.Value;
Afuse = pi/4*obj.fuse.diameter.Value^2.*cosd(alpha)+...
    (pi/4*obj.fuse.diameter.Value^2+obj.fuse.diameter.Value*obj.fuse.length.Value).*(1-cosd(alpha));
Athr = thr.tether1.diameter.Value/4;
CDthr = thr.tether1.dragCoeff.Value(1)*Athr/Aref
if isempty(obj.fuse.alpha)
CDfuse = (obj.fuse.endDragCoeff.Value.*cosd(alpha)+...
    obj.fuse.sideDragCoeff.Value.*(1-cosd(alpha))).*Afuse/Aref*fuseFactor;
else
    CDfuse = obj.fuse.CD.Value;
end
CLwing = obj.portWing.CL.Value+obj.stbdWing.CL.Value;
CLstab = interp1(alpha1,obj.hStab.CL.Value,alpha);
CDwing = obj.portWing.CD.Value+obj.stbdWing.CD.Value;
CDstab = interp1(alpha1,obj.hStab.CD.Value,alpha);
CDvert = interp1(alpha1,obj.vStab.CD.Value,alpha);

CLtot = CLwing+CLstab;
CDtot = CDwing+CDstab+CDvert+CDfuse+CDthr;

h = figure(fig);
subplot(2,2,1);hold on;grid on;
plot(alpha,CLtot,'color',p.Results.color,'LineStyle',p.Results.lineStyle,'Marker',p.Results.marker);
xlabel('$\alpha$ [deg]');  ylabel('$\mathrm{C_L}$');  xlim(p.Results.xLim);
set(gca,'FontSize',12)
subplot(2,2,2);hold on;grid on;
plot(alpha,CDtot,'color',p.Results.color,'LineStyle',p.Results.lineStyle,'Marker',p.Results.marker);
xlabel('$\alpha$ [deg]');  ylabel('$\mathrm{C_D}$');  xlim(p.Results.xLim);
set(gca,'FontSize',12)
subplot(2,2,3);hold on;grid on; 
plot(alpha,CLtot.^3./CDtot.^2,'color',p.Results.color,'LineStyle',p.Results.lineStyle,'Marker',p.Results.marker);
xlabel('$\alpha$ [deg]');  ylabel('$\mathrm{C_L^3/C_D^2}$');  xlim(p.Results.xLim);
set(gca,'FontSize',12)
subplot(2,2,4);hold on;grid on;
plot(alpha,CLtot./CDtot,'color',p.Results.color,'LineStyle',p.Results.lineStyle,'Marker',p.Results.marker);
xlabel('$\alpha$ [deg]');  ylabel('$\mathrm{C_L/C_D}$');  xlim(p.Results.xLim);
set(gca,'FontSize',12)

end