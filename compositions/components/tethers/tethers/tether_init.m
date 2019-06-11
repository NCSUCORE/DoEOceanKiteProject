for ii = 1:numel(thr)
   thr(ii).initNodePoss = [...
       linspace(thr(ii).initGndStnAttchPt(1),thr(ii).initVhclAttchPt(1),thr(ii).N);...
       linspace(thr(ii).initGndStnAttchPt(2),thr(ii).initVhclAttchPt(2),thr(ii).N);...
       linspace(thr(ii).initGndStnAttchPt(3),thr(ii).initVhclAttchPt(3),thr(ii).N)];
    thr(ii).initNodeVels = zeros(size(thr(ii).initNodePoss));
end

createThrTenVecBus
createThrNodeBus(numel(thr))
