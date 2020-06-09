tenMat = squeeze(tsc.anchThrNode1FVec.Data(:,1,:,:));

t1sq = squeeze(tenMat(:,1,:).^2); 
t2sq = squeeze(tenMat(:,2,:).^2); 
t3sq = squeeze(tenMat(:,3,:).^2);

t1 = sqrt(sum(t1sq,1));
t2 = sqrt(sum(t2sq,1));
t3 = sqrt(sum(t3sq,1)) ;

plot(tsc.anchThrNode1FVec.Time , t1 + t2 + t3)

title('3 Tether Ten Mag')
xlabel('Time (s)')
ylabel('Tension (N)')
