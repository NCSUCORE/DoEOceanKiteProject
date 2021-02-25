function plotSomethingAyaz(tsc,figName,sMinHr)

switch sMinHr
    case 's'
        td = 1;
    case 'min'
        td = 60;
    case 'h'
        td = 3600;
    otherwise
        td = 1;
end
time = tsc.positionVec.Time./td;

switch figName
    case 'Tangent roll'
        data = tsc.tanRoll.Data*180/pi;
        yLab = '[deg]';
    case 'Speed'
        data = squeeze(vecnorm(tsc.velCMvec.Data));
        yLab = '[m/s]';
    case 'Apparent vel. in x cubed'
        data = squeeze((tsc.velCMvec.Data(1,:)).^3);
        yLab = '$[m^3/s^3]$';
    case 'Turbine power'
        data = squeeze(tsc.turbPow.Data./1000);
        yLab = '[kW]';
    case 'Kite speed by flow speed cubed'
        data = squeeze(vecnorm(tsc.vWindFuseGnd.Data))./...
            squeeze(vecnorm(tsc.velCMvec.Data));
        yLab = '[-]';
    case 'Flow at kite'
        data = squeeze(vecnorm(tsc.vWindFuseGnd.Data));       
        yLab = '[m/s]';
    case 'Path elevation angle'
        data = tsc.basisParams.Data(:,3)*180/pi;
        yLab = '[deg]';
    case 'Altitude SP'
        data = tsc.altitudeSP.Data(:);
        yLab = '[m]';
    case 'Turbine energy'
        data = tsc.turbEnrg.Data(:)./1e3;
        yLab = '[kJ]';
    case 'Tether length SP'
        data = tsc.thrLSP.Data(:);
        yLab = '[m]';
    case 'Tether length'
        data = tsc.tetherLengths.Data(:);
        yLab = '[m]';
    case 'Tether tension'
        data = squeeze(tsc.FThrNetBdy.Data);
        data = vecnorm(data);
        yLab = '[N]';
end

if strcmp(figName,'Tether length SP')
    figName = 'Tether length';
    linStyle = '--';
else
    linStyle = '-';
end

fh = findobj( 'Type', 'Figure', 'Name', figName);

if isempty(fh)
    fh = figure;
    fh.Name = figName;
else
    figure(fh);
end

plot(time,data,'linewidth',1,'linestyle',linStyle);
grid on;
hold on;
xlabel(['Time [',sMinHr,']']);
ylabel([figName,' ',yLab]);
% title(figName);

if strcmp(figName,'Tether length')
colororder((1/255)*[0 114 189; 217 83 25]);
end

end
