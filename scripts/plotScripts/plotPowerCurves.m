%%
figure; hold on; grid on;
fpath = fullfile(fileparts(which('OCTProject.prj')),'output','Tmax Study\');
load([fpath,sprintf('TmaxStudy_%dkN.mat',38)]);
for i = 1:6
    plot(flwSpd,R.Pmax1(:,i));  xlabel('Flow Speed [m/s]');  ylabel('Power [kW]'); 
end
legend('Alt = 50 m','Alt = 100 m','Alt = 150 m','Alt = 200 m','Alt = 250 m','Alt = 300 m')
