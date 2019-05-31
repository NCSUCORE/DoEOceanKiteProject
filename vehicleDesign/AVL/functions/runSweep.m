close all
dsgn = avlDesignGeometryClass;

dsgn.sweepCase.alpha = linspace(-10,10,2);
dsgn.sweepCase.beta  = linspace(-10,10,2);
dsgn.sweepCase.flap = [-2 2];
dsgn.sweepCase.aileron = [-2 2];
dsgn.sweepCase.elevator = [-2 2];
dsgn.sweepCase.rudder = [-2 2];

dsgn.writeInputFile
dsgn.buildLookupTable