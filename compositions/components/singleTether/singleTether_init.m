% for ii = 2:N-1
%     Ri_o(ii-1,:) = (Rn_o - R1_o)*(ii-1)/(N-1);
% end
% Ri_o = [R1_o;Ri_o;Rn_o];
% Vi_o = zeros(size(Ri_o));


initNodePoss = [linspace(ini_R1_o(1),ini_Rn_o(1),N),...
    linspace(ini_R1_o(2),ini_Rn_o(2),N),...
    linspace(ini_R1_o(3),ini_Rn_o(3),N)];
initNodeVels = zeros(size(initNodePoss));