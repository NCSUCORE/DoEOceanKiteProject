function h = plotVehiclePolars(obj,thr,thrL,varargin)
p = inputParser;
addParameter(p,'pMom',false,@islogical);
addParameter(p,'xLim',[-20 20],@isnumeric);
addParameter(p,'color',[0,0,1],@isnumeric);
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
Aref = obj.fluidRefArea.Value;
Afuse = pi/4*obj.fuse.diameter.Value^2.*cosd(alpha)+...
    (pi/4*obj.fuse.diameter.Value^2+obj.fuse.diameter.Value*obj.fuse.length.Value).*(1-cosd(alpha));
Athr = thr.tether1.diameter.Value/4;
CDthr = thr.tether1.dragCoeff.Value(1)*Athr/Aref;
CDfuse = (obj.fuse.endDragCoeff.Value.*cosd(alpha)+...
    obj.fuse.sideDragCoeff.Value.*(1-cosd(alpha))).*Afuse/Aref*fuseFactor;
CLwing = obj.portWing.CL.Value+obj.stbdWing.CL.Value;
CLstab = obj.hStab.CL.Value;
CDwing = obj.portWing.CD.Value+obj.stbdWing.CD.Value;
CDstab = obj.hStab.CD.Value;
CDvert = obj.vStab.CD.Value;

CLtot = CLwing+CLstab;
CDtot = CDwing+CDstab+CDvert+CDfuse+CDthr;

h = figure(fig);
subplot(2,2,1);hold on;grid on;
plot(alpha,CLtot,'color',p.Results.color);
xlabel('alpha [deg]');  ylabel('$\mathrm{CL}$');  xlim(p.Results.xLim);
subplot(2,2,2);hold on;grid on;
plot(alpha,CDtot,'color',p.Results.color);
xlabel('alpha [deg]');  ylabel('$\mathrm{CD}$');  xlim(p.Results.xLim);
subplot(2,2,3);hold on;grid on;
plot(alpha,CLtot.^3./CDtot.^2,'color',p.Results.color);
xlabel('alpha [deg]');  ylabel('$\mathrm{CL^3/CD^2}$');  xlim(p.Results.xLim);
subplot(2,2,4);hold on;grid on;
plot(alpha,CLtot./CDtot,'color',p.Results.color);
xlabel('alpha [deg]');  ylabel('$\mathrm{CL/CD}$');  xlim(p.Results.xLim);

end