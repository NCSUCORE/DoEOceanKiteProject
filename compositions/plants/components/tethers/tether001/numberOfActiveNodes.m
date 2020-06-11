function [ActiveNodes, ActiveLengths] = numberOfActiveNodes(OriginalLengths, ReeledOutLength, TetherLength)

OriginalNodes = length(OriginalLengths)+1;
No = OriginalNodes;

ActiveLengths = zeros(size(OriginalLengths));
L = zeros(size(ActiveLengths));
flag = false;
a = 1;

if ReeledOutLength == TetherLength
    a = a+1;
    L(1:end) = OriginalLengths(1:end);
else
    while flag == false
        if ReeledOutLength == sum(OriginalLengths(a:end))
            flag = true;
        elseif ReeledOutLength > sum(OriginalLengths(a:end))
            flag = true;
        else
            a=a+1;
        end
    end

L((a-1):end) = (ReeledOutLength/(No-a+1))*ones(1,(No-a+1));

end

ActiveNodes = nnz(L)+1;
ActiveLengths = L;

