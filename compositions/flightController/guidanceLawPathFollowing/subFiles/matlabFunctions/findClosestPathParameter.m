function sClosest = findClosestPathParameter(initPathParam,kitePos,...
    pathWidth,pathHeight,pathElevation)
%FINDCLOSESTPATHPARAMETER(initPathParam,pathWidth,pathHeight,pathElevation,kitePos)
% 
% Find the closest path parameter using Newton's minimization method
% Theoretically, this function should find the answer in one iteration
% because the cost function is quadratic, but I haven't verified that yet,
% therefore I haven't deleted the 'for' loop.
% Inputs:   initPathParam - Initial guess for minimization, preferable the
%           closest path parameter value at the previous time step
%           pathWidth - Path width [deg]
%           pathHeight - Path height [deg]
%           pathElevation - Path elevation [deg]
%           kitePos - Normalized kite position [m]
%
% Output:   sClosest - Closest path parameter
%           Note: Don't worry if the value is greater than 2*pi, it'll 
%           wrap around the path center
%
% Thoery: Minize dot product of kite position and path coordinates with
% respect to path parameter.  
% We know that a.b = |a|*|b|*cos(angle between a and b)
% If a and b have unit magnitudes, a.b is simply equal to the cos of the
% angle between them

%% dummy variables with shorter names
w   = pathWidth*pi/180;
h   = pathHeight*pi/180;
e   = pathElevation*pi/180;
s0  = initPathParam;

%% path shape parameters a and b
a = 0.5*w;
b = (1/(2*sqrt(2)))*sqrt(-w^2+sqrt((h^2*(4+h^2)*w^4))/(h^2));

%% make sure the kite position is normalized
kitePos_n = kitePos./norm(kitePos);
ux = kitePos_n(1); uy = kitePos_n(2); uz = kitePos_n(3); 

