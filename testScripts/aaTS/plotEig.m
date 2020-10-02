clc
clear all
close all

addpath('C:\Users\andre\Documents\Data\linSys')
load('linDyn')
flwSpdArray = [0.25:.25:4];
AoA = [0:2:16];
thrLenArray = [10:5:50];
ilen = length(thrLenArray);
jlen = length(flwSpdArray);
klen = length(AoA);

%Calculate time delay due to pade approximation
delay = 6.47./flwSpdArray;

%% Loop over Flow Speed
for i = 3
for k = 1
    moviename = sprintf('%d_%d_Lat',5+i*5,k*2-2);
    f1 = figure%('visible','off');    
    x1 = 0;
    x2 = 0;
    y1 = 0;
    for j = 1:jlen
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
    for j = 1:jlen
        pzmap(linDyn.Lat{i,j,k},'b')
        hold on
        [num,den]=pade(delay(j),1);
        plot(num(2),0,'ro')
        plot(-den(2),0,'rx')
        hold off
        title('Lateral Dynamics Pole Map w/ Pade Delay Approximation')
        xlim([x1 2])
        ylim([y1 -y1])
        f = getframe(f1);
        im = frame2im(f);
        [imind,cm]  = rgb2ind(im,256);
        if j == 1
            imwrite(imind,cm,moviename,'gif', 'Loopcount',inf,'DelayTime',1/3);
        else
            imwrite(imind,cm,moviename,'gif','WriteMode','append','DelayTime',1/3)
        end
    end

    
    for j = 1:jlen
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
        moviename = sprintf('%d_%d_Long',5+i*5,k*2-2);
        f1 = figure
    for j = 1:jlen
        pzmap(linDyn.Long{i,j,k},'b')
        hold on
        [num,den]=pade(delay(j),1);
        plot(num(2),0,'ro')
        plot(-den(2),0,'rx')
        hold off
        title('Longitudinal Dynamics Pole Map w/ Pade Delay Approximation')
        hold off
        xlim([x1 2])
        ylim([y1 -y1])
        f = getframe(f1);
        im = frame2im(f);
        [imind,cm]  = rgb2ind(im,256);
        if j == 1
            imwrite(imind,cm,moviename,'gif', 'Loopcount',inf,'DelayTime',1/3);
        else
            imwrite(imind,cm,moviename,'gif','WriteMode','append','DelayTime',1/3)
        end
    end
end
end

%% Loop over Tether Length
for j = 1:16
for k = 1
    moviename = sprintf('%dms_%ddeg_Lat',25*j,k*2-2);
    [num,den]=pade(delay(j),1);
    f1 = figure%('visible','off');    
    x1 = 0;
    x2 = den(2);
    y1 = 0;
    
    for i = 1:ilen
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
    for i = 1:ilen
        pzmap(linDyn.Lat{i,j,k},'b')
        hold on
        [num,den]=pade(delay(j),1);
        plot(num(2),0,'ro')
        plot(-den(2),0,'rx')
        hold off
        title('Lateral Dynamics Pole Map w/ Pade Delay Approximation')
        %annotation(sprintf('Tether Length = %d m',thrLenArray(i)))
        xlim([x1 1])
        ylim([y1 -y1])
        f = getframe(f1);
        im = frame2im(f);
        [imind,cm]  = rgb2ind(im,256);
        if i == 1
            imwrite(imind,cm,moviename,'gif', 'Loopcount',inf,'DelayTime',1/3);
        else
            imwrite(imind,cm,moviename,'gif','WriteMode','append','DelayTime',1/3)
        end
    end

    x1 = 0;
    x2 = den(2);
    y1 = 0;
    for i = 1:ilen
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
        moviename = sprintf('%dms_%ddeg_Long',25*j,k*2-2);
        f1 = figure
    for i = 1:ilen
        pzmap(linDyn.Long{i,j,k},'b')
        hold on

        plot(num(2),0,'ro')
        plot(-den(2),0,'rx')
        hold off
        title('Longitudinal Dynamics Pole Map w/ Pade Delay Approximation')
        hold off
        xlim([x1 1])
        ylim([y1 -y1])
        f = getframe(f1);
        im = frame2im(f);
        [imind,cm]  = rgb2ind(im,256);
        if i == 1
            imwrite(imind,cm,moviename,'gif', 'Loopcount',inf,'DelayTime',1/3);
        else
            imwrite(imind,cm,moviename,'gif','WriteMode','append','DelayTime',1/3)
        end
    end
end
end

%% Loop over Pitch Angle
for j = 16
for i = 3
    moviename = sprintf('%dm_%dms_Lat',5+5*i,25*j);
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
        title('Lateral Dynamics Pole Map w/ Pade Delay Approximation')
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
        moviename = sprintf('%dm_%dms_Long',5+5*i,25*j);
        f1 = figure
    for k = 1:klen
        pzmap(linDyn.Long{i,j,k},'b')
        hold on
        [num,den]=pade(delay(j),1);
        plot(num(2),0,'ro')
        plot(-den(2),0,'rx')
        hold off
        title('Longitudinal Dynamics Pole Map w/ Pade Delay Approximation')
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
end
end