function [MA] = getAddedMass(Input,vhcl)


%%  These can possibly change: For reference

% Input.wing.Thickness = 12;
% Input.wing.Sections = 20; 
% Input.hStab.Thickness = 12; 
% Input.hStab.Sections = 20; 
% Input.vStab.Thickness = 12; 
% Input.vStab.Sections = 10; 
% Input.fuse.Sections = 10; 
%% Setting up structure from vhlc and inputs 

cv.wing.rootChord = vhcl.wingRootChord.Value;
cv.wing.tipChord = vhcl.wingRootChord.Value*vhcl.wingTR.Value;   

% I did this instead of AR because AR should be b^2/S, but I thought you guys might be using AR = b/c_root

cv.wing.span = (vhcl.wingRootChord.Value*(1+vhcl.wingTR.Value)*0.5*vhcl.wingAR.Value);      % tip to tip
cv.wing.thckns = Input.wing.Thickness*0.01;      % as percent chord
cv.wing.LEsweep = vhcl.wingSweep.Value;          % Note that this is not the way that sweep is typically defined in the aerospace industry
cv.wing.dihedral = vhcl.wingDihedral.Value;   `  % Need to think about how this is defined. Typically it is mean chamber at c/4
cv.wing.incidence = vhcl.wingDihedral.Value;
cv.wing.secshape = 'ellipse';
cv.wing.nsects = Input.wing.Sections;
cv.hstab.rootChord = vhcl.hStab.rootChord.Value;
cv.hstab.tipChord = vhcl.hStab.TR.Value*vhcl.hStab.rootChord.Value;
cv.hstab.span = 2*vhcl.hStab.halfSpan.Value;
cv.hstab.thckns = Input.hStab.Thickness*0.01;      % as percent chord
cv.hstab.LEsweep = atan2d((cv.hstab.rootChord-cv.hstab.tipChord),cv.hstab.span);
cv.hstab.incidence = vhcl.hStab.incidence.Value;
cv.hstab.dihedral = vhcl.hStab.dihedral.Value;
cv.hstab.secshape = 'ellipse';
cv.hstab.nsects = Input.hStab.Sections;            % number of amsections for the horizontal stabilizer
cv.hstab.rootLE = vhcl.hStab.rSurfLE_WingLEBdy.Value;
cv.vstab.rootChord = vhcl.vStab.rootChord.Value;
cv.vstab.tipChord = vhcl.vStab.rootChord.Value*vhcl.vStab.TR.Value;
cv.vstab.span = vhcl.vStab.halfSpan.Value;
cv.vstab.LEsweep = vhcl.vStab.sweep.Value;
cv.vstab.incidence = vhcl.vStab.incidence.Value;
cv.vstab.secshape = 'ellipse';
cv.vstab.nsects = Input.vStab.Sections; % number of amsections for the vertical stabilizer
cv.vstab.rootLE = vhcl.vStab.rSurfLE_WingLEBdy.Value;
cv.vstab.thckns = Input.vStab.Thickness*0.01;  % as percent chord
cv.fuse.diameter = vhcl.fuse.diameter.Value;
cv.fuse.length = vhcl.fuse.length.Value;
cv.fuse.secshape = 'ellipse';
cv.fuse.shape = 'spheroid';
cv.fuse.nsects = Input.fuse.Sections; % number of amsections for the fuselage
cv.fuse.RNose_LE = vhcl.fuse.rNose_LE.Value;


runname = 'fullSizeKiteComp';
savefigs = false;
MA = addedMassKiteVehicle(cv,runname,savefigs);
MA = round(MA);

if false % checks with previous baseline. Change to true if check is needed 
oldMA = [130           0           0           0           9           0;...
           0        1221           0        -625           0        2527;...
           0           0        9316           0       -7557           0;...
           0        -625           0       67352           0       -2879;...
           9           0       -7557           0       20442           0;...
           0        2527           0       -2879           0       14123];
diffMA = MA - oldMA;
diffFrac = diffMA./oldMA;
diffFrac(isnan(diffFrac)) = 0;
% Looks good, now we can explore a litte.
% Save this one as the baseline for comparison
baselineMA = MA;
end 

end 