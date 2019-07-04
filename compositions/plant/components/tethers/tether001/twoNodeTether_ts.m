close all
clear
clc
gndNodePos = [0 0 0]';
gndNodeVel = [0 0 0]';
airNodePos = [0 0 1]';
airNodeVel = [0 0 0]';
flowVec    = [1 0 0]';
unstretchedLength = norm(airNodePos(:)-gndNodePos(:));


numNodes 		 = 5;
thr(1).diameter 		 = 1;
thr(1).youngsMod 		 = 1;
thr(1).vehicleMass 		 = 1;
thr(1).dampingRatio 	 = 1;
thr(1).dragCoeff 		 = 0.5;
thr(1).density 			 = 1;

% thr(2).diameter 		 = 1;
% thr(2).youngsMod 		 = 1;
% thr(2).vehicleMass 		 = 1;
% thr(2).dampingRatio 	 = 1;
% thr(2).dragCoeff 		 = 0.5;
% thr(2).density 			 = 1;


sim('twoNodeTether_th')