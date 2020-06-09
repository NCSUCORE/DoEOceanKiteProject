function parsedTable = avlParseTable(raw)
try
startIndex = regexp(raw,' j ');
raw = raw(startIndex+1:end);

splitData = strsplit(raw,'\n');
splitData = cellfun(@(x) strtrim(x),splitData,'UniformOutput',false);
headers = strsplit(strrep(splitData{1},'c cl','c_cl'),' ');
data = [sprintf('%s\n',splitData{2:end-1}),splitData{end}];
data = regexprep(data, ' +', ',');
data = textscan(data,'','Delimiter',',','CollectOutput',true);
data = data{1};

for ii = 1:size(data,2)

   parsedTable.(genvarname(headers{ii})) = data(:,ii); 

end

    catch
        x = 1;
    end
end