function [MA,v] = addedMassKiteVehicle(cv,runname,savefigs)
% This function returns an added mass matrix and a kite vehicle with the
% body frame origin at the centerline (root) leading edge (LE) of the wing.
% This function makes use of the following assumptions:
%   - The wing is made up of symmetric airfoils that are approximated by
%      ellipses. This assumption helps locate the wing amsections in the
%      vehicle frame and has a negligible impact on the computed values. 
%   - The fuselage is a body of rotation.
%   - The origin of the vehicle coordinate system is coincident with the
%      the fuselage axis of rotation and a line that is perpendicular with
%      the fuselage axis of rotation and wing leading edge (LE).
%   - The wing and horizontal stabilizer are symmetrical about the fuselage
%      axis of rotation.
% Temporary assumptions that can easily be relaxed with minor development
%   - The fuselage is a speheroid

% A better way to do this would be to have a slenderbody class and derived
% classes for the types of vehicles and slender bodies. i.e. kite < vehicle
% wing < slenderbody.
if nargin < 1
    cv.wing.rootChord = 1;
    cv.wing.tipChord = 0.8; % I did this instead of AR because AR should be b^2/S, but I thought you guys might be using AR = b/c_root
    cv.wing.span = 10;      % tip to tip
    cv.wing.thckns = 0.12;  % as percent chord
    cv.wing.LEsweep = 15;   % Note that this is not the way that sweep is typically defined in the aerospace industry
    cv.wing.dihedral = 20;   % Need to think about how this is defined. Typically it is mean chamber at c/4
    cv.wing.incidence = 0;
    cv.wing.secshape = 'ellipse';
    cv.wing.nsects = 30;
    cv.hstab.rootChord = 0.5;
    cv.hstab.tipChord = 0.4;
    cv.hstab.span = 4;
    cv.hstab.thckns = 0.12;  % as percent chord
    cv.hstab.LEsweep = atan2d((cv.hstab.rootChord-cv.hstab.tipChord),cv.hstab.span);
    cv.hstab.incidence = -13.5;
    cv.hstab.dihedral = -20;
    cv.hstab.secshape = 'ellipse';
    cv.hstab.nsects = 25; % number of amsections for the horizontal stabilizer
    cv.hstab.rootLE = [5.5;0;0];
    cv.vstab.rootChord = 0.65;
    cv.vstab.tipChord = 0.52;
    cv.vstab.span = 2.4375;
    cv.vstab.LEsweep = 10;
    cv.vstab.incidence = -25;
    cv.vstab.secshape = 'ellipse';
    cv.vstab.nsects = 10; % number of amsections for the vertical stabilizer
    cv.vstab.rootLE = [5.35;0;0];
    cv.vstab.thckns = 0.12;  % as percent chord
    cv.fuse.diameter = 0.4445;
    cv.fuse.length = 9.02;
    cv.fuse.secshape = 'ellipse';
    cv.fuse.shape = 'spheroid';
    cv.fuse.nsects = 40; % number of amsections for the fuselage
    cv.fuse.RNose_LE = [-2;0;0];
    %vhcl.LE2
    runname = 'test';
    savefigs = true;
elseif nargin == 1
    runname = '';
    savefigs = false;
elseif nargin ~= 3
    error(['Only works with 0, 1, or 3 arguments. 0 is for testing', ...
    ', 1 is normal use where the argument is a struct containing the vehicle',...
    ' parameters, and 3 is to control saving stuff. You passed %d.'],nargin);
end

% make a vehicle object
v = amvehicle;

% add amsections - vehicleObject.addSection(amsection,location,rotation)
% Fuselage
if(strcmp(cv.fuse.shape,'spheroid'))
    % A spheroid projects an ellipse from the side. If x is the coordinate
    % along the axis and r is the perpendicular coordinate, then the
    % equation for a ellipse is (x-xo)^2/a^2 + (r-ro)^2/b^2 = 1
    % where a is the semimajor axis and b is the semiminor axis. 
    sectWidth = cv.fuse.length/cv.fuse.nsects;
    a = cv.fuse.length*0.5;
    b = cv.fuse.diameter*0.5;
    % xo is defined from the center of the ellipse.
    xo = cv.fuse.RNose_LE(1) + a;
    x = xo - a + sectWidth/2;
    r = b*sqrt(1-(x-xo)^2/a^2);
    v.addSection(amsection(cv.fuse.secshape,r,r,sectWidth),[x;0;0],[0;0;0]);
    for i=2:1:cv.fuse.nsects % add circles in the +x direction towards the tail
        x = x + sectWidth;
        r = b*sqrt(1-(x-xo)^2/a^2);
        v.addSection(amsection(cv.fuse.secshape,r,r,sectWidth),[x;0;0],[0;0;0]);
    end
    % v.showme('b'); % for development/debugging - lets you look at the
    % shape you just made.
