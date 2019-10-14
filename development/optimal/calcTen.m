% load('endbehaviorfixed.mat')
spoolSpeeds=-.4:.05:.4;
n=1000;
mid=ceil(length(spoolSpeeds)/2);
clear Ten
tempTen = [];
Ten=zeros(n);
xopts=linspace(spoolSpeeds(1),spoolSpeeds(end),n);
for ii = 1:length(spoolSpeeds)
    %Create a 2000xN Tension surface where N is the number of spool speeds
    %that were simulated
    tempTen=[tempTen Tens{ii}'];   %#ok<AGROW>
end
%tempTen is 1000x17 1000 path variables and 17 spoolSpeeds
for ii = 1:n
    %Create a 2000xN Tension surface where N is the number of spool speeds
    %that were simulated
    Ten(ii,:)=interp1(spoolSpeeds,tempTen(ii,:),xopts);
end
figure;h=surf(linspace(spoolSpeeds(1),spoolSpeeds(end),1000),0:.001:.999,Ten);
set(h,'LineStyle','none')