



close all;clear;clc

% Setting sim time to zero runs a single time step
simTime = 10;
SampleTime = .1;
time = 0:SampleTime:simTime;

TetherLengthI = 91;
TetherLengthF = 1.01;

LastLinkLength = 1;

numNodes = 8;
initNodePosTotal = [0,15,30,45,60,75,90,91];%linspace(0,TetherLength,numNodes)


initNodeVel = zeros(3,numNodes-2);
initNodePos = [zeros(1,numNodes-2);zeros(1,numNodes-2);initNodePosTotal(2:end-1)];

gndNodePos = zeros(3,1);
gndNodeVel = zeros(3,1);
airNodePos = [0;0;initNodePosTotal(end)];
airNodeVel = zeros(3,1);

k = SampleTime:SampleTime:simTime;
TetherLength = linspace(TetherLengthI,TetherLengthF,length(k));
for i = 1:length(k)
    gndNodePos(1:3,i+1) = [0,0,0];
    %gndNodePos(1:3,i+1) = [-k(i)*SampleTime,0,0];
    airNodePos(1:3,i+1) = [5*k(i)*SampleTime,0,TetherLength(i)];
    %airNodePos(1:3,i+1) = [0,0,TetherLength];
    LinkUnstrechedLengths(i+1,:) = [((TetherLength(i)-LastLinkLength)/(numNodes-2))*ones(1,numNodes-2),LastLinkLength];
end
LinkUnstrechedLengths(1,:) = [((TetherLength(1)-LastLinkLength)/(numNodes-2))*ones(1,numNodes-2),LastLinkLength];
TetherLength = [TetherLengthI,TetherLength];



gndNodeVel = gradient(gndNodePos);
airNodeVel = gradient(airNodePos);

gndNodePosTS = timeseries(gndNodePos,time);
gndNodeVelTS = timeseries(gndNodeVel,time);
airNodePosTS = timeseries(airNodePos,time);
airNodeVelTS = timeseries(airNodeVel,time);
TetherLengthTS = timeseries(TetherLength,time);
UnstrechedLengthsTS = timeseries(LinkUnstrechedLengths,time);


linkFlowVelVecs = [.0000001*ones(1,numNodes-1);0*ones(1,numNodes-1);0*ones(1,numNodes-1)];

simout = sim('tether001_th');

tsc = signalcontainer(simout.logsout);

nodePositionVecs = tsc.nodePositionVecs.Data;
forceVecBdy = tsc.forceVecBdy.Data;
a = tsc.a.Data;
v = tsc.v.Data;
x = tsc.x.Data;

Num = size(x);
Time = tsc.x.Time;

h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
filename = 'testAnimated.gif'; 
for i = 1:Num(3)
    A = [gndNodePos(1,i),x(1,:,i),airNodePos(1,i)];
    B = [gndNodePos(2,i),x(2,:,i),airNodePos(2,i)];
    C = [gndNodePos(3,i),x(3,:,i),airNodePos(3,i)];
    plot3(A',B',C','.-');
    title(['Time (s) ',num2str(round(round(Time(i),2,'significant'),4))])
    xlim([-50,50]);
    ylim([-50,50]);
    zlim([0,max(TetherLength)]);
          % Capture the plot as an image 
      frame = getframe(h); 
      im = frame2im(frame); 
      [imind,cm] = rgb2ind(im,256); 
      % Write to the GIF File 
      if i == 1 
          imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
      else 
          imwrite(imind,cm,filename,'gif','WriteMode','append'); 
      end 
end
xlabel('x')
ylabel('y')
zlabel('z')
drawnow 





















