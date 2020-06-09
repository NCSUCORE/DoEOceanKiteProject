clear p spoolTotal speeds pow

timediffs=diff(interp1(pathVars{mid},times{mid},linspace(0,1,1000),'linear','extrap'));
timediffs=[timediffs timediffs(end)];
p(1)=mean(mean(Ten));
n=50;
speeds = cell(1,n);
spoolTotalSum = 0;
spoolTotalSumSum = 0;
errorTotalSum = 0;
pow = zeros(1,n);
for i = 1:n
    %%
    if mod(i,10)==0
        disp(100*i/n)
    end
    speeds{i} = zeros(1,1000);
    energy(i)=0;
    %%
    for ii = 1:1000
        hamil = @(x) (p(i)-Ten(ii,xopts==x)).*x;
        [~,bestind]=min(hamil(xopts));
        bestspeed=xopts(bestind);
        tenbest=Ten(ii,bestind);
        speeds{i}(ii)=bestspeed;
        energy(i) = energy(i) + (tenbest*bestspeed*timediffs(ii));
        %% Animation stuff
        if false && i == 50 && mod(ii,5)==0
            if ii==5
                figure;
            end
            plot(xopts,Ten(ii,:))
            hold on
            plot(xopts,ones(size(xopts))*p(i))
            if bestspeed>0
                rectangle('Position',[0,p(i),bestspeed,tenbest-p(i)],'faceColor','c')
            else
                rectangle('Position',[bestspeed,tenbest,-bestspeed,p(i)-tenbest],'faceColor','c');
            end
            plot([bestspeed bestspeed],[min(min(Ten)) max(max(Ten))],'r--')
            ylim([min(min(Ten)) max(max(Ten))])
            legend('Current Tension Profile','Critical Tension','Optimal Spool Speed')
            ylabel('Tension')
            title(sprintf('Tension at Path Variable = %4.3f',ii/1000))
            xlabel('spool speed');
            hold off
            pause(.01)
            if false
                filename="rec_anim.gif";
                frame = getframe(gcf); 
                im = frame2im(frame); 
                [imind,cm] = rgb2ind(im,256); 
                if ii == 5 
                  imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
                else 
                  imwrite(imind,cm,filename,'gif','DelayTime',.01,'WriteMode','append'); 
                end 
            end
        end
    end
    spoolTotal(i) = sum(speeds{i}.*timediffs);
    spoolTotalSum = spoolTotalSum + spoolTotal(i);
    spoolTotalSumSum = spoolTotalSumSum + spoolTotalSum;
    
    
    kp=1200;
    ki=600;
    p(i+1)=kp*spoolTotalSum + ki*spoolTotalSumSum + p(1);
end
%%
figure;
subplot(2,2,1);plot(spoolTotal)
xlabel('Iterations')
ylabel('Net Amount Spooled per iteration (m)')
title('Spooling Error vs Iteration')
subplot(2,2,2);plot(p)
xlabel('Iterations')
ylabel('Critical Tension (N)')
title('Costate value vs iteration')
subplot(2,2,3);plot(energy/range(times{mid}))
xlabel('Iterations')
ylabel('Power Production (Watts)')
title('Power Production vs Iteration')
linkaxes(findall(gcf,'Type','axes'),'x')
xlim([1 inf])
subplot(2,2,4);plot(linspace(0,1,1000),speeds{end})
xlabel('pathVar')
ylabel('Optimized Spool Speed')
% title=sprintf('Final Optimized Spooling Strategy\nSpools Out %4.2f%% of the time',100*length(speeds{end}(speeds{end}>0))/length(speeds{end}));
nums=1:1000;
nums=nums(speeds{end}>0);
title(['Final Optimized Spooling Strategy' newline 'Spools Out ' char(string(100*length(speeds{end}(speeds{end}>0))/length(speeds{end}))) '% of the path'])
% title(['Final Optimized Spooling Strategy' newline 'Spools Out ' char(string(100* sum(timediffs(speeds{end}>0))/sum(timediffs))) '% of the path'])

%% 
s=linspace(0,1,1000)';
figure;h=surf(spoolSpeeds,s,Ten);set(h,'LineStyle','none')
hold on
if exist('p','var')
    h1=surf(spoolSpeeds,s,p(end)*ones(size(Ten)),'FaceColor','c');
    set(h1,'LineStyle','none')
end
xlabel("Spooling Speeds (m/s)")
ylabel("Path Variable")
zlabel("Estimated Tether Tension (N)")
%%
% figure
% cmap=jet(17);
% for i=[1:17]
%     timediffs1=diff(interp1(pathVars{i},times{i},linspace(0,1,1000),'linear','extrap'));
%     timediffs1=[timediffs1 timediffs1(end)];
%     plot(linspace(0,1,1000),timediffs1,'Color',cmap(i,:),'lineWidth',interp1(1:17,1:2,i))
%     hold on
%     maxomin(i) = max(diff(interp1(pathVars{i},times{i},linspace(0,.99,1000),'linear','extrap')))/min(diff(interp1(pathVars{i},times{i},linspace(0,.99,1000),'linear','extrap')));
% end
% colormap jet
% caxis([-.4 .4])
% colorbar
% xlabel('Path Variable')
% ylabel('Time to move .001 path Variable (s)')
% % xlim([0,.99])