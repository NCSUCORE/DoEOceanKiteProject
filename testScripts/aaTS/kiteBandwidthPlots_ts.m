%% Test script for John to control the kite model
clear;clc;close all;
Simulink.sdi.clear

thrLengthArray = [200:200:600];
flwSpdArray = [0.1:0.1:0.5];
el = 30*pi/180;

for j = 1:length(thrLengthArray)
    for k = 1:length(flwSpdArray)
        
        % Load Simulation Results
        flwSpd = flwSpdArray(k);
        thrLength = thrLengthArray(j);
        filename = sprintf(strcat('V-%.3f_EL-%.1f_THR-%d.mat'),flwSpd,el*180/pi,thrLength);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'output','Manta\');
        load([fpath filename])
        
    %Process Data - Load Snapshot Array and Pre-Allocate Cell Arrays for
    %plotting data
    snaps = 0.025:0.025:0.975;
    n = length(snaps);
    dispName = cell(n,1);
    for i = 1:n
        dispName{i} = sprintf('Path Parameter = %.2f',snaps(i));
    end
    
    %Pre-Allocate cell arrays for Bode data
    magdb = cell(4,1,n); wHz = cell(4,1,n); mag = cell(4,1,n);
    for i = 1:4
        for ii = 1
            for iii = 1:n
                [mag{i,ii,iii},phase,wout] = bode(linsys(i,3*(ii-1)+[1:3],iii,:),{0.001*2*pi 2*pi});
                magdb{i,ii,iii} = 20*log10(mag{i,ii,iii}.*flwSpd);
                wHz{i,ii,iii} = wout/(2*pi);
                a(i,ii,iii) = find(mag{i,ii,iii}(:,2,:)==max(mag{i,ii,iii}(:,2,:)));
                wHzPertMat(i,ii,iii) = wHz{i,ii,iii}(a(i,ii,iii));
                magPertMat(i,ii,iii) = mag{i,ii,iii}(a(i,ii,iii)); 
                toc
            end
        end
    end
    searchVal = max(magPertMat,[],3);
    for i = 1:length(searchVal)
        a(i) = find(magPertMat(i,:,:)==searchVal(i),1)
        wHzPert(i) = wHzPertMat(a(i));
    end
