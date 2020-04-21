% Function to write to excel
function writetoexcel(obj,fileName)
writetable(obj.table,fileName,...
    'WriteVariableNames',true,'Sheet',obj.Name);
end