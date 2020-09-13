JanAvg = squeeze(mean(JANpow,4));
AprAvg = squeeze(mean(APRpow,4));
JulAvg = squeeze(mean(JULpow,4));
OctAvg = squeeze(mean(OCTpow,4));
%%
figure;
subplot(4,1,1)
histogram(JanAvg,[0:.2:1.2],'Normalization','probability');  ylabel('Probability');  title('January 2017')
subplot(4,1,2)
histogram(AprAvg,[0:.2:1.2],'Normalization','probability');  ylabel('Probability');  title('April 2017')
subplot(4,1,3)
histogram(JulAvg,[0:.2:1.2],'Normalization','probability');  ylabel('Probability');  title('July 2017')
subplot(4,1,4)
histogram(OctAvg,[0:.2:1.2],'Normalization','probability');  xlabel('Power [kW]');  ylabel('Probability');  title('October 2017')
%%
n = 1;
for i = 1:7
    for j = 1:7
        for k = 1:25
            Jan(n) = JanAvg(i,j,k);
            Apr(n) = AprAvg(i,j,k);
            Jul(n) = JulAvg(i,j,k);
            Oct(n) = OctAvg(i,j,k);
            n = n+1;
        end
    end
end
%%
Jan50 = prctile(Jan,50);  Jan75 = prctile(Jan,75);  Jan90 = prctile(Jan,90);  
Apr50 = prctile(Apr,50);  Apr75 = prctile(Apr,75);  Apr90 = prctile(Apr,90);  
Jul50 = prctile(Jul,50);  Jul75 = prctile(Jul,75);  Jul90 = prctile(Jul,90);  
Oct50 = prctile(Oct,50);  Oct75 = prctile(Oct,75);  Oct90 = prctile(Oct,90);  