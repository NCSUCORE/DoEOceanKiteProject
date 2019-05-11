function aero_param = VS_and_HS_design(aero_param,geom_param)

%% calculating Rrud_cm for rudder
x_cm = geom_param.x_cm;

VS_LE = aero_param.VS_LE;
VS_length = aero_param.VS_length;
VS_TR = aero_param.VS_TR;
VS_sweep = aero_param.VS_sweep;
VS_chord = aero_param.VS_chord;

cr_VS = VS_chord;
cr_4 = cr_VS/4;

h_rud = VS_TR*VS_length/2;

c_4_h = (cr_4)*(VS_TR - 1)*(h_rud/VS_length) + cr_4;

Rvs_cmx = c_4_h + VS_LE + VS_length*tand(VS_sweep) - x_cm;
Rvs_cmz = h_rud;

Rvs_cm = [Rvs_cmx;0;Rvs_cmz];

avg_VS_chord = VS_chord*(VS_TR + 1)/2;
VS_Sref = avg_VS_chord*VS_length;

aero_param.Rvs_cm = Rvs_cm;
aero_param.VS_Sref = VS_Sref;

end