%% first and second derivatives of kitePos DOT pathPos
eq_dbyds_ukDOTup = @(E_path,a,b,s,ux,uy,uz)-a.^2.*uz.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^2.*((a.^2.*cos(s.*2.0))./2.0+b.^2.*cos(s.*2.0)+a.^2./2.0)+a.^2.*ux.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^2.*((a.^2.*cos(s.*2.0))./2.0+b.^2.*cos(s.*2.0)+a.^2./2.0)-a.^2.*uy.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^2.*((a.^2.*cos(s.*2.0))./2.0+b.^2.*cos(s.*2.0)+a.^2./2.0)-a.*b.^2.*uy.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*cos(s).*1.0./(a.^2.*cos(s).^2+b.^2).^2.*(a.^2.*sin(s).^2+a.^2+b.^2)-a.*b.^2.*ux.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*cos(s).*1.0./(a.^2.*cos(s).^2+b.^2).^2.*(a.^2.*sin(s).^2+a.^2+b.^2);
eq_d2byds2_ukDOTup = @(E_path,a,b,s,ux,uy,uz)a.^4.*uz.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^4.*(a.^2.*cos(s.*2.0)+b.^2.*cos(s.*2.0).*2.0+a.^2).^2.*(-1.0./4.0)-(a.^2.*uz.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^3.*(a.^4.*sin(s.*2.0).*2.0+a.^4.*sin(s.*4.0)-b.^4.*sin(s.*2.0).*8.0-a.^2.*b.^2.*sin(s.*2.0).*8.0+a.^2.*b.^2.*sin(s.*4.0).*2.0))./4.0+(a.^2.*ux.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^3.*(a.^4.*sin(s.*2.0).*2.0+a.^4.*sin(s.*4.0)-b.^4.*sin(s.*2.0).*8.0-a.^2.*b.^2.*sin(s.*2.0).*8.0+a.^2.*b.^2.*sin(s.*4.0).*2.0))./4.0-(a.^2.*uy.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^3.*(a.^4.*sin(s.*2.0).*2.0+a.^4.*sin(s.*4.0)-b.^4.*sin(s.*2.0).*8.0-a.^2.*b.^2.*sin(s.*2.0).*8.0+a.^2.*b.^2.*sin(s.*4.0).*2.0))./4.0-(a.^4.*ux.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^4.*(a.^2.*cos(s.*2.0)+b.^2.*cos(s.*2.0).*2.0+a.^2).^2)./4.0+(a.^4.*uy.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^4.*(a.^2.*cos(s.*2.0)+b.^2.*cos(s.*2.0).*2.0+a.^2).^2)./4.0-a.^2.*b.^4.*ux.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*cos(s).^2.*1.0./(a.^2.*cos(s).^2+b.^2).^4.*(a.^2.*sin(s).^2+a.^2+b.^2).^2+a.^2.*b.^4.*uy.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*cos(s).^2.*1.0./(a.^2.*cos(s).^2+b.^2).^4.*(a.^2.*sin(s).^2+a.^2+b.^2).^2+a.*b.^2.*uy.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*sin(s).*1.0./(a.^2.*cos(s).^2+b.^2).^3.*(a.^4.*sin(s).^2.*4.0+a.^4.*sin(s).^4-a.^4.*5.0+b.^4-a.^2.*b.^2.*4.0+a.^2.*b.^2.*sin(s).^2.*6.0)+a.*b.^2.*ux.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*sin(s).*1.0./(a.^2.*cos(s).^2+b.^2).^3.*(a.^4.*sin(s).^2.*4.0+a.^4.*sin(s).^4-a.^4.*5.0+b.^4-a.^2.*b.^2.*4.0+a.^2.*b.^2.*sin(s).^2.*6.0)-a.^3.*b.^2.*uy.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*cos(s).*1.0./(a.^2.*cos(s).^2+b.^2).^4.*((a.^2.*cos(s.*2.0))./2.0+b.^2.*cos(s.*2.0)+a.^2./2.0).*(a.^2.*sin(s).^2+a.^2+b.^2).*2.0-a.^3.*b.^2.*ux.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*cos(s).*1.0./(a.^2.*cos(s).^2+b.^2).^4.*((a.^2.*cos(s.*2.0))./2.0+b.^2.*cos(s.*2.0)+a.^2./2.0).*(a.^2.*sin(s).^2+a.^2+b.^2).*2.0;

%% iterate
sPrev = s0;
maxCount = 100;
for counter = 1:maxCount
    % evaluate first derivative
    NewtFirstDir = eq_dbyds_ukDOTup(e,a,b,sPrev,ux,uy,uz);
    % evaluate second derivative
    NewtSecondDir = eq_d2byds2_ukDOTup(e,a,b,sPrev,ux,uy,uz);
    % next path parameter
    sClosest = sPrev - NewtFirstDir/NewtSecondDir;
    % break out of for loop if difference is low
    if (sClosest-sPrev)/(2*pi) < 1e-3
        break;
    end
    % update sPrve
    sPrev = sClosest;
end

% ensure that the next path parameter is not behind the intial one
sClosest = max(s0,sClosest);

