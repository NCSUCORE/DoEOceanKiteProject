function flowSpeed = vfdInputToFlowSpeed(vfdHz)
%VFDINPUTTOFLOWSPEED Converts the VFD value given in Hertz to flow speed in
%m/s
%   Example: vfdInputToFlowSpeed(10)
flowSpeed = 0.017*vfdHz - 0.00934;

end

