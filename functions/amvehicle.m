classdef amvehicle < handle
    % a vehicle made up of slender bodis
    
    properties (SetAccess = private)
        sections  % 1xn array of section objects in the vehicle
        sectLocs  % 3xn array of section centroid locations
        sectOrnts % 3xn array of section orientation using 3-2-1 body rotations (i.e. psi, theta, phi)
    end % private properties
    
    methods
        function hobj = amvehicle
            % Make a vehicle, then add sections and locations to the
            % vehcile.
            hobj.sections = amsection.empty;
            hobj.sectLocs = [];
            hobj.sectOrnts = [];
        end
        
        function addSection(hobj,sctn,loc,rot)
            hobj.sections = [hobj.sections sctn];
            hobj.sectLocs = [hobj.sectLocs loc];
            hobj.sectOrnts = [hobj.sectOrnts rot];
        end
        
        function hfig = showme(hobj,clr)
            %disp('Displaying vehicle');
            if nargin < 2
                clr = 'r';
            end
            % show me what the vehicle currently looks like
            hfig = figure('Position',[200 300 900 600]);
            ax1 = axes('Parent',hfig); hold on;
            for i=1:1:numel(hobj.sections)
                B_C_a = rotate321(hobj.sectOrnts(1,i),hobj.sectOrnts(2,i),hobj.sectOrnts(3,i));
                secpts = hobj.sections(i).getShapePoints;
                for j = 1:1:length(secpts)
                    pts_B(:,j) = B_C_a*[0;secpts(:,j)] + hobj.sectLocs(:,i);
                end
                plot3(ax1,pts_B(1,:),pts_B(2,:),pts_B(3,:),clr);
                axscale = max(max(abs(pts_B)));
                axis([-axscale axscale -axscale axscale -axscale axscale]);                
            end % loop over sections
            hold off;
            axis equal;
            view(-45,30);
        end
        
        function MA = getAddedMass(hobj,rho)
            MA = zeros(6);
            for i=1:1:numel(hobj.sections)
                if nargin > 1
                    computeCoeffs(hobj.sections(i),rho); % Compute added mass for rho density (water is the default medium)
                end
                a22 = hobj.sections(i).MA22;
                a33 = hobj.sections(i).MA33;
                a44 = hobj.sections(i).MA44;
                dl = hobj.sections(i).diffl;
                xa = hobj.sectLocs(1,i); ya = hobj.sectLocs(2,i); za = hobj.sectLocs(3,i);
                psi = hobj.sectOrnts(1,i); theta = hobj.sectOrnts(2,i); phi = hobj.sectOrnts(3,i);
                
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
                m56 = - dl*(za*(ya*(a33*sin(theta)^2 + a22*cos(theta)^2*sin(psi)^2) + xa*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta)))) + xa*(ya*(a33*cos(phi)*cos(theta)*sin(theta) + a22*cos(theta)*sin(psi)*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta))) - xa*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))*(cos(psi)*sin(phi) - cos(phi)*sin(psi)*sin(theta)) - a33*cos(phi)*cos(theta)^2*sin(phi)))) - a44*dl*(sin(phi)*sin(psi) + cos(phi)*cos(psi)*sin(theta))*(cos(phi)*sin(psi) - cos(psi)*sin(phi)*sin(theta));
                m66 = dl*(ya*(ya*(a33*sin(theta)^2 + a22*cos(theta)^2*sin(psi)^2) + xa*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta)))) + xa*(xa*(a22*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))^2 + a33*cos(theta)^2*sin(phi)^2) + ya*(a33*cos(theta)*sin(phi)*sin(theta) - a22*cos(theta)*sin(psi)*(cos(phi)*cos(psi) + sin(phi)*sin(psi)*sin(theta))))) + a44*dl*(sin(phi)*sin(psi) + cos(phi)*cos(psi)*sin(theta))^2;
                MA = MA + [m11 m12 m13 m14 m15 m16;...
                           m12 m22 m23 m24 m25 m26;...
                           m13 m23 m33 m34 m35 m36;...
                           m14 m24 m34 m44 m45 m46;...
                           m15 m25 m35 m45 m55 m56;...
                           m16 m26 m36 m46 m56 m66];
            end
        end
    end % methods
    
end % vehicle

function B_C_a = rotate321(psi,theta,phi)
% For plotting sections in the body frame
    Rx_phi = ...
        [1 0 0;...
        0 cos(phi) sin(phi);...
        0 -sin(phi) cos(phi)];    
    Ry_theta =...
        [cos(theta) 0 -sin(theta);...
        0 1 0;...
        sin(theta) 0 cos(theta)];
    Rz_psi = ...
        [cos(psi) sin(psi) 0;...
        -sin(psi) cos(psi) 0;...
        0 0 1];
    B_C_a = Rx_phi*Ry_theta*Rz_psi;
end