% test if these 2 lines of code can eliminate all of the above
eq_newtFunc = @(E_path,a,b,s,ux,uy,uz)s-(a.^2.*uz.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^2.*((a.^2.*cos(s.*2.0))./2.0+b.^2.*cos(s.*2.0)+a.^2./2.0)-a.^2.*ux.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^2.*((a.^2.*cos(s.*2.0))./2.0+b.^2.*cos(s.*2.0)+a.^2./2.0)+a.^2.*uy.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^2.*((a.^2.*cos(s.*2.0))./2.0+b.^2.*cos(s.*2.0)+a.^2./2.0)+a.*b.^2.*uy.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*cos(s).*1.0./(a.^2.*cos(s).^2+b.^2).^2.*(a.^2.*sin(s).^2+a.^2+b.^2)+a.*b.^2.*ux.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*cos(s).*1.0./(a.^2.*cos(s).^2+b.^2).^2.*(a.^2.*sin(s).^2+a.^2+b.^2))./((a.^4.*uz.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^4.*(a.^2.*cos(s.*2.0)+b.^2.*cos(s.*2.0).*2.0+a.^2).^2)./4.0+(a.^2.*uz.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^3.*(a.^4.*sin(s.*2.0).*2.0+a.^4.*sin(s.*4.0)-b.^4.*sin(s.*2.0).*8.0-a.^2.*b.^2.*sin(s.*2.0).*8.0+a.^2.*b.^2.*sin(s.*4.0).*2.0))./4.0-(a.^2.*ux.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^3.*(a.^4.*sin(s.*2.0).*2.0+a.^4.*sin(s.*4.0)-b.^4.*sin(s.*2.0).*8.0-a.^2.*b.^2.*sin(s.*2.0).*8.0+a.^2.*b.^2.*sin(s.*4.0).*2.0))./4.0+(a.^2.*uy.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^3.*(a.^4.*sin(s.*2.0).*2.0+a.^4.*sin(s.*4.0)-b.^4.*sin(s.*2.0).*8.0-a.^2.*b.^2.*sin(s.*2.0).*8.0+a.^2.*b.^2.*sin(s.*4.0).*2.0))./4.0+(a.^4.*ux.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^4.*(a.^2.*cos(s.*2.0)+b.^2.*cos(s.*2.0).*2.0+a.^2).^2)./4.0-(a.^4.*uy.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*1.0./(a.^2.*cos(s).^2+b.^2).^4.*(a.^2.*cos(s.*2.0)+b.^2.*cos(s.*2.0).*2.0+a.^2).^2)./4.0+a.^2.*b.^4.*ux.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*cos(s).^2.*1.0./(a.^2.*cos(s).^2+b.^2).^4.*(a.^2.*sin(s).^2+a.^2+b.^2).^2-a.^2.*b.^4.*uy.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*cos(s).^2.*1.0./(a.^2.*cos(s).^2+b.^2).^4.*(a.^2.*sin(s).^2+a.^2+b.^2).^2-a.*b.^2.*uy.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*sin(s).*1.0./(a.^2.*cos(s).^2+b.^2).^3.*(a.^4.*sin(s).^2.*4.0+a.^4.*sin(s).^4-a.^4.*5.0+b.^4-a.^2.*b.^2.*4.0+a.^2.*b.^2.*sin(s).^2.*6.0)-a.*b.^2.*ux.*cos((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*sin(s).*1.0./(a.^2.*cos(s).^2+b.^2).^3.*(a.^4.*sin(s).^2.*4.0+a.^4.*sin(s).^4-a.^4.*5.0+b.^4-a.^2.*b.^2.*4.0+a.^2.*b.^2.*sin(s).^2.*6.0)+a.^3.*b.^2.*uy.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*cos((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*cos(s).*1.0./(a.^2.*cos(s).^2+b.^2).^4.*((a.^2.*cos(s.*2.0))./2.0+b.^2.*cos(s.*2.0)+a.^2./2.0).*(a.^2.*sin(s).^2+a.^2+b.^2).*2.0+a.^3.*b.^2.*ux.*sin((a.^2.*sin(s.*2.0).*(-1.0./2.0)+E_path.*b.^2+E_path.*a.^2.*cos(s).^2)./(a.^2.*cos(s).^2+b.^2)).*sin((a.*b.^2.*sin(s))./(a.^2.*cos(s).^2+b.^2)).*cos(s).*1.0./(a.^2.*cos(s).^2+b.^2).^4.*((a.^2.*cos(s.*2.0))./2.0+b.^2.*cos(s.*2.0)+a.^2./2.0).*(a.^2.*sin(s).^2+a.^2+b.^2).*2.0);
sTest = max(eq_newtFunc(e,a,b,sPrev,ux,uy,uz),s0);


end

