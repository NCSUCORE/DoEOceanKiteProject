function [val,tscLap] = calcLapStats(tscOrig,reSampTime,varargin)

pp = inputParser;
addParameter(pp,'plotRes',false,@islogical);
parse(pp,varargin{:});

lapNumTsc = tscOrig.lapNumS;
maxLap = max(lapNumTsc.Data);

if maxLap > 2
    % time vector
    startIdx = find(lapNumTsc.Data(:)==maxLap-1,1,'first');
    endIdx   = find(lapNumTsc.Data(:)==maxLap-1,1,'last');
    tRange = lapNumTsc.Time(startIdx):reSampTime:lapNumTsc.Time(endIdx);
    
   
    tscLap = tscOrig.resample([tRange(1):reSampTime:tRange(2)]);
    
    %% lap averaged statistics
    % time vector
    val.timeVec = tscLap.lapNum.Time;
    % tether drag
    val.thrDrag = mean(vecnorm(tscLap.O_thrDrag.Data));
    % tether tension
    val.thrTension = mean(vecnorm(tscLap.O_thrTen.Data));
    % winch power
    val.winchPower = mean(tscLap.winchPower.Data);
    % winch energy
    val.winchEnergy = tscLap.winchEnergy.Data(end) - tscLap.winchEnergy.Data(1);
    % turbine power
    val.turbPower = mean(tscLap.turbPower.Data);
    % turbine energy
    val.turbEnergy = tscLap.turbEnergy.Data(end) - tscLap.turbEnergy.Data(1);
    % kite speed
    val.kiteSpeed = mean(vecnorm(tscLap.O_vKite.Data));
    % kite drag
    val.kiteDrag = mean(vecnorm(tscLap.B_FnetDrag.Data));
    % lap time
    val.lapTime   = tscLap.lapNum.Time(end) - tscLap.lapNum.Time(1);
    % kite angle of attack
    val.kiteAoADeg   = mean(tscLap.kiteAoADeg.Data);
    % max tan roll
    val.maxTanRollDeg = max(abs(tscLap.tanRoll.Data*180/pi));
    % max tan roll des
    val.maxTanRollDesDeg = max(abs(tscLap.desTanRoll.Data*180/pi));
    % max slip angle
    val.maxSlipAngleDeg = max(abs(tscLap.slipAngle.Data*180/pi));
    % max slip angle
    val.maxAilDef = max(abs(tscLap.csDef.Data(:,1)));
    % kite CLbyCD
    val.CLbyCD = mean(tscLap.CLbyCD.Data);
    % kite CL3/CD2
    val.CL3byCD2 = mean(tscLap.CL3byCD2.Data);
    % kite vAppx3
    val.vAppx3 = mean(tscLap.B_vApp.Data(1,:,:).^3);
    % lap number
    val.lapNum = maxLap;
    % lap number
    val.trackingErrorLap = tscLap.trackingErrorLap.Data(end);
    
else
    val = nan;
    tscLap   = nan;
end


if pp.Results.plotRes
    tiledlayout('flow');
    tVec = val.timeVec - val.timeVec(1);
%     % slip angle
%     nexttile; plot(tVec,tscLap.slipAngle.Data*180/pi,'k-');hold on;
%     ylabel('Slip angle [deg]'); title(makeTitle(val.maxSlipAngleDeg,'ma'));
%     % tangent roll angle
%     nexttile; plot(tVec,tscLap.desTanRoll.Data*180/pi,'r--','linewidth',1.0);hold on;
%     plot(tVec,tscLap.tanRoll.Data*180/pi,'k-'); ylabel('Tangent roll [deg]');
%     title(makeTitle(val.maxTanRollDeg,'ma'));
%     % Aileron deflection
%     nexttile; plot(tVec,tscLap.csDef.Data(:,1),'k-');hold on;
%     ylabel('Aileron deflection [deg]'); title(makeTitle(val.maxAilDef,'ma'));
    % kite angle of attack
    nexttile; plot(tVec,tscLap.kiteAoADeg.Data(:),'k-');hold on;
    ylabel('Kite AoA [deg]'); title(makeTitle(val.kiteAoADeg,'me'));
%     % kite CL by CD
%     nexttile; plot(tVec,tscLap.CLbyCD.Data(:),'k-');hold on;
%     ylabel('Total $C_{L}/C_{D}$'); title(makeTitle(val.CLbyCD,'me'));
%     % kite CL3 by CD2
%     nexttile; plot(tVec,tscLap.CL3byCD2.Data(:),'k-');hold on;
%     ylabel('Total $C_{L}^3/C_{D}^2$'); title(makeTitle(val.CL3byCD2,'me'));
    % speed
    nexttile; plot(tVec,vecnorm(squeeze(tscLap.O_vKite.Data)),'k-');hold on;
    ylabel('Speed [m/s]'); title(makeTitle(val.kiteSpeed,'me'));
    % kite drag
    nexttile; plot(tVec,vecnorm(squeeze(tscLap.B_FnetDrag.Data)),'k-');hold on;
    ylabel('Kite drag [N]'); title(makeTitle(val.kiteDrag,'me'));
    % tether drag
    nexttile; plot(tVec,squeeze(vecnorm(tscLap.O_thrDrag.Data)),'k-');hold on;
    ylabel('Tether drag [N]'); title(makeTitle(val.thrDrag,'me'));
    % tether tension
    nexttile; plot(tVec,squeeze(vecnorm(tscLap.O_thrTen.Data))./1e3,'k-');hold on;
    ylabel('Tether tension [kN]'); title(makeTitle(val.thrTension/1e3,'me'));
%     % Winch power
%     nexttile; plot(tVec,tscLap.winchPower.Data./1e3,'k-');hold on;
%     ylabel('Winch power [kW]'); title(makeTitle(val.winchPower/1e3,'me'));
%     % Winch energy
%     nexttile; plot(tVec,(tscLap.winchEnergy.Data-tscLap.winchEnergy.Data(1))./1e3,'k-');hold on;
%     ylabel('Winch energy [kJ]'); title(makeTitle(val.winchEnergy/1e3,'ra'));
    % turbine power
    nexttile; plot(tVec,tscLap.turbPower.Data(:)./1e3,'k-');hold on;
    ylabel('Turbine power [kW]'); title(makeTitle(val.turbPower/1e3,'me'));
%     % turbine energy
%     nexttile; plot(tVec,(tscLap.turbEnergy.Data(:)-tscLap.turbEnergy.Data(1))./1e3,'k-');hold on;
%     ylabel('Turbine energy [kJ]'); title(makeTitle(val.turbEnergy/1e3,'ra'));
%     % Tracking error
%     nexttile; plot(tVec,tscLap.trackingErrorIns.Data,'k-');hold on;
%     ylabel('Tracking err. [m]'); title(makeTitle(val.trackingErrorLap,'ra'));

    allAxes = findall(gcf,'type','axes');
    xlabel(allAxes,'Time [s]');
    set(allAxes,'fontsize',10);
    linkaxes(allAxes,'x');
    grid(allAxes,'on');
    xlim(allAxes,[0 tVec(end)]);
    
end


end

function val = makeTitle(ip,meanOrMax)

if strcmpi(meanOrMax,'me')
    val = sprintf('Mean = %.2f',ip);
    yline(ip,'r:','linewidth',1.2);
elseif strcmpi(meanOrMax,'ma')
    val = sprintf('Max = %.2f',ip);
    yline(ip,'b:','linewidth',1.2);
    yline(-ip,'b:','linewidth',1.2);
elseif strcmpi(meanOrMax,'ra')
    val = sprintf('Range = %.2f',ip);
end
end