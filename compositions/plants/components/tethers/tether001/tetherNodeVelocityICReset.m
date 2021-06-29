function [Bool,VelocityIC]  = tetherNodeVelocityICReset(CurStepNumNodes, PrevStepNumNodes, nodeVelocities, gndNodeVel, time, GivenIC, ReelInVel)

if ReelInVel<=0
    if time==0
        VelocityIC = GivenIC;
        Bool = 1;
    else
        Na = CurStepNumNodes;
        No = size(nodeVelocities,2);

        if PrevStepNumNodes==0
            Nc = CurStepNumNodes;
            Np = Nc;
        else
            Np = PrevStepNumNodes;
            Nc = CurStepNumNodes;
        end

        VelocityIC = [gndNodeVel(1)*ones(1,No-2);...
                      gndNodeVel(2)*ones(1,No-2);...
                      gndNodeVel(3)*ones(1,No-2)];

        % Checks If The Current Number of Nodes Equals Previous Number of Nodes
        % If not equal then reset initial conditions
        if Nc == Np
            Bool = -1;
        else
            Bool = 1;
            linkVecs  = diff(nodeVelocities,1,2);
            for ii = 1:(Na-2)
                jj = (Na-2)-ii+1;
                VecToi = sum(linkVecs(:,1:(No-ii-2)),2);
                VecNextPercent = linkVecs(:,No-ii-1).*(jj/(Na-1));
                %VelocityIC(:,jj+(No-Na)) = VecToi+VecNextPercent;
                VelocityIC(:,jj+(No-Na)) = VecToi+VecNextPercent+VelocityIC(:,jj+(No-Na));
            end  
        end
    end         
else
    if time==0
        VelocityIC = GivenIC;
        Bool = 1;
    else
        No = size(nodeVelocities,2);

        if PrevStepNumNodes==0
            Nc = CurStepNumNodes;
            Np = Nc;
        else
            Np = PrevStepNumNodes;
            Nc = CurStepNumNodes;
        end

        VelocityIC = [gndNodeVel(1)*ones(1,No-2);...
                      gndNodeVel(2)*ones(1,No-2);...
                      gndNodeVel(3)*ones(1,No-2)];
                  
        % Checks If The Current Number of Nodes Equals Previous Number of Nodes
        % If not equal then reset initial conditions
        if Nc == Np
            Bool = -1;
        else
            Bool = 1;
            VelocityIC(:,No-Nc-1:end) = nodeVelocities(:,No-Nc+1:end); % set nodes to keep
        end
    end  
end



                  
                  
                  