else
    error('Only spheroid fuselage currently supported');
end
    
% Wings
% Easiest to add one at a time
sectWidth = cv.wing.span/cv.wing.nsects;
for i=1:1:cv.wing.nsects/2 % add circles in the +y direction
    y = (i-1)*sectWidth + sectWidth/2;
    if(strcmp(cv.fuse.shape,'spheroid'))
        a = cv.fuse.length*0.5;
        b = cv.fuse.diameter*0.5;
        xo = cv.fuse.RNose_LE(1) + a;
        if abs(cv.fuse.RNose_LE(1)) > 2*a % if the wing is not on the body
            minRadius = 0;
        else
            minRadius = b*sqrt(1-(0-xo)^2/a^2);
        end
    else
        error('Only spheroid fuselage currently supported');
    end
    if abs(y) < minRadius % don't need internal amsections - todo make this radius at loc
        continue;
    end
    chord = 2*(cv.wing.tipChord - cv.wing.rootChord)/cv.wing.span*y + cv.wing.rootChord;
    offset = chord/2 + y*tand(cv.wing.LEsweep);
    airfoilThickness = cv.wing.thckns*chord;
    v.addSection(amsection(cv.wing.secshape,chord/2,airfoilThickness/2,sectWidth),...
        [offset;y;y*tand(cv.wing.dihedral)],...
        [90*pi/180;-cv.wing.incidence*pi/180;-cv.wing.dihedral*pi/180]); 
    % Note that we can rotate a little about x to account for dihedral which will create more off-diagonal terms
end
%v.showme('r');
for i=1:1:cv.wing.nsects/2 % add circles in the +y direction
    y = -(i-1)*sectWidth - sectWidth/2;
    if(strcmp(cv.fuse.shape,'spheroid'))
        a = cv.fuse.length*0.5;
        b = cv.fuse.diameter*0.5;
        xo = cv.fuse.RNose_LE(1) + a;
        if abs(cv.fuse.RNose_LE(1)) > 2*a
            minRadius = 0;
        else
            minRadius = b*sqrt(1-(0-xo)^2/a^2);
        end
    else
        error('Only spheroid fuselage currently supported');
    end
    if abs(y) < minRadius % don't need internal amsections - todo make this radius at loc
        continue;
    end
    chord = -2*(cv.wing.tipChord - cv.wing.rootChord)/cv.wing.span*y + cv.wing.rootChord;
    offset = chord/2 - y*tand(cv.wing.LEsweep);
    airfoilThickness = cv.wing.thckns*chord;
    v.addSection(amsection(cv.wing.secshape,chord/2,airfoilThickness/2,sectWidth),...
        [offset;y;-y*tand(cv.wing.dihedral)],...
        [90*pi/180;-cv.wing.incidence*pi/180;cv.wing.dihedral*pi/180]); 
    % Note that we can rotate a little about x to account for dihedral which will create more off-diagonal terms
end
%v.showme('b');

% Horizontal Stabilizer
% Easiest to add one at a time
sectWidth = cv.hstab.span/cv.hstab.nsects;
for i=1:1:cv.hstab.nsects/2 % add circles in the +y direction
    y = (i-1)*sectWidth + sectWidth/2;
    if(strcmp(cv.fuse.shape,'spheroid'))
        a = cv.fuse.length*0.5;
        b = cv.fuse.diameter*0.5;
        xo = cv.fuse.RNose_LE(1) + a;
        if abs(cv.hstab.rootLE(1)) > a + xo 
            minRadius = 0;
        else
            minRadius = b*sqrt(1-(cv.hstab.rootLE(1)-xo)^2/a^2);
        end
    else
        error('Only spheroid fuselage currently supported');
    end
    if abs(y) < minRadius % don't need internal amsections - todo make this radius at loc
        continue;
    end
    chord = 2*(cv.hstab.tipChord - cv.hstab.rootChord)/cv.hstab.span*y + cv.hstab.rootChord;
    offset = chord/2 + y*tand(cv.hstab.LEsweep) + cv.hstab.rootLE(1);
    airfoilThickness = cv.hstab.thckns*chord;
    v.addSection(amsection(cv.hstab.secshape,chord/2,airfoilThickness/2,sectWidth),...
        [offset;y;y*tand(cv.hstab.dihedral) + cv.hstab.rootLE(3)],...
        [90*pi/180;-cv.hstab.incidence*pi/180;-cv.hstab.dihedral*pi/180]); 
    % Note that we can rotate a little about x to account for dihedral which will create more off-diagonal terms
