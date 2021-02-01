function plotSomething(tsc,figName,sMinHr)

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
        
end

fh = findobj( 'Type', 'Figure', 'Name', figName);

if isempty(fh)
    fh = figure;
    fh.Name = figName;
else
    figure(fh);
end

plot(time,data,'linewidth',1);
grid on;
hold on;
xlabel(['Time [',sMinHr,']']);
ylabel(yLab);
title(figName);


end
