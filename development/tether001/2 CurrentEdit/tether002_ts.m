
close all;clear;clc
% Setting sim time to zero runs a single time step
simTime = 1000;
SampleTime = .1; %SOMETHING WEIRD WHEN THIS NUMBER CHANGES
time = 0:SampleTime:simTime;

TetherLength = 100;

numNodes = 11;
TopLinkLength = TetherLength/(numNodes-1);
OriginalLengths = [((TetherLength-TopLinkLength)/(numNodes-2))*ones(1,numNodes-2),TopLinkLength];
LengthI = 100; %TetherLength;
LengthF = 1;
% if FirstLinkLengthF<=0
%     fprintf('Wont Work')
%     FirstLinkLengthF
% end

%INITIALLINE = linspace(OriginalLengths(2),TetherLength-TopLinkLength,numNodes-2);
INITIALLINE = linspace(sqrt((OriginalLengths(end)^2)/3),sqrt((LengthI^2)/3)-sqrt((OriginalLengths(1)^2)/3),numNodes-2);
initNodeVel = [zeros(1,numNodes-2);zeros(1,numNodes-2);zeros(1,numNodes-2)];
%initNodePos = [zeros(1,NumberNodesTotal-2);zeros(1,NumberNodesTotal-2);INITIALLINE];
%initNodePos = [zeros(1,numNodes-2);INITIALLINE;zeros(1,numNodes-2)];
%initNodePos = [INITIALLINE;zeros(1,numNodes-2);zeros(1,numNodes-2)];
initNodePos = [INITIALLINE;INITIALLINE;INITIALLINE];
%initNodePos = [linspace(1,9,NumberNodesTotal-2);zeros(1,NumberNodesTotal-2);INITIALLINE];


k = 0:SampleTime:simTime;
ReeledOutLength = linspace(LengthI,LengthF,length(k));

ReelInVel = -(LengthI-LengthF)/simTime;

%AIR = linspace(LengthI,LengthF,length(k));
AIRDiag = linspace(sqrt((LengthI^2)/3)+1,sqrt((LengthF^2)/3)+.01,length(k));
GND = linspace(0,0,length(k));
for i = 1:length(k)
    gndNodePos(1:3,i) = [0,0,GND(i)];
    %gndNodePos(1:3,i) = [-k(i)*SampleTime,0,0];
    airNodePos(1:3,i) = [AIRDiag(i),AIRDiag(i),AIRDiag(i)];
    %airNodePos(1:3,i) =  [10,0,VERT(i)];
    %airNodePos(1:3,i) = [0,0,TetherTotalLength];
    %airNodePos(1:3,i) = [AIR(i),0,0];
    %airNodePos(1:3,i) = [0,TetherLength,0];
end

% for i = (length(k)/2+.5):length(k)
%     gndNodePos(1:3,i) = [0,0,0];
%     %gndNodePos(1:3,i) = [-k(i)*SampleTime,0,0];
%     airNodePos(1:3,i) = [HORZ(i),0,TetherTotalLength+FirstLinkLengthI-FirstLinkLength(i)];
%     %airNodePos(1:3,i) =  [10,0,VERT(end)];
%     %airNodePos(1:3,i) = [0,0,TetherTotalLength];
%     %airNodePos(1:3,i) = [0,TetherTotalLength,0];
% end
% for i = ((length(k)/2)+1):length(k)
%     gndNodePos(1:3,i) = [0,0,0];
%     %gndNodePos(1:3,i+1) = [-k(i)*SampleTime,0,0];
%     airNodePos(1:3,i) = [HORZ(length(k)/2),0,TetherTotalLength+FirstLinkLengthI-FirstLinkLength(length(k)/2)];
%     %airNodePos(1:3,i+1) = [0,0,TetherLength(end)];
%     %airNodePos(1:3,i+1) = [0,TetherLength(end),0];
% end

TetherLengthOLDTS = timeseries(linspace(LengthI,LengthF,length(k)),time);

gndNodeVel = gradient(gndNodePos);
airNodeVel = gradient(airNodePos);

gndNodePosTS = timeseries(gndNodePos,time);
gndNodeVelTS = timeseries(gndNodeVel,time);
airNodePosTS = timeseries(airNodePos,time);
airNodeVelTS = timeseries(airNodeVel,time);
ReeledOutLengthTS = setinterpmethod(timeseries(ReeledOutLength,time),'zoh');


%%


linkFlowVelVecs = [10*ones(1,numNodes-1);10*ones(1,numNodes-1);.001*ones(1,numNodes-1)];

simout2 = sim('tether003_th');

%initNodePos = [[0,0,0,0,0,0,0,1,11];zeros(1,numNodes-2);zeros(1,numNodes-2)];
simout = sim('tether002_th');


