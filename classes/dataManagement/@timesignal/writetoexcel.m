function writetoexcel(obj,fileName)
%% Write data to user-specified excel file
writetable(obj.table,fileName,...
    'WriteVariableNames',true,'Sheet',obj.Name);
end