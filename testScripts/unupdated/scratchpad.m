vhcl.setInitAngVelVec([0 0 0],'rad/s')
vhcl.setInitEulAng([0*pi/180 0*pi/180 180*pi/180],'rad')
initelev = 20;
initTL = fltCtrl.dockedTetherLength.Value; % m
vhcl.setInitPosVecGnd([-initTL*cosd(initelev),0,initTL*sind(initelev)],'m')
vhcl.setInitVelVecBdy([0 0 0],'m/s')

vhcl.initPosVecGnd.Value

vhcl.setICsOnPath(...
    .05,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.initPosVec.Value,... % Initial center point of path sphere
    (11/2)*norm([ 1 0 0 ])) % Initial speed

vhcl.initPosVecGnd.Value