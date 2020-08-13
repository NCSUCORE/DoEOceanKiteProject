function [nodeForceVecs,Scope]  = tetherNodeTensionForce(ReeledOutLength, nodePos, nodeVel, ActiveLengths, ...
    NumberNodesActive, numNodes, thrDiam, youngsMod, dampingRatio, mass,minSoftLength)

% 
% mass = .05
% zeta = .75;
% thrDiam = .0144;
% youngsMod = 5*10^10;

%minSoftLength = .02;

%numNodes = size(nodePos,2);
No = numNodes;
Na = NumberNodesActive;

unstretchedLength = ReeledOutLength;
totalSpringConst = youngsMod*(pi/4)*(thrDiam^2)/unstretchedLength;

SpringConsts = zeros(1,numNodes-1);
if Na>2
    SpringConsts(:,(No-Na+2):end) = youngsMod*(pi/4)*(thrDiam^2)./ActiveLengths(1,(end-NumberNodesActive+3):end);
    if ActiveLengths(1,(end-NumberNodesActive+2))>minSoftLength
        SpringConsts(:,(No-Na+1)) = youngsMod*(pi/4)*(thrDiam^2)./ActiveLengths(1,(end-NumberNodesActive+2));
    else
        SpringConsts(:,(No-Na+1)) = youngsMod*(pi/4)*(thrDiam^2)./minSoftLength;
    end
else
    SpringConsts(end) = totalSpringConst;
end
DampCoeffs = dampingRatio*2*sqrt(SpringConsts.*mass);

% %%%%%%%%%%%%%%%%%%%%%%%
% SpringConsts = zeros(1,TotalNodes-1);
% if Na>2
%     SpringConsts(:,(No-Na+1):end) = youngsMod*(pi/4)*(thrDiam^2)./ActiveLengths(1,(end-NumberNodesActive+2):end);
% else
%     SpringConsts(end) = totalSpringConst;
% end
% DampCoeffs = zeta*2*sqrt(SpringConsts.*mass);
% 
% a = zeros(1,length(SpringConsts));
% for i = 1:length(SpringConsts)
%     if SpringConsts(i)==0
%         a(i) = 0;
%     else
%         a(i) = 1/SpringConsts(i);
%     end
% end
% %if ReeledOutLength<40.11 && ReeledOutLength>40
% if round((1/sum(a)))~=round(totalSpringConst)
%     round(totalSpringConst)
%     round((1/sum(a)))
%     ReeledOutLength
% end
% %end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

linkVecs  = diff(nodePos,1,2);
linkLength = sqrt(sum(linkVecs.^2));

linkUnitVecs = zeros(3,numNodes-1);
linkUnitVecs(1:3,(No-Na+1):end) = linkVecs(1:3,(No-Na+1):end)./repmat(sqrt(sum((linkVecs(1:3,(No-Na+1):end).^2),1)),[3 1]);
%prevent divide by zero if reeled in 
linkUnitVecs(isnan(linkUnitVecs))=0;

%Rate of change of all links
linkLengthDeriv = dot(nodeVel(:,2:end)-nodeVel(:,1:end-1),linkUnitVecs);

% %Forces from spring and damping in each link
% springForces = max(SpringConsts.*(linkLength-ActiveLengths),0);
% %damperForces = max(DampCoeffs.*linkLengthDeriv,0);
% %springForces = SpringConsts.*(linkLength-ActiveLengths);
% damperForces = max(DampCoeffs.*linkLengthDeriv,0);

%springForces = max(SpringConsts.*(linkLength-ActiveLengths),0);
springForces = SpringConsts.*(linkLength-ActiveLengths);
mask1 = springForces<0;
springForces(mask1) = (tanh(springForces(mask1)));%+springForces(mask1).*10^-2;
% springForces = SpringConsts.*(linkLength-ActiveLengths);

% damperForces = DampCoeffs.*linkLengthDeriv;
% mask1 = (linkLength-ActiveLengths)<0;
% damperForces(mask1) = 0;

