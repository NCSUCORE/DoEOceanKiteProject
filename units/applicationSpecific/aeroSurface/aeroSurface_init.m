% Aerodynamic surface coordinate system:
% x is chordwise direction from leading edge to trailing edge
% y is selected so that positive rotation about this unit vector
% results in what the user wants positive control surface deflection to be
% z is formed from the cross product.

if abs(dot(uSpan,uChord))>1e-10
    warndlg('Rotation unit vec and chord unit vec should be orthogonal.','Non-orthoginal vectors')
end

if abs(1-sqrt(sum(uSpan.^2)))>1e-10
    warndlg('Span unit vector is not unit length.','Non-unit vector')
end

if abs(1-sqrt(sum(uChord.^2)))>1e-10
    warndlg('Chord unit vector is not unit length.','Non-unit vector')
end
xUnitVec = uChord;
yUnitVec = uSpan;
zUnitvec = cross(xUnitVec,yUnitVec);

% Rotation matrix to go from body coordinates to aero surface coordinates
RBody2Surf = [xUnitVec(:)';...
     yUnitVec(:)';...
     zUnitvec(:)'];
 
 RSurf2Body = inv(RBody2Surf);
 
 % Populate the list of airfoils
 maskObj = Simulink.Mask.get(gcb);
 airfoilSelectionObj = maskObj.Parameters(strcmpi({maskObj.Parameters.Name},'airfoilSelection'));
 files = dir(fullfile(fileparts(which(mfilename)),'library','*.txt'));
 airfoilSelectionObj.TypeOptions = {files.name};