end
%v.showme('r');
for i=1:1:cv.hstab.nsects/2 % add circles in the +y direction
    y = -(i-1)*sectWidth - sectWidth/2;
    if(strcmp(cv.fuse.shape,'spheroid'))
        a = cv.fuse.length*0.5;
        b = cv.fuse.diameter*0.5;
        xo = cv.fuse.RNose_LE(1) + a;
        if abs(cv.hstab.rootLE(1)) > a + xo 
            minRadius = 0;
        else
            minRadius = b*sqrt(1-(cv.hstab.rootLE(1)-xo)^2/a^2);
        end
    else
        error('Only spheroid fuselage currently supported');
    end
    if abs(y) < minRadius % don't need internal amsections - todo make this radius at loc
        continue;
    end
    chord = -2*(cv.hstab.tipChord - cv.hstab.rootChord)/cv.hstab.span*y + cv.hstab.rootChord;
    offset = chord/2 - y*tand(cv.hstab.LEsweep) + cv.hstab.rootLE(1);
    airfoilThickness = cv.hstab.thckns*chord;
    v.addSection(amsection(cv.hstab.secshape,chord/2,airfoilThickness/2,sectWidth),...
        [offset;y;-y*tand(cv.hstab.dihedral) + cv.hstab.rootLE(3)],...
        [90*pi/180;-cv.hstab.incidence*pi/180;cv.hstab.dihedral*pi/180]); 
    % Note that we can rotate a little about x to account for dihedral which will create more off-diagonal terms
end
%v.showme('b');

% Vertical Stabilizer
sectWidth = cv.vstab.span/cv.vstab.nsects;
for i=1:1:cv.vstab.nsects % add circles in the +y direction
    z = (i-1)*sectWidth + sectWidth/2;
    if(strcmp(cv.fuse.shape,'spheroid'))
        a = cv.fuse.length*0.5;
        b = cv.fuse.diameter*0.5;
        xo = cv.fuse.RNose_LE(1) + a;
        if cv.hstab.rootLE(1) > b
            minRadius = 0;
        else
            minRadius = b*sqrt(1-(cv.hstab.rootLE(1)-xo)^2/a^2);
        end
    else
        error('Only spheroid fuselage currently supported');
    end
    if abs(z) < minRadius % don't need internal amsections - todo make this radius at loc
        continue;
    end
    chord = (cv.vstab.tipChord - cv.vstab.rootChord)/cv.vstab.span*z + cv.vstab.rootChord;
    offset = chord/2 + z*tand(cv.vstab.LEsweep) + cv.vstab.rootLE(1);
    airfoilThickness = cv.vstab.thckns*chord;
    v.addSection(amsection(cv.vstab.secshape,chord/2,airfoilThickness/2,sectWidth),...
        [offset + cv.vstab.rootLE(3);0;z],...
        [90*pi/180;cv.vstab.incidence*pi/180;90*pi/180]); 
    % Note that we can rotate a little about x to account for dihedral which will create more off-diagonal terms
end

if savefigs
    hfig1 = v.showme('k');
    if ~exist([pwd '\output\figs'],'dir')
        mkdir([pwd '\output\figs']);
    end
    hfig1.CurrentAxes.Color = 'none';
    hfig1.CurrentAxes.Title.String = ['Sections for ' runname ' in the body frame.'];
    hfig1.CurrentAxes.XLabel.String = 'x';
    hfig1.CurrentAxes.YLabel.String = 'y';
    hfig1.CurrentAxes.ZLabel.String = 'z';
    savefig(hfig1,[pwd '\output\figs\' runname '.fig']);
%     saveas([pwd '\output\figs\' runname], '-png', '-transparent');
end

% OK, let's see the added mass matrix for this guy
MA = v.getAddedMass;
%MA = round(MA) % round to the nearest integer to remove numerical noise