
n = thr.numNodes.Value

lap = tsc.lapNumS.max-1;
[idx1,idx2,~] = tsc.getLapIdxs(lap);
ran = idx1:idx2;


timeVec = tsc.airTenVecs.Time(ran)-tsc.airTenVecs.Time(idx1);

nodePos = (tsc.thrNodePosVecs.Data(:,:,ran));
nodeEl = squeeze(atan2(nodePos(3,:,:),(sqrt(sum(nodePos(1:2,:,:).^2,1))))*180/pi);
nodeAz = squeeze(atan2(nodePos(2,:,:),nodePos(1,:,:))*180/pi);
nodeY = squeeze(nodePos(2,:,:)-mean(nodePos(2,:,:),3));
nodeZ = squeeze(nodePos(3,:,:)-mean(nodePos(3,:,:),3));
nodeElDev(:,i) = (nodeEl-mean(nodeEl))';
nodeAzDev(:,i) = (nodeAz-mean(nodeAz))';

% for i = 1:n
%     nodePos = squeeze(tsc.thrNodePosVecs.Data(:,i,ran));
%     nodeEl = atan2(nodePos(3,:),(sqrt(sum(nodePos(1:2,:).^2,1))))*180/pi;
%     nodeAz = atan2(nodePos(2,:),nodePos(1,:))*180/pi;
%     nodeElDev(:,i) = (nodeEl-mean(nodeEl))';
%     nodeAzDev(:,i) = (nodeAz-mean(nodeAz))';
% end

nodeL = (floor(sqrt(sum(squeeze(nodePos(:,:,1)).^2,1))/150)+1)*150;
l = 2;
m = 2;
j = 1;
for i = l:m:n
    legEnt{j} = sprintf('Node %d (%d m)',i,nodeL(i));
    j = j+1;
end

figure
plot(timeVec,nodeY(l:m:end,:))
set(gca,'LineStyleOrder',{'-','--'})
xlabel 'Time [s]'
ylabel '$y_{ground}-\mu_{y_{ground}}$'
set(gca,'FontSize',12)
legend(legEnt,'Location','eastoutside')

figure
plot(timeVec,nodeElDev(l:m:end,:))
set(gca,'LineStyleOrder',{'-','--'})
xlabel 'Time [s]'
ylabel '$z_{ground}-\mu_{z_{ground}}$'
set(gca,'FontSize',12)
legend(legEnt,'Location','eastoutside')

figure
plot(timeVec,nodeAzDev(l:m:end,:))
set(gca,'LineStyleOrder',{'-','--'})
xlabel 'Time [s]'
ylabel '$z_{ground}-\mu_{z_{ground}}$'
set(gca,'FontSize',12)
legend(legEnt,'Location','eastoutside')

figure
plot(timeVec,nodeZ(l:m:end,:))
set(gca,'LineStyleOrder',{'-','--'})
xlabel 'Time [s]'
ylabel '$z_{ground}-\mu_{z_{ground}}$'
set(gca,'FontSize',12)
legend(legEnt,'Location','eastoutside')