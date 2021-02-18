clear
load('D:\Work\newDoEVersion\DoEOceanKiteProject\output\ThrEL_Study_Airborne.mat');
bucketWidth = 50;
buckets = 100:bucketWidth:800;

for ii = 1:size(altitude,1)
    for jj = 1:size(altitude,3)
        newP(jj,:,ii) = Pavg(ii,:,jj);
        newZ(jj,:,ii) = altitude(ii,:,jj);
        newEl(jj,:,ii) = elevation(ii,:,jj);
    end
    for kk = 1:size(altitude,2)
        newTl(:,kk,ii) = thrLength(:);
    end
end

Z = newZ(:,:,1);
EL = newEl(:,:,end);
TL = newTl(:,:,1);
for ii = 1:size(newP,3)
    for jj = 1:numel(buckets)
        bucketSelect = sqrt((Z-buckets(jj)).^2)<=bucketWidth/2;
        pp = newP(:,:,ii);
        pp(~bucketSelect) = NaN;
        [pMax(ii,jj),pIdx] = max(pp,[],'all','linear');
        zVal(ii,jj) = buckets(jj);
        zMax(ii,jj) = Z(pIdx);
        elMax(ii,jj) = EL(pIdx);
        thrMax(ii,jj) = TL(pIdx);
        FL(ii,jj) = flwSpd(ii);
        
    end
end

contourf(FL,zVal,pMax);
xlabel('Flow speed [m/s]');
ylabel('Altitude [m]');
c = colorbar;
c.Label.String      = 'Power [kW]';
c.Label.Interpreter = 'latex';


