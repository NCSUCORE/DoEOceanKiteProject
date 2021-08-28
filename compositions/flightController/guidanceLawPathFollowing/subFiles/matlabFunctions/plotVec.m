function plotVec(tVec,dVals,yLab)

dVals = squeeze(dVals);
if size(dVals,1) ~= 3
dVals = dVals';
end
cols = [228,26,28; 77,175,74; 55,126,184]./255;

for ii = 1:3
    plot(tVec,dVals(ii,:),'color',cols(ii,:));
    hold on;
end
grid on;
ylabel(yLab);
end
