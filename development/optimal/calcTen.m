spoolSpeeds=-.8:.1:.8;
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

figure;
h=surf(linspace(spoolSpeeds(1),spoolSpeeds(end),1000),0:.001:.999,Ten);
set(h,'LineStyle','none')
%%
% plb=min(min(Ten));
% pub=max(max(Ten));
% pvals=linspace(plb,pub,5);
% speeds=zeros(length(pvals),1000);
% for i=1:length(pvals)
%     tic
%     speeds(i,:)=calcSpeeds(Ten,pvals(i),[spoolSpeeds(1) spoolSpeeds(end)]);
%     toc
% end
% 
% figure;
% for i=1:length(pvals)
% plot(speeds(i,:))
% hold on
% end

% function speeds = calcSpeeds(Ten, p, speedRange)
%     xopts=linspace(speedRange(1),speedRange(2),max(size(Ten)));
%     n=1000;
%     % speeds = zeros(2*max(size(Ten)),1);
%     speeds = zeros(n,1);
%     % for ii = 1:2*max(size(Ten))
%     for ii = 1:n
%         iidbl=(1000/n)*ii;
%         %     hamil = @(x) (p-Ten(ii,xopts==x)).*x;
%         perc=iidbl-floor(iidbl);
%         currTen=((1-perc)*Ten(max(floor(iidbl),1),:)) + (perc*Ten(ceil(iidbl),:));
%         hamil = @(x) (p-interp1(xopts,currTen,x)).*x;
%         [~,bestind]=min(hamil(xopts));
%         bestx=xopts(bestind);
% 
%         step=xopts(2)-xopts(1);
%         lbnd = max(xopts(1),bestx-step);
%         rbnd = min(xopts(end),bestx+step);
%         tau = 1-.38197;
%         for i=1:5
%             x1=((1-tau)*rbnd)+(tau*lbnd);
%             x2=((1-tau)*lbnd)+(tau*rbnd);
%             f1=hamil(x1);
%             f2=hamil(x2);
%             if f1>=f2
%                 lbnd=x1;
%             else
%                 rbnd=x2;
%             end
%         end
%         bestx=(lbnd+rbnd)/2;
%         speeds(ii)=bestx;
%     end
%     disp(i)
% end
