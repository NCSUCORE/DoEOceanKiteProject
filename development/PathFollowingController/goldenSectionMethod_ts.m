lambda_g = @(s)((aB.*sin(s))./(1 + ((aB/bB)^2).*(cos(s).^2))); %path longitude
phi_g  = @(s)((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2))); %path latitude


     
     
     
       positionW = [1,1,1];
     aB = 2;
     bB = 1;
                % path = [(cos(((aB.*sin(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))).*cos(((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))));
                 %       (sin(((aB.*sin(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))).*cos(((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))));
                  %      (sin(((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))));]; 
     
   
    
     
    
     centralAngle = @(s)(2.*asin(.5*(norm( [(cos(((aB.*sin(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))).*cos(((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))));
                        (sin(((aB.*sin(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))).*cos(((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))));
                        (sin(((((aB/bB)^2).*sin(s).*cos(s))./(1 + ((aB/bB)^2).*(cos(s).^2)))));]-positionW))));