%     h = figure; hold on;
%     clear serNameCell
%     ax = gca;
%     offset = 0
%     numEnt = ceil(length(snaps)/2)
%     a=hsv(numEnt);
%     colororder(ax,a);
%     colormap(ax,jet)
%     for i = 19:19+numEnt
%         serName = sprintf('s = %.3f',snaps(i+offset));
%         serNameCell(i) = {serName};
%         [p(:,i),z] = pzmap(linsys(:,:,i+offset,:));
%         scatter(real(p(:,i)),imag(p(:,i)),[],ones(length(p(:,i)),1)*snaps(i),'x')
%     end
%     h = colorbar;
%     ylabel(h, 'Path Parameter','Interpreter','latex')
% %     scatter(real(p),imag(p))
%     line(xlim(),[0,0],'Color',[.5 .5 .5])
%     line([0,0],ylim(),'Color',[.5 .5 .5])
%     xlabel('Real Axis [$s^{-1}$]')
%     ylabel('Imaginary Axis [$s^{-1}$]')
% %     legend(serNameCell,'NumColumns',4','Location','NorthWest')
% 
% 
% for i =1:length(snaps)
%     pPlot(i) = max(real(p(:,i)));
% end
%     
% h = figure
% ax = gca; colormap(ax,jet);
% scatter(snaps,pPlot,[],pPlot,'filled')
% h = colorbar;
% ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
% xlabel('Path Position')
% ylabel('Real Component of Slowest Pole [$s^{-1}$]')
% 
% 
% % figure
% % semilogy(snaps,1./pPlot,'kx')
% % xlabel('Path Position')
% % ylabel('Time Constants of Slowest Pole [s]')
% 
% 
%     
%     titleCellIn = {'Ground X Component','Ground Y Component','Ground Z Component'};
%     titleCellOut = {' Side Slip Error [rad]',' Central Angle Error [rad]',...
%         ' Tangent Roll Error [rad]',' Velocity Angle Error [rad]'};
%     subTitleCellIn = {' Normalized Velocity Magnitude [$|v_{turb}|/|v_{freestream}|$]'};
%     yLabelIn = 'Magnitude [dB]';
%     xLabelIn = 'Frequency [Hz]';
%        
%     for i = 1:4
%         for ii = 1:1
%             h = figure('Units','inches','Position',[1 1 12 8])
%             r = 1; c = 3;
%             a=lines(5);
%             ax1 =subplot(r,c,1); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{1});
%             ax2 = subplot(r,c,2); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{2});
%             ax3 = subplot(r,c,3); hold on; xlabel(xLabelIn); ylabel(yLabelIn); title(titleCellIn{3});
%             colororder(ax1,a); colororder(ax2,a); colororder(ax3,a);
%             ax1.LineStyleOrder = {'-','--',':'}; ax2.LineStyleOrder = {'-','--',':'}; ax3.LineStyleOrder = {'-','--',':'};
%             set(ax1,'xscale','log'); set(ax2,'xscale','log');  set(ax3,'xscale','log');
%             sgtitle({strcat('Frequency Response: ',subTitleCellIn{ii},' disturbance'),...
%                 strcat(' to ',titleCellOut{i})})
%             for iii = 1:4:length(snaps)
%                     serName = sprintf('s = %.3f',snaps(iii));
% %                     subplot(1,4,3); xlabel(xLabelIn); ylabel(yLabelIn);
% %                     title(titleCellIn{1})
% %                     semilogx(wHz{1,ii,iii},squeeze(magdb{1,ii,iii}(:,i,:))); hold on;
%                     semilogx(ax1,wHz{i,1,iii},squeeze(magdb{i,1,iii}(:,1,:)));
%                     semilogx(ax2,wHz{i,1,iii},squeeze(magdb{i,1,iii}(:,2,:)),'DisplayName',serName);
%                     semilogx(ax3,wHz{i,1,iii},squeeze(magdb{i,1,iii}(:,3,:)),'DisplayName',serName);
% %                     subplot(1,4,4); xlabel(xLabelIn); ylabel(yLabelIn);
% %                     title(titleCellIn{4})
% %                     semilogx(wHz{4,ii,iii},squeeze(magdb{4,ii,iii}(:,i,:)),'DisplayName',serName); hold on;
% 
%                 legend(ax2,'Location','southwest','NumColumns',2)
%                 xlabel('Frequency [Hz]')
%                 ylabel('Magnitude [dB]')
%             end
%         end
%     end
end

%%  Log Results
distFreq = wHzPert;
    lap = max(tsc.lapNumS.Data)-1;
    [Idx1,Idx2] = getLapIdxs(tsc,lap);
    ran = Idx1:Idx2-1;
    for i = 1:1000-1
        ind(i)=find(tsc.closestPathVariable.Data(ran) > i/1000,1);
    end
    tanRollErrBase = squeeze(tsc.tanRollError.Data(Idx1+ind));
    cenAngleErrBase = squeeze(tsc.centralAngle.Data(Idx1+ind));
    betaErrBase = squeeze(tsc.betaErr.Data(Idx1+ind));
    velAngErrBase = squeeze(tsc.velAngleError.Data(Idx1+ind));
    pathVar = tsc.closestPathVariable.Data(Idx1+ind);
    figure
    plot(pathVar,tanRollErrBase)
 
   
    lap = max(tsc1.lapNumS.Data)-1;
    [Idx1,Idx2] = getLapIdxs(tsc1,lap);
    ran = Idx1:Idx2-1;
    for i = 1:1000-1
        ind(i)=find(tsc1.closestPathVariable.Data(ran) > i/1000,1);
    end
    tanRollErr = squeeze(tsc1.tanRollError.Data(Idx1+ind));
    cenAngleErr = squeeze(tsc1.centralAngle.Data(Idx1+ind));
    betaErr = squeeze(tsc1.betaErr.Data(Idx1+ind));
    velAngErr = squeeze(tsc1.velAngleError.Data(Idx1+ind));
