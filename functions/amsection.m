classdef amsection < handle
    
    properties (SetAccess = private)
        lenY   % [real] characteristic length in the y direction
        lenZ   % [real] characteristic length in the z direction
        shape  % [str] shape of the section ('ellipse' 'rectangle' 'diamond')
        MA22   % [real] hydrodynamic mass in the y direction due to acceleration in the y direction 
        MA33   % [real] hydrodynamic mass in the z direction due to acceleration in the z direction 
        MA44   % [real] hydrodynamic mass about the x axis due to angular acceleration about the x axis 
        diffl  % [real] differential length of the section
    end %properties
    
    methods
        function hobj = amsection(shp,ly,lz,dl,m1,m2,m3)
            if nargin < 4
                dl = NaN;
            end
            if nargin > 4
                % Use this to create a section with user defined added mass
                % values
                % todo implement
                error('User defined added mass for sections not implemented');
            end
            rho = 1000; % Assume water for now
            [m22, m33, m44] = amsection.computeAddedMass(rho,shp,ly,lz);
            % todo validate. rectangle and diamond must have lenY and lenZ > 0
            hobj.shape = shp;
            hobj.lenY = ly;
            hobj.lenZ = lz;
            hobj.MA22 = m22;
            hobj.MA33 = m33;
            hobj.MA44 = m44;
            hobj.diffl = dl;
        end
        
        function hfig = showme(hobj)
            dim = [0.4 0.4 0.2 0.2];
            switch hobj.shape
                case 'ellipse'
                    hfig = figure;
                    if hobj.lenY == 0 || hobj.lenZ == 0
                        if hobj.lenY > 0
                            x = linspace(-hobj.lenY,hobj.lenY,1000);
                            y = zeros(size(x));
                            limX = max(x);
                            limY = 0.5*limX;
                            dim = [0.4 0.51 0.2 0.2];
                        else
                            y = linspace(-hobj.lenZ,hobj.lenZ,1000);
                            x = zeros(size(y));
                            limY = max(y);
                            limX = limY;
                            dim = [0.525 0.4 0.2 0.2];
                        end
                    else
                    x = linspace(-hobj.lenY,hobj.lenY,1000);
                    y = hobj.lenZ*sqrt(1-x.^2/hobj.lenY^2);
                    limX = hobj.lenY;
                    limY = hobj.lenZ;
                    end
                    plot(x,y,'r',x,-y,'r','LineWidth',2.0);
                    axis equal                    
                    axis(1.1*[-limX limX -limY limY])                    
                    str = {['a_2_2 = ' num2str(hobj.MA22,'%4.3e')],['a_3_3 = ' num2str(hobj.MA33,'%4.3e')],['a_4_4 = ' num2str(hobj.MA44,'%4.3e')]};
                    annotation('textbox',dim,'String',str,'FitBoxToText','on');
                    xlabel('Y'); ylabel('Z');
                case 'rectangle'
                    hfig = figure;
                    plot([-hobj.lenY,hobj.lenY],[-hobj.lenZ,-hobj.lenZ],'r',...
                        [-hobj.lenY,hobj.lenY],[hobj.lenZ,hobj.lenZ],'r',...
                        [-hobj.lenY,-hobj.lenY],[-hobj.lenZ,hobj.lenZ],'r',...
                        [hobj.lenY,hobj.lenY],[-hobj.lenZ,hobj.lenZ],'r','LineWidth',2.0);
                    axis(1.1*[-hobj.lenY hobj.lenY  -hobj.lenZ hobj.lenZ])
                    axis equal
                    str = {['MA22 = ' num2str(hobj.MA22,'%4.3e')],['MA33 = ' num2str(hobj.MA33,'%4.3e')],['MA44 = ' num2str(hobj.MA44,'%4.3e')]};
                    annotation('textbox',dim,'String',str,'FitBoxToText','on');
                    xlabel('Y'); ylabel('Z');
                case 'diamond'
                    hfig = figure;
                    plot([-hobj.lenY,0],[0,hobj.lenZ],'r',...
                        [0,hobj.lenY],[hobj.lenZ,0],'r',...
                        [hobj.lenY,0],[0,-hobj.lenZ],'r',...
                        [0,-hobj.lenY],[-hobj.lenZ,0],'r','LineWidth',2.0);
                    axis(1.1*[-hobj.lenY hobj.lenY  -hobj.lenZ hobj.lenZ])
                    axis equal
                    str = {['MA22 = ' num2str(hobj.MA22,'%4.3e')],['MA33 = ' num2str(hobj.MA33,'%4.3e')],['MA44 = ' num2str(hobj.MA44,'%4.3e')]};
                    annotation('textbox',dim,'String',str,'FitBoxToText','on');
                    xlabel('Y'); ylabel('Z');
                otherwise
                    error('Unknown section shape')
            end % switch
        end % showme
        
        function pts = getShapePoints(hobj)
            % Gets points for plotting
            switch hobj.shape
                case 'ellipse'
                    numEllipsePoints = 100;
                    if hobj.lenY == 0 || hobj.lenZ == 0
                        if hobj.lenY > 0
                            x = linspace(-hobj.lenY,hobj.lenY,numEllipsePoints);
                            y = zeros(size(x));
                        else
                            y = linspace(-hobj.lenZ,hobj.lenZ,numEllipsePoints);
                            x = zeros(size(y));
                        end
                    else
                        x = linspace(-hobj.lenY,hobj.lenY,numEllipsePoints);
                        y = hobj.lenZ*sqrt(1-x.^2/hobj.lenY^2);
                    end
                    pts = [[x -x];[y -y]];
                case 'rectangle'
                    pts = [-hobj.lenY,hobj.lenY,-hobj.lenY,hobj.lenY;...
                           -hobj.lenZ,-hobj.lenZ,hobj.lenZ,hobj.lenZ];
                case 'diamond'
                    pts = [-hobj.lenY,hobj.lenY,-hobj.lenY,hobj.lenY;...
                           -hobj.lenZ,-hobj.lenZ,hobj.lenZ,hobj.lenZ];
                otherwise
                    error('Unknown section shape')
            end % switch
        end % getShapePoints
        
        function computeCoeffs(hobj,rho)
            [hobj.MA22, hobj.MA33, hobj.MA44] = hobj.computeAddedMass(rho,hobj.shape,hobj.lenY,hobj.lenZ);
        end % computeCoeff
    end % methods
    
    methods(Static)
        function [m22, m33, m44] = computeAddedMass(rho,shp,ly,lz)
            switch shp
                case 'ellipse'
                    m22 = pi*rho*lz^2;
                    m33 = pi*rho*ly^2;
                    m44 = 0.125*pi*rho*(ly^2-lz^2)^2;
                case 'rectangle'
                    yz = ly/lz;
                    if ly > lz % long rectangle
                        if yz <= 3.5 % slightly long rectangle
                            m22 = 1.7*pi*rho*lz^2;
                            m33 = 1.36*pi*rho*ly^2;
                            m44 = 0.15*pi*rho*ly^4;
                        elseif yz > 3.5 && yz <= 7.5 % long rectangle
                            m22 = 1.98*pi*rho*lz^2;
                            m33 = 1.21*pi*rho*ly^2;
                            m44 = 0.15*pi*rho*ly^4;
                        elseif yz > 7.5 % really long rectanlge
                            m22 = 2.23*pi*rho*lz^2;
                            m33 = 1.14*pi*rho*ly^2;
                            m44 = 0.15*pi*rho*ly^4;
                        end
                    elseif ly < lz % tall rectangle
                        if yz <= 3.5 % slightly long rectangle
                            m22 = 1.36*pi*rho*lz^2;
                            m33 = 1.7*pi*rho*ly^2;
                            m44 = 0.15*pi*rho*lz^4;
                        elseif yz > 3.5 && yz <= 7.5 % long rectangle
                            m22 = 1.21*pi*rho*lz^2;
                            m33 = 1.98*pi*rho*ly^2;
                            m44 = 0.15*pi*rho*lz^4;
                        elseif yz > 7.5 % really long rectanlge
                            m22 = 1.14*pi*rho*lz^2;
                            m33 = 2.23*pi*rho*ly^2;
                            m44 = 0.15*pi*rho*lz^4;
                        end
                    else % square
                        m22 = 1.51*pi*rho*ly^2;
                        m33 = m22;
                        m44 = 0.234*pi*rho*ly^4;
                    end
                case 'diamond'
                    if ly > lz
                        m22 = 0.67*pi*rho*lz^2;
                        m33 = 0.85*pi*rho*ly^2;
                        m44 = 0.059*pi*rho*ly^4;
                    elseif lz > ly
                        m22 = 0.85*pi*rho*lz^2;
                        m33 = 0.67*pi*rho*ly^2;
                        m44 = 0.059*pi*rho*lz^4;
                    else % square diamond
                        m22 = 0.76*pi*rho*ly^2;
                        m33 = m22;
                        m44 = 0.059*pi*rho*ly^4;
                    end                    
                otherwise
                    error('Unknown section shape')
            end
        end
    end % static methods
end %section