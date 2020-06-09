function clean = avlOutputCleanup(raw)

% Step 1: chop the text into sections, where each section is the result
% from a single run
sectionStartIndicator = 'Vortex Lattice Output -- Total Forces';
outputEndIndicator =  'Operation of run case';
sectionStarts = regexp(raw,sectionStartIndicator);
sectionEnds = sectionStarts(2:end) - 1;
sectionEndIndices = regexp(raw,outputEndIndicator);
sectionEnds = [sectionEnds sectionEndIndices(end)];

for ii = 1:length(sectionEnds)
    sections{ii} = raw(sectionStarts(ii):sectionEnds(ii));
end

% Step 2: process each of those sections
for ii = 1:length(sections)
   % Get all data from the total forces output
   clean(ii).FT = avlParseFT(sections{ii});
   clean(ii).ST = avlParseST(sections{ii});
end

end