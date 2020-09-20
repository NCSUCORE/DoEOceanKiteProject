function     [ActiveNodes, ActiveLengths,FirstLink,Delta] = numberOfActiveNodes(OriginalLengths, ReeledOutLength, ... 
    TetherLength,airNodePos, midNodePos, gndNodePos,ReelInVel,FirstLinkPrev,minLinkLength,minLinkDeviation)

% For position divergence vector
position = [gndNodePos,midNodePos,airNodePos];

%Number of nodes
No = length(OriginalLengths)+1;

%Prealocated L and Activelengths
ActiveLengths = zeros(size(OriginalLengths));
L = zeros(size(ActiveLengths));

%Set Flags
flag = false;
flagIn1  = false;
flagIn2  = false;
flagOut1 = false;

%Set search parameter
a = 1;

if ReeledOutLength == TetherLength  %Full Extension
    a = a+1;
    L(1:end) = OriginalLengths(1:end);
    FirstLink = OriginalLengths(1);
    Delta = 100;
    Na = No;
elseif ReeledOutLength > TetherLength
    a = a+1;
    L(1:end) = OriginalLengths(1:end);
    FirstLink = OriginalLengths(1)+ReeledOutLength - TetherLength;
    Delta = 100;
    Na = No;
else %Any amount of reel-in
    while flag == false %finds position of bottom link
        if ReeledOutLength == sum(OriginalLengths(a:end))
            flag = true;
        elseif ReeledOutLength > sum(OriginalLengths(a:end))
            flag = true;
        else
            a=a+1;
        end
    end
    %Changing first link length
    FirstLink = OriginalLengths(a-1)-(sum(OriginalLengths((a-1):end))-ReeledOutLength);
    
    %Setting flag one if within min length
    if FirstLink < minLinkLength %If below limit
        flagIn1  = true;
        flagOut1  = true;
    end
    
    Na = No-a+2;
    
    %Checks for delta if within minimum length
    if flagIn1  == true
        
        % pt is the location of first active node (1x3)
        % v1 is ground node location (1x3)
        % v2 is the second active node location (1x3)
        % Delta is a 1x1 scalar with the orthogonal distance
        v1 = position(:,1);
        pt = position(:,No-Na+2);
        v2 = position(:,No-Na+3);
        c = v1 - v2;
        d = pt - v2;
        Delta = sqrt(sum(cross(c,d).^2)) ./ sqrt(sum(c.^2));
        if Delta<=minLinkDeviation
            flagIn2 = true;
        elseif FirstLinkPrev>=OriginalLengths(1)
            flagIn2 = true;
        end
    else
        Delta = 100;
    end
    
    
    if a == No %If on last link
        L(end) = FirstLink;
    else
        if ReelInVel<=0 %Reeling in
            if flagIn1==true && flagIn2==true %Min and Delta
                L((a):end) = [OriginalLengths(a)+FirstLink,OriginalLengths((a+1):end)];
                FirstLink = OriginalLengths(a)+FirstLink;
            elseif flagIn1==true && flagIn2==false %Min not Delta
                L((a-1):end) = [FirstLink,OriginalLengths((a):end)];
            elseif flagIn1==false && flagIn2==true %Not min and Delta
                L((a-1):end) = [FirstLink,OriginalLengths((a):end)];
            elseif flagIn1==false && flagIn2==false %Not Min or Delta
                L((a-1):end) = [FirstLink,OriginalLengths((a):end)];
            end
        elseif ReelInVel>0 %Reeling out
            if flagOut1==true %Min
                L((a):end) = [OriginalLengths(a)+FirstLink,OriginalLengths((a+1):end)];
            elseif flagOut1==false %Not min
                L((a-1):end) = [FirstLink,OriginalLengths((a):end)];
            end
        end
    end
end


ActiveNodes = nnz(L)+1;
ActiveLengths = L;

Delta = Delta;
%Delta = Na;
% 
% Na = No-a+2;
% v1 = position(:,No-Na+1)-position(:,1);
% pt = position(:,No-Na+2)-position(:,1);
% if (No-Na+3)>No
%     v2 =  position(:,end)-position(:,1);
% else
%     v2 = position(:,No-Na+3)-position(:,1);
% end
% c = v1 - v2;
% d = pt - v2;
% Delta = norm(cross(c,d)) / norm(c);
% 
% 














% % % % % function [ActiveNodes, ActiveLengths] = numberOfActiveNodes(OriginalLengths, ReeledOutLength, TetherLength)
% % % % % 
% % % % % OriginalNodes = length(OriginalLengths)+1;
% % % % % No = OriginalNodes;
% % % % % 
% % % % % ActiveLengths = zeros(size(OriginalLengths));
% % % % % L = zeros(size(ActiveLengths));
% % % % % flag = false;
% % % % % a = 1;
% % % % % 
% % % % % if ReeledOutLength == TetherLength
% % % % %     a = a+1;
% % % % %     L(1:end) = OriginalLengths(1:end);
% % % % % else
% % % % %     while flag == false
% % % % %         if ReeledOutLength == sum(OriginalLengths(a:end))
% % % % %             flag = true;
% % % % %         elseif ReeledOutLength > sum(OriginalLengths(a:end))
% % % % %             flag = true;
% % % % %         else
% % % % %             a=a+1;
% % % % %         end
% % % % %     end
% % % % % 
% % % % % L((a-1):end) = (ReeledOutLength/(No-a+1))*ones(1,(No-a+1));
% % % % % 
% % % % % end
% % % % % 
% % % % % ActiveNodes = nnz(L)+1;
% % % % % ActiveLengths = L;
% % % % % 
