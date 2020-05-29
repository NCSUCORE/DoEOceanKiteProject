function [ctrlVec,spdVec] = combinedCtrl(log,pastLapMeanFlowSpd,TL,pastCtrlVec,pastSpdVec,intraDrift)
%Define ctrlVec and spdVec here:
%ctrlVec is 8x1: [firstSpoolInCenter spoolInWidth ds1 ds2 ds3 ds4 ds5 lapInitTL]
%speedVec is 5x1: [vOut vIn vOut vIn vOut]
vOut = pastLapMeanFlowSpd / 3;
vIn = -vOut;

sc = pastCtrlVec(1);
sw = pastCtrlVec(2);

cleanLog = [0 0;...
    log(and(log(:,1)~=0,log(:,2)~=0),:)];
 
% Extract regions
r1 = cleanLog(and(cleanLog(:,1)>=0        ,cleanLog(:,1)<sc-sw),:);
r2 = cleanLog(and(cleanLog(:,1)>=sc-sw    ,cleanLog(:,1)<sc+sw),:);
r3 = cleanLog(and(cleanLog(:,1)>=sc+sw    ,cleanLog(:,1)<0.5+sc-sw),:);
r4 = cleanLog(and(cleanLog(:,1)>=0.5+sc-sw,cleanLog(:,1)<0.5+sc+sw),:);
r5 = cleanLog(and(cleanLog(:,1)>=0.5+sc+sw,cleanLog(:,1)<=1),:);

% Calculate average numerical derivative in each region ds/dt
ds1 = mean(diff(r1(:,1))./diff(r1(:,2)));
ds2 = mean(diff(r2(:,1))./diff(r2(:,2)));
ds3 = mean(diff(r3(:,1))./diff(r3(:,2)));
ds4 = mean(diff(r4(:,1))./diff(r4(:,2)));
ds5 = mean(diff(r5(:,1))./diff(r5(:,2)));

deltaVec = [ds1 ds2 ds3 ds4 ds5]';

dsInv = diag([1/ds1 1/ds2 1/ds3 1/ds4 1/ds5]);

spdVec = [vOut vIn vOut vIn vOut]';
V = diag(spdVec);

Delta = eye(5);
Delta(2,1) = -1;
Delta(3,2) = -1;
Delta(4,3) = -1;
Delta(5,4) = -1;

A  = [ 0  0 0.5 0.5 1]';
B1 = [ 1  1   1   1 0]';
B2 = [-1  1  -1   1 0]';

c1 = ones(1,5)*V*dsInv*Delta*(A+B1*sc);
c2 = ones(1,5)*V*dsInv*Delta*B2;

ctrlVec = pastCtrlVec;
if ~isnan(c1) && ~isnan(c2)
    sw = min([max([(intraDrift-c1)/c2 0]) sc]); % 0<=sw<=sc
end
ctrlVec(2) = sw;
ctrlVec(3:7) = deltaVec';
ctrlVec(8) = TL;