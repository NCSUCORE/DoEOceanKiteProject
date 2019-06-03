function parsedTable = avlParseTable(raw)
startIndex = regexp(raw,'j      ');
raw = strtrim(raw(startIndex:end));
lns = splitlines(raw);
lns = strrep(lns,'c cl','c_cl');
headers = genvarname(strsplit(lns{1},' '));

cols = textscan(raw,'%f   %f   %f   %f   %f   %f   %f   %f   %f   %f   %f   %f   %f',...
'HeaderLines',1,'Delimiter','\n');
for ii = 1:length(headers)
   parsedTable.(headers{ii}) = cols{ii}(1:end-1); 
end

end