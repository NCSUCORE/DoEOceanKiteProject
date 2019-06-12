initNodePoss = [linspace(ini_R1_o(1),ini_Rn_o(1),N);...
    linspace(ini_R1_o(2),ini_Rn_o(2),N);...
    linspace(ini_R1_o(3),ini_Rn_o(3),N)];

initNodePoss = initNodePoss(:,2:N-1);

initNodeVels = zeros(size(initNodePoss));
% x = 1;