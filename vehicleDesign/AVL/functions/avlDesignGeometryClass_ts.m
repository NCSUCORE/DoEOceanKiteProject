% close all
% dsgn = avlDesignGeometryClass
% dsgn.input_file_name = 'newName'
% dsgn.plot;
% dsgn.writeInputFile;
% dsgn.runCase;
% dsgn.buildLookupTable;

dsgn = avlDesignGeometryClass;
dsgn.wing_chord = 1.5;

save('saveFile','dsgn')