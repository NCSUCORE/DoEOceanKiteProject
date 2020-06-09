function results = avlParseST(raw)
startString = 'Surface and Strip Forces by surface';
startIndex = regexp(raw,startString);
raw = raw(startIndex:end);

sectionStarts = regexp(raw,'Surface [\#] \d*\s*\D*\n');
sectionEnds = sectionStarts(2:end)-1;
sectionEnds(end+1) = length(raw);

% Pull out subsection for each suface
for ii = 1:length(sectionStarts)
   subSect{ii} = raw(sectionStarts(ii):sectionEnds(ii)); 
end

% Parse each subsection
for ii = 1:length(subSect)
   % Parse the first bit, non-tabular data
   % Get the surface name and number from the first line
   header = regexp(subSect{ii},'Surface [\#] \d*\s*\D*\n','match');
   surfaceNumber = regexp(header{1},'\d*','match');
   surfaceName   = strsplit(header{1},' ');
   surfaceName   = strrep([surfaceName{4:end-1}],'(','');
   surfaceName   = strrep(surfaceName,')','');
   surfaceName   = strrep(surfaceName,'-','_');
   surfaceNumber = str2double(surfaceNumber{1});
   
   % Create the field name and surface number property in the output
   % structure
   results.(surfaceName).surfaceNumber = surfaceNumber;
   
   % Pull out data from the first chunk of info
   startIdx = regexp(subSect{ii},'# Chordwise =');
   endIdx   = regexp(subSect{ii},'Forces referred to Ssurf');
   results.(surfaceName).netProperties = avlParseAtEqual(subSect{ii}(startIdx:endIdx-1));
   
   % Pull out data from the large table at the end
   startIdx = regexp(subSect{ii},'Strip Forces referred to Strip Area, Chord');
   endIdx   = length(subSect{ii});
   results.(surfaceName).tabular = avlParseTable(subSect{ii}(startIdx:endIdx-1));
   
end
end