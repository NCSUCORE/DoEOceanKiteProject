function [muP,VarP,varargout] = convertWindStatsToPowerStats(X,Y,G,...
    z,muZ,varZ)

% initialize
x = muZ;
y = z;
xV = zeros(2,2);
yV = zeros(2,2);
fV = zeros(2,2);

% calculate distance between grid points and sort
disMat = ((x-X(:)).^2 + (y-Y(:)).^2).^0.5;
[~,I] = sort(disMat);

% locate the 4 points surrounding point of interest
for ii = 1:4
    xV(ii) = X(I(ii));
    yV(ii) = Y(I(ii));
    fV(ii) = G(I(ii));    
end

% surrounding grid co-ordinates
x1 = min(xV(:)); x2 = max(xV(:));
y1 = min(yV(:)); y2 = max(yV(:));

deno        = (x2 - x1)*(y2 - y1);
fTimesYdiff = fV*[y2 - y; y - y1];
yCol        = fTimesYdiff/deno;

% constant term (independent of x)
c1 = [x2 -x1]*yCol;
% term dependent on x
cx = x*[-1 1]*yCol;

% expected value
muP = c1 + cx;

% variance
VarP = varZ*[-1 1]*(yCol.^2);

% other outputs
surroundGrid.xV = xV;
surroundGrid.yV = fV;
surroundGrid.fV = fV;
varargout{1} = surroundGrid;

end