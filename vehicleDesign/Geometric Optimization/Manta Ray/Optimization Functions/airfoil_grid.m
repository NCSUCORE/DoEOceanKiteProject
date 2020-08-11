function [Ixx_lim] = airfoil_grid(AR,S)
% I beam airfoil grid code

% Airfoil characteristics
ChrdL = S/AR;

%I beam dimension
T1Brat = 0.3;     % 30% - Max ratio of T1 and Max value of B
T2Arat = 0.2;     % 10% - Max ratio of T2 and Max value of A

% Importing airfoil
[x_af,us_af,ls_af] = airfoil_data();

% Grid specifications
x_ind = [7 15 25 35 45 55 65 75 82 90];

y_lim = linspace(-0.1,0.1);
x_lim = linspace(-0.1,1.1);
for i = 1:length(x_ind)
    x_elem = x_af(x_ind(i));
    
    y_elem_us = us_af(x_ind(i));
    y_elem_ls = ls_af(x_ind(i));
    
    x_grid = x_elem*ones(length(y_lim));
    y_grid_us = y_elem_us*ones(length(x_lim));
    y_grid_ls = y_elem_ls*ones(length(x_lim));
end

% Creating I beams and calculating Ixx
for j = 1:(length(x_ind)-1)
   B_arr(j) = x_af(x_ind(j+1)) - x_af(x_ind(j));
   
   y_us = us_af(x_ind(j+1));
   y_ls = ls_af(x_ind(j+1));
   if us_af(x_ind(j)) < us_af(x_ind(j+1))
       y_us = us_af(x_ind(j));
   end
   if abs(ls_af(x_ind(j))) < abs(ls_af(x_ind(j+1)))
       y_ls = ls_af(x_ind(j));
   end
   A_arr(j) = y_us - y_ls;
   
   T1_arr(j) = B_arr(j)*T1Brat;
   T2_arr(j) = A_arr(j)*T2Arat;
   
   [Ixx,~] = AMoICalc(A_arr(j)*ChrdL,B_arr(j)*ChrdL,T1_arr(j)*ChrdL,...
       T2_arr(j)*ChrdL);
   Ixx_arr(j) = Ixx;
end

Ixx_lim = (sum(Ixx_arr))*(39.37^4);

% Plotting I beams
% for k = 1:(length(x_ind)-1)
%    xori = x_af(x_ind(k));
%    yori = ls_af(x_ind(k));
%    rectangle('Position',[xori+(0.5*B_arr(k)- 0.5*T1_arr(k)) yori T1_arr(k) A_arr(k)],'FaceColor',[0 .5 .5],'Curvature',0.2);
%    rectangle('Position',[xori yori B_arr(k) T2_arr(k)],'FaceColor',[0 .5 .5],'Curvature',0.2);
%    rectangle('Position',[xori (yori+A_arr(k)-T2_arr(k)) B_arr(k) T2_arr(k)],'FaceColor',[0 .5 .5],'Curvature',0.2);
% end
end

function [Ixx,Iyy] = AMoICalc(A,B,T1,T2)

a = A - (2*T2);
b = B - T1;
Ixx = (B*(A^3)/12) - (b*(a^3)/12);
Iyy = (A*(B^3)/12) - (a*(b^3)/12);

end
