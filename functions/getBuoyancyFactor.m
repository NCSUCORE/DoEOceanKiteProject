function BF = getBuoyancyFactor(vhcl,env,thr)
Vk = vhcl.volume.Value;
try
    Vthr = thr.tether1.diameter.Value^2*pi/4*400;
    Gthr = env.gravAccel.Value*Vthr*thr.tether1.density.Value;
catch
    Vthr = thr.diameter.Value^2*pi/4*400;
    Gthr = env.gravAccel.Value*Vthr*thr.density.Value;
end
Bthr = env.gravAccel.Value*Vthr*env.water.density.Value;
Bk = env.gravAccel.Value*Vk*env.water.density.Value;
BF = env.gravAccel.Value*Vk*env.water.density.Value/(Bk+Bthr-Gthr);
end

