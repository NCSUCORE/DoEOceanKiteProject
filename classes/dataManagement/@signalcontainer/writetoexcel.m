function writetoexcel(obj,fileName,sigNames)
%% Writes specified signals to excel file
for ii = 1:numel(sigNames)
    obj.(sigNames{ii}).writeToExcel(fileName)
end
end