clc
clear all
close all
x = [0.01:.01:1.99];


% [x,y] = meshgrid(x1,y1);
% z = 1+y.^2.*x.^2+2.*x.*y.*(1+3.*y+2.*y.^2);
%
% figure
% contourf(x,y,z)
% colorbar

for i = 1:numel(x)
    f = @(y)(myFun3(x(i),y));
    g = @(y)(myFun2(x(i),y));
%     factor(i) = fmincon(f,0,[],[],[],[],0,[]);
    [gMax(i),factor(i)] = fmincon(g,-.2,[],[],[],[],0,[]); 
end
% x = 2;0:.1:2;
% figure
% hold on
% y = 0:.1:1
% for i = 1:numel(x)
% %     myFun(x(i),0:1:1000)
%     output = myFun(x(i),y);
%     min(output)
%     plot(y,output)
% end
% figure
% plot(x,yMax)
% xlabel('$k_L L$')
% set(gca,'FontSize',14)
% ylabel('$\frac{1}{L}\frac{G_{max}}{p_{max}}$','FontSize',18)
% grid on

% plot(x,)
% figure
% loglog(x,yMax)
% xlabel('$k_L L$')
% set(gca,'FontSize',14)
% ylabel('$\frac{1}{L}\frac{G_{max}}{p_{max}}$','FontSize',18)
% grid on
% 
%%
fpath = 'C:\Users\adabney\iCloudDrive\NCSU HW Uploads\estimationPaper\figs\';
figure('Position',[100 100 600 300])
plot(x,1./(2-x),'k--','LineWidth',1.5)
hold on
plot(x,factor,'k','LineWidth',1.5)
plot(x,myFun2(x,1),'k:','LineWidth',1.5)
plot(x,myFun2(x,2),'k-.','LineWidth',1.5)
plot(x,myFun2(x,5),'k','LineWidth',.5)
hold on
% plot(x,gMax)
xlabel('$k_L L$')
ylabel('Factor on $Lp_{max}$')
set(gca,'FontSize',14)
legend('Noise Free','Optimal Noise Profile','$G_{max} = p_{max} L$','$G_{max} = 2p_{max} L$','$G_{max} = 5p_{max} L$','Location','northwest')
ylim([0 10])
grid on
saveas(gcf,[fpath 'bound'],'fig')
saveas(gcf,[fpath 'bound'],'epsc')

figure('Position',[100 100 600 300])
% plot(x,factor)
hold on
plot(x,gMax,'k','LineWidth',1.5)
xlabel('$k_L L$')
set(gca,'FontSize',14)
ylabel('$\frac{1}{L}\frac{G_{max}}{p_{max}}$','FontSize',18)
grid on
saveas(gcf,[fpath 'reqNoise'],'fig')
saveas(gcf,[fpath 'reqNoise'],'epsc')



function [out] = myFun(x,y)
    out = 1+x.^2.*y.^2+2.*x.*y*(1+3.*x-2.*x.^2);
end

function [out] = myFun2(x,y)
    out = (-1+x+x.*y-x.^2.*y+sqrt(1+x.^2.*y.^2+2.*x.*y.*(1+3.*x-2.*x.^2)))./((2-x).*x);
end
function [out] = myFun3(x,y)
    out = (-1+x+x.*y-x.^2.*y-sqrt(1+x.^2.*y.^2+2.*x.*y*(1+3.*x-2.*x.^2)))./((2-x).*x);
end
