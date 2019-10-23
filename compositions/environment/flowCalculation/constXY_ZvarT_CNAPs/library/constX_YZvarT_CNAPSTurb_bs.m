

%% Set up environment
loadComponent('pathFollowingTether');
env = ENV.env;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'constX_YZvarT_CNAPSTurb'},'FlowDensities',1000)

env.water = env.water.setStartCNAPSTime(0,'s');
env.water = env.water.setEndCNAPSTime(3600,'s');

env.water.yBreakPoints.setValue(0:1:4,'m');

env.water.setTI(0.1,'');
env.water.setF_min(0.01,'Hz');
env.water.setF_max(1,'Hz');
env.water.setP(1,'');
env.water.setQ(0.1,'Hz');
env.water.setC(5,'');
env.water.setN_mid_freq(5,'');

% figure(1)
% plot(squeeze(env.water.flowVecTSeries.Value.Data(1,:,:)))
% ylim([-.5 1])
% figure(2)
% plot(squeeze(env.water.flowVecTSeries.Value.Data(2,:,:)))
% ylim([-.5 1])
env.water.process
env.water = env.water.buildTimeseries;
environment_bc
FLOWCALCULATION = 'constX_YZvarT_CNAPSTurb';
saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');





% % make a video
colormap(jet);
timeStep = 1;
frame_rate = 10*1/timeStep;
video = VideoWriter('vid_Test3', 'Motion JPEG AVI');
video.FrameRate = frame_rate; 
num_frames = length(env.water.flowTSX.time);

mov(1:length(env.water.flowTSX.time))=struct('cdata',[],'colormap',[]);  
set(gca,'nextplot','replacechildren')

for i = 1:100%length(env.water.flowTSY.time)
    
    figure(1)
    colormap(jet);
    contourf(env.water.yBreakPoints.Value,env.water.depthArray.Value,env.water.flowTSX.data(:,:,i))
    

    h1 = colorbar
    h1.Label.String= '[m/s]'
%     ('Ticks',1:0.2:1.8)
    
    xlabel('Y (m)')
    ylabel('Depth (m)')
    title(['U Component of Turbulent Flow at Y Z plane. Time = ',sprintf('%0.2f', env.water.flowTSX.time(i)),' s'])
%     h1 = axis; 
%     set(h1, 'Ydir', 'reverse')
 ax6 = gca;
 ax6.FontSize = 16;
%  h6.LineWidth = 1.5
%  h6.Color = [0, 0 ,0]
    set(gca, 'YDir','reverse')
    x0=100;
    y0=100;
   width=700;
 height= 500;
set(gcf,'position',[x0,y0,width,height])
    F(i) = getframe(gcf);
    
end


    open(video)
    for i = 1:length(F)
        writeVideo(video, F(i));
    end
    close(video)
