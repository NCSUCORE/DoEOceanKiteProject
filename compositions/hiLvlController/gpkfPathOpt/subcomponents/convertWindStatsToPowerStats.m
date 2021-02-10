function [muP,VarP,varargout] = convertWindStatsToPowerStats(X,Y,G,...
    z,muZ,varZ)

% initialize
x = muZ;
y = z;
xV = zeros(2,2);
yV = zeros(2,2);
fV = zeros(2,2);

% calculate distance between grid points and sort
xDis  = ((x - X(:,1)).^2).^0.5;
yDis  = ((y - Y(1,:)).^2).^0.5;

[~,xSort] = sort(xDis);
[~,ySort] = sort(yDis);

% locate the 4 points surrounding point of interest
for ii = 1:2
    for jj = 1:2
    xV(ii,jj) = X(xSort(ii),1);
    yV(ii,jj) = Y(1,ySort(jj));
    fV(ii,jj) = G(xSort(ii),ySort(jj));   
    end
end

% surrounding grid co-ordinates
x1 = X(xSort(1),1); x2 = X(xSort(2),1);
y1 = Y(1,ySort(1)); y2 = Y(1,ySort(2));

deno        = (x2 - x1)*(y2 - y1);
fTimesYdiff = fV*[y2 - y; y - y1];
yCol        = fTimesYdiff/deno;

% constant term (independent of x)
c1 = [x2 -x1]*yCol;
% slope
c2 = [-1 1]*yCol;

% expected value
muP = c1 + c2*x;

% variance
VarP = varZ*c2^2;

% other outputs
surroundGrid.xV = xV;
surroundGrid.yV = yV;
surroundGrid.fV = fV;
varargout{1} = surroundGrid;

end