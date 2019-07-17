clear
env = OCT.env;
env.addFlow({'water'},'FlowDensities',1000)
env.water.velVec.Value = [0 -1 0];
env.water.heading