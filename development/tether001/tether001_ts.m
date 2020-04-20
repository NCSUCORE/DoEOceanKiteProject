
close all;clear;clc

% Setting sim time to zero runs a single time step
simTime = 25;
SampleTime = .1;
time = 0:SampleTime:simTime;

ReelInVelcoity = 0; 
TetherTotalLength = 100;
TopLinkLength = 10;

NumberNodesTotal = 10;
LinkUnstrechedLengths = [((TetherTotalLength-TopLinkLength)/(NumberNodesTotal-2))*ones(1,NumberNodesTotal-2),TopLinkLength];
FirstLinkLengthI = LinkUnstrechedLengths(1);
FirstLinkLengthF = FirstLinkLengthI+ReelInVelcoity*simTime;
% if FirstLinkLengthF<=0
%     fprintf('Wont Work')
%     FirstLinkLengthF
% end

INITIALLINE = linspace(LinkUnstrechedLengths(2),TetherTotalLength-TopLinkLength,NumberNodesTotal-2);
initNodeVel = [zeros(1,NumberNodesTotal-2);zeros(1,NumberNodesTotal-2);zeros(1,NumberNodesTotal-2)];
%initNodePos = [zeros(1,NumberNodesTotal-2);zeros(1,NumberNodesTotal-2);INITIALLINE];
initNodePos = [zeros(1,NumberNodesTotal-2);INITIALLINE;zeros(1,NumberNodesTotal-2)];

k = 0:SampleTime:simTime;
FirstLinkLength = linspace(FirstLinkLengthI,FirstLinkLengthF,length(k));

HORZ = linspace(0,10,length(k));
for i = 1:length(k)
    gndNodePos(1:3,i) = [0,0,0];
    %gndNodePos(1:3,i) = [-k(i)*SampleTime,0,0];
    %airNodePos(1:3,i) = [HORZ(i),0,TetherTotalLength+FirstLinkLengthI-FirstLinkLength(i)];
    %airNodePos(1:3,i) = [0,0,TetherTotalLength];
    airNodePos(1:3,i) = [0,TetherTotalLength,0];
end

% for i = ((length(k)/2)+1):length(k)
%     gndNodePos(1:3,i) = [0,0,0];
%     %gndNodePos(1:3,i+1) = [-k(i)*SampleTime,0,0];
%     airNodePos(1:3,i) = [HORZ(length(k)/2),0,TetherTotalLength+FirstLinkLengthI-FirstLinkLength(length(k)/2)];
%     %airNodePos(1:3,i+1) = [0,0,TetherLength(end)];
%     %airNodePos(1:3,i+1) = [0,TetherLength(end),0];
% end

gndNodeVel = gradient(gndNodePos);
airNodeVel = gradient(airNodePos);

gndNodePosTS = timeseries(gndNodePos,time);
gndNodeVelTS = timeseries(gndNodeVel,time);
airNodePosTS = timeseries(airNodePos,time);
airNodeVelTS = timeseries(airNodeVel,time);

VelocityReelInTS = timeseries(ReelInVelcoity*ones(length(time),1),time);
FirstLinkLengthTS= timeseries(FirstLinkLength,time);

linkFlowVelVecs = [.00001*ones(1,NumberNodesTotal-1);0*ones(1,NumberNodesTotal-1);0*ones(1,NumberNodesTotal-1)];

%simTime = 0;
simout = sim('tether001_th');
%simout = sim('tether000Comparison_th');

tsc = signalcontainer(simout.logsout);

Time = tsc.x.Time;
x = tsc.x.Data;
Num = size(x);
h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
filename = 'testAnimated.gif'; 
for i = 1:Num(3)
    A = [gndNodePos(1,i),x(1,:,i),airNodePos(1,i)];
    B = [gndNodePos(2,i),x(2,:,i),airNodePos(2,i)];
    C = [gndNodePos(3,i),x(3,:,i),airNodePos(3,i)];
    plot3(A',B',C','.-');
    title(['Time (s) ',num2str(round(round(Time(i),2,'significant'),4))])
%     xlim([-50,50]);
%     ylim([-50,50]);
%     zlim([0,max(TetherTotalLength)]);
    xlim([-10,50]);
    ylim([-10,TetherTotalLength+5]);
    zlim([-30,30]);
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







% 
% Node1Acceleration = tsc.Node1Acceleration.Data;
% a = tsc.a.Data;
% v = tsc.v.Data;
% x = tsc.x.Data;
% PMAT = tsc.PMAT.Data;
% KMAT = tsc.KMAT.Data;
% XMAT = tsc.XMAT.Data;
% INVMASS = tsc.INVMASS.Data;
% min(INVMASS(INVMASS>0))
% WMAT = tsc.WMAT.Data;
% FTOTAL = tsc.FTOTAL.Data;
% D2R_DS2 = tsc.D2R_DS2.Data;
% FW = tsc.FW.Data;
% FK = tsc.FK.Data;
% 
% i=10;
% INVM = [INVMASS(:,:,i)*(PMAT(:,:,i)*KMAT(:,:,i)*XMAT(i,:)'+PMAT(:,:,i)*WMAT(i,:)'),...
%         INVMASS(:,:,end)*(PMAT(:,:,end)*KMAT(:,:,end)*XMAT(end,:)'+PMAT(:,:,end)*WMAT(end,:)')];
% F_Tot = reshape(FTOTAL(i,:)',3,numel(FTOTAL(i,:)')/3)
% FW = reshape(FW(i,:)',3,numel(FW(i,:)')/3)
% FK = reshape(FK(i,:)',3,numel(FK(i,:)')/3)
% d2rdsr2 = reshape(D2R_DS2(i,:)',3,numel(D2R_DS2(i,:)')/3)
% r = x(:,:,end)