tsc = signalcontainer(simout.logsout);
tsc2 = signalcontainer(simout2.logsout);


Time = tsc.x.Time;
x = tsc.x.Data;
x2 = tsc2.x.Data;
Scope = tsc.Scope.Data;

% for i = 2:length(Scope)
%     if Scope(i)>Scope(i-1)
%         [Scope(i-1),Scope(i)]
%     end
% end
figure(1)
    hold on 
    for i = 1:size(tsc.NForce.Data,3)
        NForce(i) = norm(tsc.NForce.Data(:,1,i));
        OneForce(i) = norm(tsc.OneForce.Data(:,1,i));
    end
    
    for i = 1:size(tsc2.NForce.Data,3)
        NForceCurr(i) = norm(tsc2.NForce.Data(:,1,i));
        OneForceCurr(i) = norm(tsc2.OneForce.Data(:,1,i));
    end
    
    NForceTime = tsc.NForce.Time;    
    OneForceTime = tsc.OneForce.Time;
    NForceTimeCurr = tsc2.NForce.Time;
    OneForceTimeCurr = tsc2.OneForce.Time;
    
    Timestart = 2;    
    %Direction = 3; %x(1) y(2) z(3)
    
    %Air
    %Timestart = 11000;
    plot(NForceTime(Timestart:end,1),NForce(Timestart:end))
    %Timestart = 1000;
    plot(NForceTimeCurr(Timestart:end,1),NForceCurr(Timestart:end),'--')
    
    %Ground
    %Timestart = 11000;
    plot(OneForceTime(Timestart:end,1),OneForce(Timestart:end))
    plot(OneForceTimeCurr(Timestart:end,1),OneForceCurr(Timestart:end),'--')
    
    legend('Air New','Air Org','Ground New','Ground Org')
    title('X Direction Force')
    ylabel('Force')
    xlabel('Time (s)')
hold off

%figure(3)
%plot(Scope(2:end))
% for i = 1:size(Scope,1)
%     ScopeNorm(i) = norm(Scope(i,:));
% end
% plot(ScopeNorm)
% for i = 1:size(x(1,1,:),3)
%     XPLOT(i) = x(1,7,i);
% end
% plot(XPLOT)



%%
Num = size(x);
h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
filename = 'testAnimated.gif'; 
for i = 1:Num(3)
     A = [gndNodePos(1,i),x(1,:,i),airNodePos(1,i)];
     B = [gndNodePos(2,i),x(2,:,i),airNodePos(2,i)];
     C = [gndNodePos(3,i),x(3,:,i),airNodePos(3,i)];
     A2 = [gndNodePos(1,i),x2(1,:,i),airNodePos(1,i)];
     B2 = [gndNodePos(2,i),x2(2,:,i),airNodePos(2,i)];
     C2 = [gndNodePos(3,i),x2(3,:,i),airNodePos(3,i)];
    plot3(A',B',C','.-b','LineWidth',.9,'MarkerSize',10);
    hold on
    plot3(A2',B2',C2','.-r','LineWidth',.9,'MarkerSize',10);
    hold on
    plot3(A(1)',B(1)',C(1)','.g','MarkerSize',25);
    view([37.5 30])
    %plot(A2',C2','.-r','LineWidth',.9,'MarkerSize',10);
    %hold on 
    %plot(A',C','.-b','LineWidth',.9,'MarkerSize',10);
    %[j k l] = sphere;
    %g = surfl(j, k, l); 
    %set(g, 'FaceAlpha', 0.5)
    %shading interp
    hold off
   title(['Tether 100 (m) Reel-Out 10 m/s Upwelling (time (s) ',num2str(round(round(Time(i),2,'significant'),4)),')'],'FontSize',15);
   %  ylim([-15,15]);
   %   xlim([-15,TetherLength+5]);
%      ylim([-1,1])
%      xlim([0,2.5]);
%       ylim([-50,50]);
%       xlim([-5,TetherLength+5]);
    zlim([-5,sqrt((max(LengthI,LengthF)^2)/3)]);
    ylim([-5,sqrt((max(LengthI,LengthF)^2)/3)]);
    xlim([-5,sqrt((max(LengthI,LengthF)^2)/3)]);
   % xlim([-5,5]);
   % ylim([-5,TetherLength+5]);
   % zlim([-5,10]);
    xlabel('x,(m)','FontSize',13);
    ylabel('y,(m)','FontSize',13);
    zlabel('z,(m)','FontSize',13);
%     ylabel('y,(m)','FontSize',13);
%     xlabel('x,(m)','FontSize',14);
     %   legend('Proposed Model','Current Model')
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
   % xlabel('x,(m)','FontSize',13);
    ylabel('z,(m)','FontSize',13);
    xlabel('Horizontal tether with 10 m/s upwelling','FontSize',14);
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














