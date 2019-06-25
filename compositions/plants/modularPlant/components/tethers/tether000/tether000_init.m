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