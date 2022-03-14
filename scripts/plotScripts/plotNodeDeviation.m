
n = thr.numNodes.Value;
r = hiLvlCtrl.basisParams.Value(5);
w = hiLvlCtrl.basisParams.Value(1);
h = hiLvlCtrl.basisParams.Value(2);
x = r/n
lap = tsc.lapNumS.max-1;
[idx1,idx2,~] = tsc.getLapIdxs(lap);
ran = idx1:idx2;

nodePlots = tsc.thrNodePosVecs.getsampleusingtime...
    (tsc.airTenVecs.Time(idx1),tsc.airTenVecs.Time(idx2))
sQuery = [0:0.125:0.875]
for j = 1:numel(sQuery)
ind(j) = find(tsc.closestPathVariable.Data(:,:,ran)>sQuery(j),1)
end

sVec = squeeze(tsc.closestPathVariable.Data(ran));

timeVec = tsc.airTenVecs.Time(ran)-tsc.airTenVecs.Time(idx1);

nodePos = (tsc.thrNodePosVecs.Data(:,:,ran));
nodeEl = squeeze(atan2(nodePos(3,:,:),(sqrt(sum(nodePos(1:2,:,:).^2,1))))*180/pi);
nodeAz = squeeze(atan2(nodePos(2,:,:),nodePos(1,:,:))*180/pi);
nodeY = squeeze(nodePos(2,:,:)-mean(nodePos(2,:,:),3));
nodeZ = squeeze(nodePos(3,:,:)-mean(nodePos(3,:,:),3));
% nodeElDev(:,i) = (nodeEl-mean(nodeEl))';
% nodeAzDev(:,i) = (nodeAz-mean(nodeAz))';

% for i = 1:n
%     nodePos = squeeze(tsc.thrNodePosVecs.Data(:,i,ran));
%     nodeEl = atan2(nodePos(3,:),(sqrt(sum(nodePos(1:2,:).^2,1))))*180/pi;
%     nodeAz = atan2(nodePos(2,:),nodePos(1,:))*180/pi;
%     nodeElDev(:,i) = (nodeEl-mean(nodeEl))';
%     nodeAzDev(:,i) = (nodeAz-mean(nodeAz))';
% end

nodeL = [1:n]*x
%%
figure
tiledlayout(2,1)
for i = 1:numel(sQuery)
    nexttile(1)
    hold on
    grid on
    plot(squeeze(nodePlots.Data(1,:,ind(i))),squeeze(nodePlots.Data(2,:,ind(i))))
    ylabel '$y_g$ [m]'
    set(gca,'FontSize',12)
    nexttile(2)
    hold on
    grid on
    plot(squeeze(nodePlots.Data(1,:,ind(i))),squeeze(nodePlots.Data(3,:,ind(i))))
    ylabel '$z_g$ [m]'
    xlabel '$x_g$ [m]'
    set(gca,'FontSize',12)
end

l = 2;
m = 2;
j = 1;
for i = l:m:n
    if i == n
        legEnt{j} = sprintf('Kite Node (%d m)',nodeL(i));
    else
        legEnt{j} = sprintf('Node %d (%d m)',i,nodeL(i));
    end
    j = j+1;
end

figure('Position',[100 100 800 500])
plot(timeVec./timeVec(end),nodeY(l:m:end,:)/(w/2))
grid on
set(gca,'LineStyleOrder',{'-','--'})
xlabel 'Normalized Time'
ylabel '$\frac{y_{ground}-\mu_{y_{ground}}}{0.5w}$'
set(gca,'FontSize',12)
legend(legEnt,'Location','eastoutside')

% figure
% plot(timeVec,nodeElDev(l:m:end,:))
% set(gca,'LineStyleOrder',{'-','--'})
% xlabel 'Time [s]'
% ylabel '$z_{ground}-\mu_{z_{ground}}$'
% set(gca,'FontSize',12)
% legend(legEnt,'Location','eastoutside')
% 
% figure
% plot(timeVec,nodeAzDev(l:m:end,:))
% set(gca,'LineStyleOrder',{'-','--'})
% xlabel 'Time [s]'
% ylabel '$z_{ground}-\mu_{z_{ground}}$'
% set(gca,'FontSize',12)
% legend(legEnt,'Location','eastoutside')

figure('Position',[100 100 800 500])
plot(timeVec./timeVec(end),nodeZ(l:m:end,:)/(h/2))
grid on
set(gca,'LineStyleOrder',{'-','--'})
xlabel 'Normalized Time'
ylabel '$\frac{z_{ground}-\mu_{z_{ground}}}{0.5h}$'
set(gca,'FontSize',12)
legend(legEnt,'Location','eastoutside')

