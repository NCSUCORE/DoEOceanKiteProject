 ctrl.fun = @constantUniformFlow_bc;
 ctrl.fun1 = @plant_bc;
 ctrl.fun2 = @pathFollowingController_bc;
 ctrl.fun3 = @oneDoFGndStnCtrl_bc;
 ctrl.fun4 = @oneTetherThreeSurfaceCtrl_bc;
 save(fullfile(fileparts(which(mfilename)),strrep(mfilename,'_bs','')),'ctrl')