%damperForces = max(DampCoeffs.*linkLengthDeriv,0);
damperForces = DampCoeffs.*linkLengthDeriv;
mask2 = damperForces<0;
damperForces(mask2) = (tanh(damperForces(mask2)));%+damperForces(mask2).*10^-2;

%Finds force along each link
totalLinkForceVec = repmat(springForces+damperForces,[3 1]).*linkUnitVecs;
%totalLinkSpringForceVec = repmat(springForces,[3 1]).*linkUnitVecs;

%Finds force on each node
nodeForceVecs = zeros(3,No);
nodeForceVecs(:,(No-Na+1):end) = [totalLinkForceVec(:,(No-Na+1)) diff(totalLinkForceVec(:,(No-Na+1):end),1,2) -totalLinkForceVec(:,end)];

%nodeForceVecs= [totalLinkForceVec(:,1) diff(totalLinkForceVec,1,2) -totalLinkForceVec(:,end)];

%Moves Reeled in bottom  node force to Ground Node
if SpringConsts(1) == 0
    nodeForceVecs(:,1) = nodeForceVecs(:,No-Na+1);
    nodeForceVecs(:,No-Na+1) = [0;0;0];
end


Scope = [linkLength ActiveLengths];
% Scope = damperForces;


% for ii=1:3
%     nodeForceVecs(ii,1) = -sum(nodeForceVecs(ii,2:end))-mean(nodeForceVecs(ii,2));
% end

    %nodeForceVecs(:,1) = nodeForceVecs(:,1)-nodeForceVecs(:,No-Na+2);




% % % % 
% % % % % % % %mass = .05;
% % % % % % % %dampingRatio = .75;
% % % % % % % %thrDiam = .0144;
% % % % % % % %youngsMod = 5*10^10;
% % % % 
% % % % TotalNodes = numNodes;%size(nodePos,2);
% % % % No = TotalNodes;
% % % % Na = NumberNodesActive;
% % % % 
% % % % unstretchedLength = ReeledOutLength;
% % % % totalSpringConst = youngsMod*(pi/4)*(thrDiam^2)/unstretchedLength;
% % % % 
% % % % SpringConsts = zeros(1,TotalNodes-1);
% % % % if Na>2
% % % %     SpringConsts(:,(No-Na+1):end) = youngsMod*(pi/4)*(thrDiam^2)./ActiveLengths(1,(end-NumberNodesActive+2):end);
% % % % else
% % % %     SpringConsts(end) = totalSpringConst;
% % % % end
% % % % DampCoeffs = dampingRatio*2*sqrt(SpringConsts.*mass);
% % % % 
% % % % linkVecs  = diff(nodePos,1,2);
% % % % linkLength = sqrt(sum(linkVecs.^2));
% % % % 
% % % % linkUnitVecs = zeros(3,TotalNodes-1);
% % % % linkUnitVecs(1:3,(No-Na+1):end) = linkVecs(1:3,(No-Na+1):end)./repmat(sqrt(sum((linkVecs(1:3,(No-Na+1):end).^2),1)),[3 1]);
% % % % %prevent divide by zero if reeled in 
% % % % linkUnitVecs(isnan(linkUnitVecs)) = 0;
% % % % 
% % % % %Rate of change of all links
% % % % linkLengthDeriv = dot(nodeVel(:,2:end)-nodeVel(:,1:end-1),linkUnitVecs);
% % % % 
% % % % %Forces from spring and damping in each link
% % % % springForces = SpringConsts.*(linkLength-ActiveLengths);
% % % % damperForces = DampCoeffs.*linkLengthDeriv;
% % % % 
% % % % %Finds force along each link
% % % % totalLinkForceVec = repmat(springForces+damperForces,[3 1]).*linkUnitVecs;
% % % % 
% % % % %Finds force on each node
% % % % nodeForceVecs = [totalLinkForceVec(:,1) diff(totalLinkForceVec,1,2) -totalLinkForceVec(:,end)];
% % % % 
% % % % %Moves Reeled in bottom  node force to Ground Node
% % % % if SpringConsts(1) == 0
% % % %     nodeForceVecs(:,1) = nodeForceVecs(:,No-Na+1);
% % % %     nodeForceVecs(:,No-Na+1) = [0;0;0];
% % % % end


