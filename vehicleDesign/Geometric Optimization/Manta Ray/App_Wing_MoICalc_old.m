function [Ixx_lim, Area_skin, Area_spar1,Area_spar2]= App_Wing_MoICalc_old(ChrdL, Skmax, Sp1max, Sp2max, Sp3max)
% I beam airfoil grid code

%I beam dimension
T1Brat = 0.00001;     % 30% - Max ratio of T1 and Max value of B
% Skmax = 0.2;     % 10% - Max ratio of T2 and Max value of A

% Importing airfoil
[x_af,us_af,ls_af] = App_airfoil_data();

% Grid Resolution
x_ind = 2:1:200;

Sp1T = Sp1max*200;
Sp2T = Sp2max*200;
% Sp3T = Sp3max*200;

x_w1_ori = 50; 
x_w2_ori = 140; 
% x_w3_ori = 35;

%First Web (at 30% chord)
x_w1_ll = x_w1_ori - (Sp1T/2);x_w1_ul = x_w1_ori + (Sp1T/2);
x_w2_ll = x_w2_ori - (Sp2T/2);x_w2_ul = x_w2_ori + (Sp2T/2);
% x_w3_ll = x_w3_ori - (Sp3T/2);x_w3_ul = x_w3_ori + (Sp3T/2);

Area_skin = 0;
Area_spar1 = 0;
Area_spar2 = 0;
% Area_spar3 = 0;

% Creating airfoil skin calculating Ixx skin
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
   T2_arr(j) = A_arr(j)*Skmax;
   
   [Ixx,Iyy] = AMoICalc(A_arr(j)*ChrdL,B_arr(j)*ChrdL,T1_arr(j)*ChrdL,...
       T2_arr(j)*ChrdL);
   Area = 2*B_arr(j)*T2_arr(j)*(ChrdL^2);
   if (j >= x_w1_ll && j <= x_w1_ul || j >= x_w2_ll && j <= x_w2_ul) %|| j >= x_w3_ll && j <= x_w3_ul)
       SparH = A_arr(j) - (2*T2_arr(j));
       Ixx = Ixx + (B_arr(j)*(SparH^3)*(ChrdL^4)/12);
       Area = Area + (B_arr(j)*SparH*(ChrdL^2));
   end
   
   Ixx_skin_arr(j) = Ixx;

   if j >= x_w1_ll && j <= x_w1_ul
       Area_spar1 = Area_spar1 + Area;
   elseif j >= x_w2_ll && j <= x_w2_ul
       Area_spar2 = Area_spar2 + Area;
%    elseif j >= x_w3_ll && j <= x_w3_ul
%        Area_spar3 = Area_spar3 + Area;
   else
       Area_skin = Area_skin + Area;
   end
end



Ixx_lim = sum(Ixx_skin_arr);

% Plotting I beams
figure;
for k = 1:(length(x_ind)-1)
   xori = x_af(x_ind(k));
   yori = ls_af(x_ind(k));
   
   
%    if (k >= x_w1_ll && k <= x_w1_ul) 
%    if (k >= x_w1_ll && k <= x_w1_ul || k >= x_w2_ll && k <= x_w2_ul)
   if (k >= x_w1_ll && k <= x_w1_ul || k >= x_w2_ll && k <= x_w2_ul) %|| k >= x_w3_ll && k <= x_w3_ul)
       rectangle('Position',[xori yori B_arr(k) A_arr(k)],'FaceColor',[0 .5 .5],'Curvature',0.2);
   else
       %    rectangle('Position',[xori+(0.5*B_arr(k)- 0.5*T1_arr(k)) yori T1_arr(k) A_arr(k)],'FaceColor',[0 .5 .5],'Curvature',0.2);
       rectangle('Position',[xori yori B_arr(k) T2_arr(k)],'FaceColor',[0 .5 .5],'Curvature',0.2);
       rectangle('Position',[xori (yori+A_arr(k)-T2_arr(k)) B_arr(k) T2_arr(k)],'FaceColor',[0 .5 .5],'Curvature',0.2);
    
   end

end
ylim([-.5 0.5])
end

function [Ixx,Iyy] = AMoICalc(A,B,T1,T2)

a = A - (2*T2);
b = B - T1;
Ixx = (B*(A^3)/12) - (b*(a^3)/12);
Iyy = (A*(B^3)/12) - (a*(b^3)/12);

end
