i0=find_system(gcb,'LookUnderMasks','on','FollowLinks','on','Name','Integrator');
i0=getSimulinkBlockHandle(i0{1});
i1=find_system(gcb,'LookUnderMasks','on','FollowLinks','on','Name','Integrator1');
i1=getSimulinkBlockHandle(i1{1});
i2=find_system(gcb,'LookUnderMasks','on','FollowLinks','on','Name','Integrator2');
i2=getSimulinkBlockHandle(i2{1});
rst=find_system(gcb,'LookUnderMasks','on','FollowLinks','on','Name','rst');
if ~isempty(rst)
    rst=getSimulinkBlockHandle(rst{1});
end
set_param(i0,'externalReset',externalReset)
set_param(i1,'externalReset',externalReset)
set_param(i2,'externalReset',externalReset)
if externalReset == "none" && ~isempty(rst)
    h=get_param([gcb,'/rst'],'lineHandles');
    delete_line(h.Outport(1));
    delete_block([gcb,'/rst']);
elseif externalReset ~= "none" && isempty(rst)
    add_block('built-in/Inport',[gcb,'/rst']);
    set_param([gcb,'/rst'],'position',[75   255   125   305])
    add_line(gcb,'rst/1',[get_param(i0,'Name'),'/2'])
    add_line(gcb,'rst/1',[get_param(i1,'Name'),'/2'])
    add_line(gcb,'rst/1',[get_param(i2,'Name'),'/2'])
end