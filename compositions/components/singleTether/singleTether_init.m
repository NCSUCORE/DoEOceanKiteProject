% for ii = 2:N
%     initNodePoss(ii-1,:) = (ini_Rn_o(:)' - ini_R1_o(:)')*(ii-1)/(N-1);
% end
% initNodePoss = [ini_R1_o(:)';initNodePoss;ini_Rn_o(:)'];
% initNodeVels = zeros(size(initNodePoss));


initNodePoss = [linspace(ini_R1_o(1),ini_Rn_o(1),N);...
    linspace(ini_R1_o(2),ini_Rn_o(2),N);...
    linspace(ini_R1_o(3),ini_Rn_o(3),N)];
initNodeVels = zeros(size(initNodePoss));
% x = 1;