for ii = 1:4
    for i = 1:length(snaps)
        x(ii,i)=find(wHz{ii,1,i} > distFreq,1);
        wHzPlot(ii,i)=wHz{ii,1,i}(x(ii,i))
        magPlot(ii,i,:) = mag{ii,1,i}(1,:,x(ii,i));
    end
end
% 
% figure; hold on;
% ax = gca;
% plot(pathVar,betaErr-betaErrBase)
% plot(snaps,magPlot(1,:,2)*distAmp*flwSpd,'kx')
% plot(snaps,-magPlot(1,:,2)*distAmp*flwSpd,'kx')
% xlabel('Path Position')
% ylabel('Residual Side Slip [rad]')
% legend('Residual Error','Predicted Error')
% 
% figure; hold on;
% plot(pathVar,cenAngleErr-cenAngleErrBase)
% plot(snaps,magPlot(2,:,2)*distAmp*flwSpd,'kx')
% plot(snaps,-magPlot(2,:,2)*distAmp*flwSpd,'kx')
% xlabel('Path Position')
% ylabel('Residual Central Angle Error [rad]')
% legend('Residual Error','Predicted Error')
% 
% figure; hold on;
% plot(pathVar,tanRollErr-tanRollErrBase,'k--')
% ax = gca; colormap(ax,jet);
% scatter(snaps,magPlot(3,:,2)*distAmp*flwSpd,[],pPlot,'filled')
% scatter(snaps,-magPlot(3,:,2)*distAmp*flwSpd,[],pPlot,'filled')
% h = colorbar;
% ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
% % plot(snaps(pPlot>1e-10),magPlot(4,(pPlot>1e-10),2)*distAmp*f
% xlabel('Path Position')
% ylabel('Residual Tangent Roll Error [rad]')
% legend('Residual Error','Predicted Error')
% 
% figure; hold on
% 
% plot(pathVar,velAngErr-velAngErrBase,'k--')
% ax = gca; colormap(ax,jet);
% scatter(snaps,magPlot(3,:,2)*distAmp*flwSpd,[],pPlot,'filled')
% scatter(snaps,-magPlot(3,:,2)*distAmp*flwSpd,[],pPlot,'filled')
% h = colorbar;
% ylabel(h, 'Pole Location [$s^{-1}$]','Interpreter','latex')
% % plot(snaps(pPlot>1e-10),magPlot(4,(pPlot>1e-10),2)*distAmp*flwSpd,'rx')
% % plot(snaps(pPlot<1e-10),magPlot(4,(pPlot<1e-10),2)*distAmp*flwSpd,'kx')
% % plot(snaps(pPlot>1e-10),-magPlot(4,(pPlot>1e-10),2)*distAmp*flwSpd,'rx')
% % plot(snaps(pPlot<1e-10),-magPlot(4,(pPlot<1e-10),2)*distAmp*flwSpd,'kx')
% xlabel('Path Position')
% ylabel('Residual Velocity Angle Error [rad]')
% legend('Residual Error','Predicted Error')
% 
% figure; hold on;
% subplot (2,2,1); hold on;
% plot(pathVar,betaErr)
% plot(pathVar,betaErrBase,'k')
% ylabel('Error [rad]'); title('Side Slip Error')
% 
% subplot (2,2,2); hold on;
% plot(pathVar,cenAngleErr)
% plot(pathVar,cenAngleErrBase,'k')
% ylabel('Error [rad]'); title('Central Angle Error')
% 
% subplot (2,2,3); hold on;
% plot(pathVar,tanRollErr)
% plot(pathVar,tanRollErrBase,'k')
% ylabel('Error [rad]'); title('Tangent Roll Angle Error'); xlabel('Path Position')
% 
% subplot (2,2,4); hold on;
% plot(pathVar,velAngErr)
% plot(pathVar,velAngErrBase,'k')
% ylabel('Error [rad]'); title('Velocity Angle Error'); xlabel('Path Position')
% 
%     Pow = tsc.rotPowerSummary(vhcl,env);
%     [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
%     AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
%     airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
%     gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
%     ten = max([max(airNode(ran)) max(gndNode(ran))]);
%     fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);
% 
% dt = datestr(now,'mm-dd_HH-MM');


% simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
% simWithMonitor('OCTModel');
% tsc = signalcontainer(logsout);   
% lap = max(tsc.lapNumS.Data)-1;
% tsc.plotFlightError(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    filename = sprintf(strcat('V-%.3f_EL-%.1f_THR-%d.mat'),flwSpd,el*180/pi,thrLength);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'output','Manta\');
if saveSim == 1
    if max(tsc.lapNumS.Data) > 1
    save(strcat(fpath,filename),'vhcl','thr','fltCtrl','env','linsys','simParams','LIBRARY','gndStn','tsc','tsc1','tsc2','tsc3')
    end
end
    end
end
%%  Plot Results
    lap = max(tsc.lapNumS.Data)-1;
    if max(tsc.lapNumS.Data) < 2
        tsc.plotFlightResults(vhcl,env,'plot1Lap',1==0,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    else
        tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
        tsc.plotFlightError(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    end
%%
% figure(23); 
% [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2-1;
% data = squeeze(tsc.currentPathVar.Data);
% subplot(2,1,1); hold on; grid on;
% plot(data(ran),squeeze(tsc.tanRollDes.Data(:,:,ran)),'r-')
% xlabel('Path Position'); ylabel('Tan Roll Des [deg]');
% subplot(2,1,2); hold on; grid on;
% plot(data(ran),squeeze(tsc.ctrlSurfDeflCmd.Data(ran,1)),'r-')
% xlabel('Path Position'); ylabel('Port Aileron [deg]');
%%
% figure; subplot(1,3,1); hold on; grid on;
% plot(tsc.basisParams.Time,squeeze(tsc.basisParams.Data(3,:,:))*180/pi,'r-'); xlabel('Time [s]'); ylabel('Elevation [deg]');
% plot(tsc.elevationAngle.Time,squeeze(tsc.elevationAngle.Data),'b-'); xlabel('Time [s]'); ylabel('Elevation [deg]');
% legend('Setpoint','Actual','location','northwest')
% subplot(1,3,2); hold on; grid on;
% plot(tsc.tetherLengths.Time,squeeze(tsc.tetherLengths.Data),'b-'); xlabel('Time [s]'); ylabel('Tether Length [m]');
% subplot(1,3,3); hold on; grid on;
% plot(tsc.positionVec.Time,squeeze(tsc.positionVec.Data(3,1,:)),'b-'); xlabel('Time [s]'); ylabel('Altitude [m]');
%%  Animate Simulation
% if simScenario <= 2
    vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',20,...
        'GifTimeStep',.00001,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
        'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'),...
        'startTime',5000);
% else
    vhcl.animateSim(tsc,2,'View',[90,0],'Pause',1==0,...
        'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==0);
% end
%%  Compare to old results
% Res = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\Results\Manta 2.0\Rotor\Turb1.0_V-0.300_EL-30.0_D-0.70_AoA-13.98_10-22_12-29.mat');
% Res.tsc.rotPowerSummary(Res.vhcl,Res.env);
% [Idx1,Idx2] = Res.tsc.getLapIdxs(max(Res.tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
% AoA = mean(squeeze(Res.tsc.vhclAngleOfAttack.Data(:,:,ran)));
% airNode = squeeze(sqrt(sum(Res.tsc.airTenVecs.Data.^2,1)))*1e-3;
% gndNode = squeeze(sqrt(sum(Res.tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
% ten = max([max(airNode(ran)) max(gndNode(ran))]);
% fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n',AoA,ten);