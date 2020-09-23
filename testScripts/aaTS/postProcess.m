clc
clear all
close all

addpath('development/slmLin/linSys/')
re = 0
im = 0
unstable = 0
flwSpdArray = [0.25:.25:4];
AoA = [0:2:16];
thrLenArray = [10:5:50];
ilen = length(thrLenArray);
jlen = length(flwSpdArray);
klen = length(AoA)
F = zeros(ilen,jlen,klen);
%imArray = cell(ilen,jlen,klen);
flwMat = repmat(flwSpdArray,12,1);
ii = 1
jj = 0
kk = 0
for k = 1%:klen
for i = 1%:ilen
for j = 1:jlen
    

    thrLen = 10 + 5*(i-1);
    flwSpd = 25 + 25*(j-1);
    pitch = 2*(k-1);
    fName = sprintf('%d_%d_%d',flwSpd,thrLen,pitch);

    load(fName);
    
    [vec,val] = eig(linsys.ss.A(1:12,1:12));
    reArray = real(diag(val));
    imArray = imag(diag(val));
    f = figure('visible','off')
    plot(reArray,imArray,'xk');
    F(i,j,k) = getframe(f);
    renew = min(min(real(val)));
    unstablenew = max(max(real(val)));
    imnew = max(max(imag(val)));
    if imnew > im
        im = imnew;
    end
    if renew > re
        re = renew;
    end
    if unstablenew > unstable
        unstable = unstablenew
        cond = [thrLenArray(i),flwSpdArray(j),AoA(k)]
        caseInd(:,ii) = [thrLenArray(i),flwSpdArray(j),AoA(k)]';
        ii = ii+1
    end
end
% figure
% mesh(reArray,flwMat,imArray)
end
end
figure
movie(F{1,:,1},5,2)


figure
movie(F(:,1,1),5,2)

figure
movie(F(1,1,:),5,2)
load('plots')
