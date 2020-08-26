function dMA = getDiffMij(s,loc,ornt)
% OBSOLETE
% Replaecd by getAddedMass in the vehicle class.
% todo remove this function and replace where ever it is used.
% Computes the differential added mass contribution to a slender body in a
% body frame.
% NOTE this version is assuming that the sections are symmetrical (i.e.
% only what is available in the section class as of 07JAN2020).

% s = a section object
% loc = location of the centroid in the body frame
% ornt = orientation angles in the body frame following 3-2-1 sequence

psi = ornt(1);   % psi about z
theta = ornt(2); % then theta about y
phi = ornt(3);   % then phi about x

xa = loc(1);
ya = loc(2);
za = loc(3);

dl = s.diffl;
a22 = s.MA22;
a33 = s.MA33;
a44 = s.MA44;

m11 = dl*(a33*sin(theta)^2 + a22*cos(theta)^2*sin(psi)^2);
m12 = -dl*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta)));
m13 = -dl*(a33*cos(phi)*cos(theta)*sin(theta) + a22*cos(theta)*sin(psi)*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)));
m14 = -dl*(ya*(a33*cos(phi)*cos(theta)*sin(theta) + a22*cos(theta)*sin(psi)*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))) - za*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))));
m15 = dl*(za*(a33*sin(theta)^2 + a22*cos(theta)^2*sin(psi)^2) + xa*(a33*cos(phi)*cos(theta)*sin(theta) + a22*cos(theta)*sin(psi)*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))));
m16 = -dl*(ya*(a33*sin(theta)^2 + a22*cos(theta)^2*sin(psi)^2) + xa*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))));
m22 = dl*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))^2 + a33*cos(theta)^2*sin(phi)^2);
m23 = -dl*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) - a33*cos(phi)*cos(theta)^2*sin(phi));
m24 = -dl*(za*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))^2 + a33*cos(theta)^2*sin(phi)^2) + ya*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) - a33*cos(phi)*cos(theta)^2*sin(phi)));
m25 = -dl*(za*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))) - xa*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) - a33*cos(phi)*cos(theta)^2*sin(phi)));
m26 = dl*(xa*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))^2 + a33*cos(theta)^2*sin(phi)^2) + ya*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))));
m33 = dl*(a22*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))^2 + a33*cos(phi)^2*cos(theta)^2);
m34 = dl*(za*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) - a33*cos(phi)*cos(theta)^2*sin(phi)) + ya*(a22*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))^2 + a33*cos(phi)^2*cos(theta)^2));
m35 = -dl*(za*(a33*cos(phi)*cos(theta)*sin(theta) + a22*cos(theta)*sin(psi)*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))) + xa*(a22*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))^2 + a33*cos(phi)^2*cos(theta)^2));
m36 = dl*(ya*(a33*cos(phi)*cos(theta)*sin(theta) + a22*cos(theta)*sin(psi)*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))) - xa*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) - a33*cos(phi)*cos(theta)^2*sin(phi)));
m44 = dl*(ya*(za*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) - a33*cos(phi)*cos(theta)^2*sin(phi)) + ya*(a22*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))^2 + a33*cos(phi)^2*cos(theta)^2)) + za*(za*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))^2 + a33*cos(theta)^2*sin(phi)^2) + ya*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) - a33*cos(phi)*cos(theta)^2*sin(phi)))) + a44*dl*cos(psi)^2*cos(theta)^2;
m45 = dl*(za*(za*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))) - xa*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) - a33*cos(phi)*cos(theta)^2*sin(phi))) - ya*(za*(a33*cos(phi)*cos(theta)*sin(theta) + a22*cos(theta)*sin(psi)*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))) + xa*(a22*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))^2 + a33*cos(phi)^2*cos(theta)^2))) - a44*dl*cos(psi)*cos(theta)*(cos(phi)*sin(psi) - cos(psi)*sin(phi)*sin(theta));
m46 = dl*(ya*(ya*(a33*cos(phi)*cos(theta)*sin(theta) + a22*cos(theta)*sin(psi)*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))) - xa*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) - a33*cos(phi)*cos(theta)^2*sin(phi))) - za*(xa*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))^2 + a33*cos(theta)^2*sin(phi)^2) + ya*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))))) + a44*dl*cos(psi)*cos(theta)*(sin(phi)*sin(psi) + cos(phi)*cos(psi)*sin(theta));
m55 = dl*(za*(za*(a33*sin(theta)^2 + a22*cos(theta)^2*sin(psi)^2) + xa*(a33*cos(phi)*cos(theta)*sin(theta) + a22*cos(theta)*sin(psi)*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)))) + xa*(za*(a33*cos(phi)*cos(theta)*sin(theta) + a22*cos(theta)*sin(psi)*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))) + xa*(a22*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))^2 + a33*cos(phi)^2*cos(theta)^2))) + a44*dl*(cos(phi)*sin(psi) - cos(psi)*sin(phi)*sin(theta))^2;
m56 = -dl*(za*(ya*(a33*sin(theta)^2 + a22*cos(theta)^2*sin(psi)^2) + xa*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta)))) + xa*(ya*(a33*cos(phi)*cos(theta)*sin(theta) + a22*cos(theta)*sin(psi)*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))) - xa*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) - a33*cos(phi)*cos(theta)^2*sin(phi)))) - a44*dl*(sin(phi)*sin(psi) + cos(phi)*cos(psi)*sin(theta))*(cos(phi)*sin(psi) - cos(psi)*sin(phi)*sin(theta));
m66 = dl*(ya*(ya*(a33*sin(theta)^2 + a22*cos(theta)^2*sin(psi)^2) + xa*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta)))) + xa*(xa*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))^2 + a33*cos(theta)^2*sin(phi)^2) + ya*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))))) + a44*dl*(sin(phi)*sin(psi) + cos(phi)*cos(psi)*sin(theta))^2;

dMA = [m11, m12, m13, m14, m15, m16;...
       m12, m22, m23, m24, m25, m26;...
       m13, m23, m33, m34, m35, m36;...
       m14, m24, m34, m44, m45, m46;...
       m15, m25, m35, m45, m55, m56;...
       m16, m26, m36, m46, m56, m66];