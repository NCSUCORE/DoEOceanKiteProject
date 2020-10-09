clc
clear all
close all

%addpath('C:\Users\andre\Documents\Data\linSys\Manta_AR8_B8\')
load('linDyn')
flwSpdArray = 2%[0.25:.25:2];
AoA = [0:1:10];
thrLenArray = 20%[20:5:50];
ilen = length(thrLenArray);
jlen = length(flwSpdArray);
klen = length(AoA);

%Calculate time delay due to pade approximation
delay = 6.75./flwSpdArray;

%% Loop over Flow Speed
% for i = 1:ilen
% for k = 1:klen
%     moviename = sprintf('%d_m%d_degLatWide',thrLenArray(i),AoA(k));
%     moviename2 = sprintf('%d_m%d_degLat',thrLenArray(i),AoA(k));
%     f1 = figure%('visible','off');    
%     x1 = 0;
%     x2 = 0;
%     y1 = 0;
%     for j = 1:jlen
%         x1t = floor(min(real(pole(linDyn.Lat{i,j,k}))));
%         x2t = ceil(max(real(pole(linDyn.Lat{i,j,k}))));
%         y1t = floor(min(imag(pole(linDyn.Lat{i,j,k}))));
%         if x1t < x1
%             x1 = x1t;
%         end
%         if x2t > x2
%             x2 = x2t;
%         end
%         if y1t < y1
%             y1 = y1t;
%         end
% %         x1t = floor(min(real(zero(linDyn.Long{i,j,k}))));
% %         x2t = ceil(max(real(zero(linDyn.Long{i,j,k}))));
% %         y1t = floor(min(imag(zero(linDyn.Long{i,j,k}))));
% %         if x1t < x1
% %             x1 = x1t;
% %         end
% %         if x2t > x2
% %             x2 = x2t;
% %         end
% %         if y1t < y1
% %             y1 = y1t;
% %         end
%     end
%     for j = 1:jlen
%         pzmap(linDyn.Lat{i,j,k},'b')
%         hold on
%         [num,den]=pade(delay(j),1);
%         plot(num(2),0,'ro')
%         plot(-den(2),0,'rx')
%         hold off
%         title({'Lateral Dynamics Pole Map w/ Pade Delay Approximation',...
%             sprintf('Tether Length = %d m, AoA = %d degrees, Flow Speed = %.2f m/s'...
%             ,thrLenArray(i),AoA(k),flwSpdArray(j))})
%         xlim([x1 2])
%         ylim([y1 -y1])        
% %         xlim([-.25 0.25])
% %         ylim([y1 -y1])
%         f = getframe(f1);
%         im = frame2im(f);
%         [imind,cm]  = rgb2ind(im,256);
%         if j == 1
%             imwrite(imind,cm,moviename,'gif', 'Loopcount',inf,'DelayTime',1/3);
%         else
%             imwrite(imind,cm,moviename,'gif','WriteMode','append','DelayTime',1/3)
%         end
%         xlim([-.1 0.1])
%         ylim([y1 -y1])
%         f = getframe(f1);
%         im = frame2im(f);
%         [imind,cm]  = rgb2ind(im,256);
%         if j == 1
%             imwrite(imind,cm,moviename2,'gif', 'Loopcount',inf,'DelayTime',1/3);
%         else
%             imwrite(imind,cm,moviename2,'gif','WriteMode','append','DelayTime',1/3)
%         end
%     end
% close all
%     
%     for j = 1:jlen
%         x1t = floor(min(real(pole(linDyn.Long{i,j,k}))));
%         x2t = ceil(max(real(pole(linDyn.Long{i,j,k}))));
%         y1t = floor(min(imag(pole(linDyn.Long{i,j,k}))));
%         if x1t < x1
%             x1 = x1t;
%         end
%         if x2t > x2
%             x2 = x2t;
%         end
%         if y1t < y1
%             y1 = y1t;
%         end
%     end
%  % Make movie of longitudinal dynamics   
%         moviename = sprintf('%d_m%d_degLongwide',thrLenArray(i),AoA(k));
%         moviename2 = sprintf('%d_m%d_degLong',thrLenArray(i),AoA(k));
%         f1 = figure
%     for j = 1:jlen
%         pzmap(linDyn.Long{i,j,k},'b')
%         hold on
%         [num,den]=pade(delay(j),1);
%         plot(num(2),0,'ro')
%         plot(-den(2),0,'rx')
%         hold off
%         title({'Longitudinal Dynamics Pole Map w/ Pade Delay Approximation',...
%             sprintf('Tether Length = %d m, AoA = %d degrees, Flow Speed = %.2f m/s'...
%             ,thrLenArray(i),AoA(k),flwSpdArray(j))})
%         hold off
%         xlim([x1 2])
%         ylim([y1 -y1])
% %         xlim([-.25 0.25])
% %         ylim([y1 -y1])
%         f = getframe(f1);
%         im = frame2im(f);
%         [imind,cm]  = rgb2ind(im,256);
%         if j == 1
%             imwrite(imind,cm,moviename,'gif', 'Loopcount',inf,'DelayTime',1/3);
%         else
%             imwrite(imind,cm,moviename,'gif','WriteMode','append','DelayTime',1/3)
%         end
% 
%         xlim([-.1 0.1])
%         ylim([y1 -y1])
%         f = getframe(f1);
%         im = frame2im(f);
%         [imind,cm]  = rgb2ind(im,256);
%         if j == 1
%             imwrite(imind,cm,moviename2,'gif', 'Loopcount',inf,'DelayTime',1/3);
%         else
%             imwrite(imind,cm,moviename2,'gif','WriteMode','append','DelayTime',1/3)
%         end
%     end
%     close all
% end
% end

%% Loop over Tether Length
% for j = 1:jlen
% for k = 1:klen
%     moviename = sprintf('%dms_%ddeg_Lat',flwSpdArray(j)*100,AoA(k));
%     [num,den]=pade(delay(j),1);
%     f1 = figure%('visible','off');    
%     x1 = 0;
%     x2 = den(2);
%     y1 = 0;
%     
%     for i = 1%:ilen
%         x1t = floor(min(real(pole(linDyn.Lat{i,j,k}))));
%         x2t = ceil(max(real(pole(linDyn.Lat{i,j,k}))));
%         y1t = floor(min(imag(pole(linDyn.Lat{i,j,k}))));
%         if x1t < x1
%             x1 = x1t;
%         end
%         if x2t > x2
%             x2 = x2t;
%         end
%         if y1t < y1
%             y1 = y1t;
%         end
% %         x1t = floor(min(real(zero(linDyn.Long{i,j,k}))));
% %         x2t = ceil(max(real(zero(linDyn.Long{i,j,k}))));
% %         y1t = floor(min(imag(zero(linDyn.Long{i,j,k}))));
% %         if x1t < x1
% %             x1 = x1t;
% %         end
% %         if x2t > x2
% %             x2 = x2t;
% %         end
% %         if y1t < y1
% %             y1 = y1t;
% %         end
%     end
%     for i = 1:ilen
%         pzmap(linDyn.Lat{i,j,k},'b')
%         hold on
%         [num,den]=pade(delay(j),1);
%         plot(num(2),0,'ro')
%         plot(-den(2),0,'rx')
%         hold off
%         xlim([x1 1])
%         ylim([y1 -y1])
%         title({'Lateral Dynamics Pole Map w/ Pade Delay Approximation',...
%             sprintf('Tether Length = %d m, AoA = %d degrees, Flow Speed = %.2f m/s'...
%             ,thrLenArray(i),AoA(k),flwSpdArray(j))})
%         f = getframe(f1);
%         im = frame2im(f);
%         [imind,cm]  = rgb2ind(im,256);
%         if i == 1
%             imwrite(imind,cm,moviename,'gif', 'Loopcount',inf,'DelayTime',1/3);
%         else
%             imwrite(imind,cm,moviename,'gif','WriteMode','append','DelayTime',1/3)
%         end
%     end
% close all
%     x1 = 0;
%     x2 = den(2);
%     y1 = 0;
%     for i = 1:ilen
%         x1t = floor(min(real(pole(linDyn.Long{i,j,k}))));
%         x2t = ceil(max(real(pole(linDyn.Long{i,j,k}))));
%         y1t = floor(min(imag(pole(linDyn.Long{i,j,k}))));
%         if x1t < x1
%             x1 = x1t;
%         end
%         if x2t > x2
%             x2 = x2t;
%         end
%         if y1t < y1
%             y1 = y1t;
%         end
%     end
%  % Make movie of longitudinal dynamics   
%         moviename = sprintf('%dms_%ddeg_Long',flwSpdArray(j)*100,AoA(k));
%         f1 = figure
%     for i = 1:ilen
%         pzmap(linDyn.Long{i,j,k},'b')
%         hold on
% 
%         plot(num(2),0,'ro')
%         plot(-den(2),0,'rx')
%         hold off
%         title({'Longitudinal Dynamics Pole Map w/ Pade Delay Approximation',...
%             sprintf('Tether Length = %d m, AoA = %d degrees, Flow Speed = %.2f m/s'...
%             ,thrLenArray(i),AoA(k),flwSpdArray(j))})
%         hold off
%         xlim([x1 1])
%         ylim([y1 -y1])
%         f = getframe(f1);
%         im = frame2im(f);
%         [imind,cm]  = rgb2ind(im,256);
%         if i == 1
%             imwrite(imind,cm,moviename,'gif', 'Loopcount',inf,'DelayTime',1/3);
%         else
%             imwrite(imind,cm,moviename,'gif','WriteMode','append','DelayTime',1/3)
%         end
%     end
%     close all
% end
% end
% 
% %% Loop over Pitch Angle
for j = 1:jlen
for i = 1:ilen
    moviename = sprintf('%dm_%dms_Lat',thrLenArray(i),flwSpdArray(j)*100);
    f1 = figure%('visible','off');    
    x1 = 0;
    x2 = 0;
    y1 = 0;
    for k = 1:klen
        x1t = floor(min(real(pole(linDyn.Lat{i,j,k}))));
        x2t = ceil(max(real(pole(linDyn.Lat{i,j,k}))));
        y1t = floor(min(imag(pole(linDyn.Lat{i,j,k}))));
        if x1t < x1
            x1 = x1t;
        end
        if x2t > x2
            x2 = x2t;
        end
        if y1t < y1
            y1 = y1t;
        end
%         x1t = floor(min(real(zero(linDyn.Long{i,j,k}))));
%         x2t = ceil(max(real(zero(linDyn.Long{i,j,k}))));
%         y1t = floor(min(imag(zero(linDyn.Long{i,j,k}))));
%         if x1t < x1
%             x1 = x1t;
%         end
%         if x2t > x2
%             x2 = x2t;
%         end
%         if y1t < y1
%             y1 = y1t;
%         end
    end
    for k = 1:klen
        pzmap(linDyn.Lat{i,j,k},'b')
        hold on
        [num,den]=pade(delay(j),1);
        plot(num(2),0,'ro')
        plot(-den(2),0,'rx')
        hold off
        title({'Lateral Dynamics Pole Map w/ Pade Delay Approximation',...
            sprintf('Tether Length = %d m, AoA = %d degrees, Flow Speed = %.2f m/s'...
            ,thrLenArray(i),AoA(k),flwSpdArray(j))})
        xlim([x1 2])
        ylim([y1 -y1])
        f = getframe(f1);
        im = frame2im(f);
        [imind,cm]  = rgb2ind(im,256);
        if k == 1
            imwrite(imind,cm,moviename,'gif', 'Loopcount',inf,'DelayTime',1/3);
        else
            imwrite(imind,cm,moviename,'gif','WriteMode','append','DelayTime',1/3)
        end
    end
close all
    
    for k = 1:klen
        x1t = floor(min(real(pole(linDyn.Long{i,j,k}))));
        x2t = ceil(max(real(pole(linDyn.Long{i,j,k}))));
        y1t = floor(min(imag(pole(linDyn.Long{i,j,k}))));
        if x1t < x1
            x1 = x1t;
        end
        if x2t > x2
            x2 = x2t;
        end
        if y1t < y1
            y1 = y1t;
        end
    end
 % Make movie of longitudinal dynamics   
        moviename = sprintf('%dm_%dms_Long',thrLenArray(i),flwSpdArray(j)*100);
        f1 = figure
    for k = 1:klen
        pzmap(linDyn.Long{i,j,k},'b')
        hold on
        [num,den]=pade(delay(j),1);
        plot(num(2),0,'ro')
        plot(-den(2),0,'rx')
        hold off
        title({'Longitudinal Dynamics Pole Map w/ Pade Delay Approximation',...
            sprintf('Tether Length = %d m, AoA = %d degrees, Flow Speed = %.2f m/s'...
            ,thrLenArray(i),AoA(k),flwSpdArray(j))})
        hold off
        xlim([x1 2])
        ylim([y1 -y1])
        f = getframe(f1);
        im = frame2im(f);
        [imind,cm]  = rgb2ind(im,256);
        if k == 1
            imwrite(imind,cm,moviename,'gif', 'Loopcount',inf,'DelayTime',1/3);
        else
            imwrite(imind,cm,moviename,'gif','WriteMode','append','DelayTime',1/3)
        end
    end
    close all
end
end