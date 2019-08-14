% x = 1;
try
    set_param([gcb '/courseFollow/pathGeometry'],'LabelModeActiveChoice',pathCtrl.fcnName.Value)
    set_param([gcb '/courseFollow/For Iterator Subsystem/pathGeometry'] ,'LabelModeActiveChoice',pathCtrl.fcnName.Value)
    set_param([gcb '/courseFollow/For Iterator Subsystem/pathGeometry1'],'LabelModeActiveChoice',pathCtrl.fcnName.Value)
catch
    set_param([gcb '/courseFollow/pathGeometry'],'LabelModeActiveChoice',fltCtrl.fcnName.Value)
    set_param([gcb '/courseFollow/For Iterator Subsystem/pathGeometry'] ,'LabelModeActiveChoice',fltCtrl.fcnName.Value)
    set_param([gcb '/courseFollow/For Iterator Subsystem/pathGeometry1'],'LabelModeActiveChoice',fltCtrl.fcnName.Value)
end
