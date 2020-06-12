function [Bool,PositionIC]  = tetherNodePositionICReset(CurStepNumNodes, PrevStepNumNodes, nodePositions, gndNodePos, time, GivenIC, ReelInVel)

%Reel In
if ReelInVel<=0
    if time==0
        PositionIC = GivenIC;
        Bool = 1;
    else
        Na = CurStepNumNodes;
        No = size(nodePositions,2);

        if PrevStepNumNodes==0
            Nc = CurStepNumNodes;
            Np = Nc;
        else
            Np = PrevStepNumNodes;
            Nc = CurStepNumNodes;
        end

        PositionIC = [gndNodePos(1)*ones(1,No-2);...
                      gndNodePos(2)*ones(1,No-2);...
                      gndNodePos(3)*ones(1,No-2)];

        % Checks If The Current Number of Nodes Equals Previous Number of Nodes
        % If not equal then reset initial conditions
        if Nc == Np
            Bool = -1;
        else
            Bool = 1;
            linkVecs  = diff(nodePositions,1,2);
            for ii = 1:(Na-2)
                jj = (Na-2)-ii+1;
                VecToi = sum(linkVecs(:,1:(No-ii-2)),2);
                VecNextPercent = linkVecs(:,No-ii-1).*(jj/(Na-1));
                %PositionIC(:,jj+(No-Na)) = VecToi+VecNextPercent;
                PositionIC(:,jj+(No-Na)) = VecToi+VecNextPercent+PositionIC(:,jj+(No-Na));
            end  
        end
    end 
    
%Reel Out    
else
    if time==0
        PositionIC = GivenIC;
        Bool = 1;
    else
        Na = CurStepNumNodes;
        No = size(nodePositions,2);

        if PrevStepNumNodes==0
            Nc = CurStepNumNodes;
            Np = Nc;
        else
            Np = PrevStepNumNodes;
            Nc = CurStepNumNodes;
        end

        PositionIC = [gndNodePos(1)*ones(1,No-2);...
                      gndNodePos(2)*ones(1,No-2);...
                      gndNodePos(3)*ones(1,No-2)];
                  
        % Checks If The Current Number of Nodes Equals Previous Number of Nodes
        % If not equal then reset initial conditions
        if Nc == Np
            Bool = -1;
        else
            Bool = 1;
            linkVecs  = diff(nodePositions,1,2);
            for ii = 1:(Na-2)
                jj = (Na-2)-ii+1;
                VecToi = sum(linkVecs(:,1:(No-ii)),2);
                VecNextPercent = linkVecs(:,No-ii).*((jj)/(Na-1));
                %PositionIC(:,jj+(No-Na)) = VecToi-VecNextPercent;
                PositionIC(:,jj+(No-Na)) = VecToi-VecNextPercent+PositionIC(:,jj+(No-Na));
            end 
        end
    end  
end
%%%%%%%%%%%%%%%%%%%%%%%%

% if Bool == 1
%     nodePositions
%     PositionIC
% end              
                  
                  
                  