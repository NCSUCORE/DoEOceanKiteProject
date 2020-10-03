clc
clear all
close all

addpath('C:\Users\andre\Documents\Data\linSys')
flwSpdArray = [0.25:.25:4];
AoA = [0:2:16];
thrLenArray = [10:5:50];
ilen = length(thrLenArray);
jlen = length(flwSpdArray);
klen = length(AoA);
%Initialize Arrays
vecLat = cell(ilen,jlen,klen);
vecLong = cell(ilen,jlen,klen);
valLat = cell(ilen,jlen,klen);
valLong = cell(ilen,jlen,klen);
pLat = cell(ilen,jlen,klen);
zLat = cell(ilen,jlen,klen);
pLong = cell(ilen,jlen,klen);
zLong = cell(ilen,jlen,klen);
re = 0; re2 = 0; im = 0; im2 = 0; unstable = 0; unstable2 = 0; 
ii = 1; jj = 1; %comp = zeros(ilen,jlen,klen);
%F = zeros(ilen,jlen,klen);
flwMat = repmat(flwSpdArray,12,1);
filt = [ones(7,7) zeros(7,6);zeros(6,7) ones(6,6)];
for k = 1%:klen
    k
for i = 1%:ilen
    i
for j = 1%:jlen
    %Load the proper data
    thrLen = 10 + 5*(i-1);
    flwSpd = 25 + 25*(j-1);
    pitch = 2*(k-1);
    fName = sprintf('%d_%d_%d',flwSpd,thrLen,pitch);
    load(fName);
    %Import the results and re-order the states to match traditional flight
    %dynamics analysis [u w q theta x z thether v p r phi y psi]
    stateOrder = [7 9 11 5 1 3 13 8 10 12 4 2 6]; 
    A = linsys.ss.A(1:13,1:13);
    B = linsys.ss.B(stateOrder,:);
    C = linsys.ss.C(:,stateOrder);
    Atemp = A(:,stateOrder);
    Anew = Atemp(stateOrder,:).*filt;
    Along = Anew(1:7,1:7);
    Alat = Anew(8:13,8:13);
    Blong = B(1:7,:);
    Blat = B(8:13,:);
    comp = max(abs(real(sort(eig(A))-sort(eig(Anew)))))./max(abs(real(sort(eig(A)))));
    Clong = C(:,1:7);
    Clat = C(:,8:13);
    [vecLat{i,j,k},valLat{i,j,k}] = eig(Alat);
    [veclong{i,j,k},vallong{i,j,k}] = eig(Along);
    longSys = ss(Along,Blong,Clong,0);
    latSys = ss(Alat,Blat,Clat,0);
    linDyn.Lat{i,j,k} = latSys;
    linDyn.Long{i,j,k} = longSys;
    linDyn.comp{i,j,k} = comp;
%%    f = figure('visible','off')
%     plot(reArray,imArray,'xk');
%     F(i,j,k) = getframe(f);
%     renewLong = min(min(real(vallong)));
%     unstablenewLong = max(max(real(vallong)));
%     imnewLong = max(max(imag(vallong)));
%     if imnewLong > im
%         im = imnewLong;
%     end
%     if renewLong > re
%         re = renewLong;
%     end
%     if unstablenewLong > unstable
%         unstable = unstablenewLong;
%         cond = [thrLenArray(i),flwSpdArray(j),AoA(k)];
%         caseInd(:,ii) = [thrLenArray(i),flwSpdArray(j),AoA(k),unstable]';
%         ii = ii+1;
%     end
%     
%     renewLat = min(min(real(vallat)));
%     unstablenewLat = max(max(real(vallat)));
%     imnewLat = max(max(imag(vallat)));
%     if imnewLat > im2
%         im2 = imnewLat;
%     end
%     if renewLat > re2
%         re2 = renewLat;
%     end
%     if unstablenewLat > unstable2
%         unstable2 = unstablenewLat;
%         cond = [thrLenArray(i),flwSpdArray(j),AoA(k)];
%         caseInd2(:,jj) = [thrLenArray(i),flwSpdArray(j),AoA(k),unstable2]';
%         jj = jj+1;
%     end
    clear(fName)
end
end
end

