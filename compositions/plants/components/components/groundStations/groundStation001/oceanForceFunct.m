function [oceanForceBdy,oceanMomentBdy] = oceanForceFunct(lumpedMassPosBdy,cmAccGnd,velVecGnd,...
    velocitiesEachLM,angularVelVec,angAccVec,flowAccPerLM,gnd2bdy,rho,V,dragCoef,addedMassCoef,numLM,submergedMat,lumpedMassAreaMat,normalVecMat)
%OCEANFORCEFUNCT Summary of this function goes here
%   Detailed explanation goes here
angAccVecMat = repmat(angAccVec,1,numLM);
cmAccGndMat = repmat(cmAccGnd,1,numLM);
velVecGndMat = repmat(velVecGnd,1,numLM);
angularVelVecMat = repmat(angularVelVec,1,numLM);




%% acceleration of each lumped mass point in the body frame

angACrossR = cross(angAccVecMat,lumpedMassPosBdy);

coriolas = cross(angularVelVecMat, lumpedMassPosBdy); % not really coriolas, just an intermiadiate step to get omega squared R


omegaSqrdR = cross(angularVelVecMat,coriolas );

accLMGnd = cmAccGndMat + angACrossR + omegaSqrdR;


%% Relative accelerations
relVelGnd = velVecGndMat - velocitiesEachLM;
relAccGnd = flowAccPerLM - accLMGnd;


%% F int 1
fInt1 = rho*V*flowAccPerLM;

%% F int 2
fInt2 = rho*V*(addedMassCoef *relAccGnd);

%% Areas drag

D = sum(normalVecMat'.*relVelGnd',2);
LMAMT = lumpedMassAreaMat'; % lumped mass area mat transposed 
RVGT = relVelGnd'; % vel veg gnd mat transposed, Im not sure if indexing and then transposing messes it up so I am transposing before
Aproj = zeros(numLM,3);
Aproj(D>0,:) = LMAMT(D>0,:).*RVGT(D>0,:);

temp = dragCoef*Aproj';
%  fDrag = .5*rho*(sqrt(sum(RVGT.*RVGT,2)))'.*(temp);
% 
% 
% 
% oceanForceGnd = fInt1 + fInt2 + fDrag';
% 
% oceanForceBdy = sum(gnd2bdy*oceanForceGnd,2); 
% 
% oceanMomentBdy = sum(cross(lumpedMassPosBdy,oceanForceBdy),2);
oceanForceBdy = 2;

oceanMomentBdy = 3; 




 
 
end

