function [Ixx_lim, Area_skin, Area_spars]= App_Wing_MoICalc(ChrdL, Skmax, Spmax,Nspars)
% I beam airfoil grid code

%I beam dimension
T1Brat = 0.00001;     % 30% - Max ratio of T1 and Max value of B
% Skmax = 0.2;     % 10% - Max ratio of T2 and Max value of A

% Importing airfoil
[x_af,us_af,ls_af] = App_airfoil_data();

% Grid Resolution
x_ind = 2:1:200;

Sp1T = Spmax*200;
Sp2T = Spmax*200;
Sp3T = Spmax*200;

x_w1_ori = 60; x_w2_ori = 90; x_w3_ori = 35;

%First Web (at 30% chord)
x_w1_ll = x_w1_ori - (Sp1T/2);x_w1_ul = x_w1_ori + (Sp1T/2);
x_w2_ll = x_w2_ori - (Sp2T/2);x_w2_ul = x_w2_ori + (Sp2T/2);
x_w3_ll = x_w3_ori - (Sp3T/2);x_w3_ul = x_w3_ori + (Sp3T/2);

Area_skin = 0;
Area_spar1 = 0;
Area_spar2 = 0;
Area_spar3 = 0;



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
   Area_skin = Area_skin + 2*B_arr(j)*T2_arr(j)*(ChrdL^2);

   if Nspars == 1
       if (j >= x_w1_ll && j <= x_w1_ul)
        SparH = A_arr(j) - (2*T2_arr(j));
        Ixx = Ixx + (B_arr(j)*(SparH^3)*(ChrdL^4)/12);
        Area_spar1 = Area_spar1 + (B_arr(j)*SparH*(ChrdL^2));
       end
   end
   
   
   if Nspars == 2
       if (j >= x_w1_ll && j <= x_w1_ul || j >= x_w2_ll && j <= x_w2_ul)
           SparH = A_arr(j) - (2*T2_arr(j));
           Ixx = Ixx + (B_arr(j)*(SparH^3)*(ChrdL^4)/12);
       end
       
       if j >= x_w1_ll && j <= x_w1_ul
         Area_spar1 = Area_spar1 + (B_arr(j)*SparH*(ChrdL^2));
       elseif j >= x_w2_ll && j <= x_w2_ul
         Area_spar2 = Area_spar2 + (B_arr(j)*SparH*(ChrdL^2));
       end
   end
   
   if Nspars == 3
       if (j >= x_w1_ll && j <= x_w1_ul || j >= x_w2_ll && j <= x_w2_ul ||...
            j >= x_w3_ll && j <= x_w3_ul)
           SparH = A_arr(j) - (2*T2_arr(j));
           Ixx = Ixx + (B_arr(j)*(SparH^3)*(ChrdL^4)/12);
       end
       
       if j >= x_w1_ll && j <= x_w1_ul
         Area_spar1 = Area_spar1 + (B_arr(j)*SparH*(ChrdL^2));
       elseif j >= x_w2_ll && j <= x_w2_ul
         Area_spar2 = Area_spar2 + (B_arr(j)*SparH*(ChrdL^2));
       elseif j >= x_w3_ll && j <= x_w3_ul
         Area_spar3 = Area_spar3 + (B_arr(j)*SparH*(ChrdL^2));
       end
       
   end
   Ixx_skin_arr(j) = Ixx;
end

Area_spars = Area_spar1 + Area_spar2+ Area_spar3;
Ixx_lim = sum(Ixx_skin_arr)*(39.37^4);

end

function [Ixx,Iyy] = AMoICalc(A,B,T1,T2)

a = A - (2*T2);
b = B - T1;
Ixx = (B*(A^3)/12) - (b*(a^3)/12);
Iyy = (A*(B^3)/12) - (a*(b^3)/12);

end
