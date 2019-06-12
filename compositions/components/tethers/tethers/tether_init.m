for ii = 1:numel(thr)
    thr(ii).initNodePoss = [...
        linspace(thr(ii).initGndStnAttchPt(1),thr(ii).initVhclAttchPt(1),thr(ii).N);...
        linspace(thr(ii).initGndStnAttchPt(2),thr(ii).initVhclAttchPt(2),thr(ii).N);...
        linspace(thr(ii).initGndStnAttchPt(3),thr(ii).initVhclAttchPt(3),thr(ii).N)];
    thr(ii).initNodePoss = thr(ii).initNodePoss(:,2:end-1);
    thr(ii).initNodeVels = zeros(size(thr(ii).initNodePoss));
end

createThrTenVecBus
createThrNodeBus(thr(1).N)

assignin('base','VSS_twoNodeTether',Simulink.Variant('1==1'))
assignin('base','VSS_NNodeTether',Simulink.Variant('1==1'))

numNodes = [thr(:).N];
if length(unique(numNodes))>1
    error('Tethers must have the same number of nodes')
else
    
    
    if numNodes(1) == 2
        set_param([gcb '/VariantSubsystem'], 'OverrideUsingVariant', 'VSS_twoNodeTether');
    else
        set_param([gcb '/VariantSubsystem'], 'OverrideUsingVariant', 'VSS_NNodeTether');
    end
end