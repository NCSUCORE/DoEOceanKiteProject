close all
dsgn = avlDesignGeometryClass;
dsgn.plot;
dsgn.runCase;
tic
dsgn.buildLookupTable;
toc