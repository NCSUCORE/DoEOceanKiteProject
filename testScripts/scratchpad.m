clear
LUT = Simulink.LookupTable;
timeVec = linspace(0,1);
LUT.Table.Value = rand(2,2,numel(timeVec));
LUT.Breakpoints(1).Value = 0:1;
LUT.Breakpoints(2).Value = 0:1;
LUT.Breakpoints(3).Value = timeVec;
LUT.StructTypeInfo.Name = 'LUT';
