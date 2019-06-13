function aero_param = VS_and_HS_design_modified(aero_param,geom_param)

%% calculating Rrud_cm for rudder
x_cm = geom_param.x_cm.Value;

VS_LE = aero_param.VS_LE.Value;
VS_length = aero_param.VS_length.Value;
VS_TR = aero_param.VS_TR.Value;
VS_sweep = aero_param.VS_sweep.Value;
VS_chord = aero_param.VS_chord.Value;

cr_VS = VS_chord;
cr_4 = cr_VS/4;

h_rud = VS_TR*VS_length/2;

c_4_h = (cr_4)*(VS_TR - 1)*(h_rud/VS_length) + cr_4;

Rvs_cmx = c_4_h + VS_LE + VS_length*tand(VS_sweep) - x_cm;
Rvs_cmz = h_rud;

Rvs_cm = [Rvs_cmx;0;Rvs_cmz];

avg_VS_chord = VS_chord*(VS_TR + 1)/2;
VS_Sref = avg_VS_chord*VS_length;

aero_param.Rvs_cm  = simulinkProperty(Rvs_cm);
aero_param.VS_Sref = simulinkProperty(VS_Sref);

end

