
pathGeometry_refresh

% https://www.mathworks.com/matlabcentral/answers/102675-how-do-i-specify-the-matlab-code-for-the-function-in-an-embedded-matlab-function-block-from-the-matl
S = sfroot;
B = S.find('Path','pathGeometry_ul/pathGeometry','-isa','Stateflow.EMChart');
if tanVecOutEnbl
    B.Script = sprintf('function [posGroundOut,tanVecOut] = fcn(pathVariable,geomParams) \n %% This script is automatically created in pathGeometry_init.m\n[r,tanVecOut] = %s(pathVariable,geomParams) ;\n',popup.Value);
else
    B.Script = sprintf('function [posGroundOut] = fcn(pathVariable,geomParams) \n %% This script is automatically created in pathGeometry_init.m\n[posGroundOut] = %s(pathVariable,geomParams) ;\n',popup.Value);
end