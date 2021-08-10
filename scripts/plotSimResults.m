%%  Script to plot/animate single simulation results 
thrDiam = 18;
fairing = 100;
Tmax = getMaxTension(thrDiam);          
load(sprintf('powStudy_CDR_ThrD-%.1f_Fair-%d.mat',thrDiam,fairing))
flwSpd = 0.45;      idxV = find(flwArray==flwSpd);
altitude = 300;     idxA = find(altArray==altitude);
thrLength = R1.thrL(idxV,idxA);
fpath = 'D:/Power Study/';
filename = sprintf(strcat('CDR_V-%.3f_alt-%.d_thrL-%d_thrD-%.1f_Fair-%d.mat'),flwSpd,altitude,thrLength,thrDiam,fairing);
load([fpath filename]);
%%
lap = max(tsc.lapNumS.Data)-1;
tsc.plotFlightResultsEng(vhcl,env,thr,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0,'cross',1==0)
%%
% vhcl.animateSimEng(tsc,5,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',20,...
%     'GifTimeStep',.1,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
%     'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','.gif'));
%%  No path
vhcl.animateSimEng(tsc,5,'TracerDuration',20,...
    'GifTimeStep',.1,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
    'ZoomIn',1==0,'SaveGif',1==0,'GifFile',strrep(filename,'.mat','a.gif'));
