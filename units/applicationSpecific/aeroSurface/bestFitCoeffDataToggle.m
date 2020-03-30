useFit = get_param(gcb,'useFit');


maskObj = Simulink.Mask.get(gcb);


switch useFit
    case 'on'
        pObj = maskObj.Parameters(strcmpi({maskObj.Parameters.Name},'clFitLims'));
        pObj.Visible = 'on';
        pObj = maskObj.Parameters(strcmpi({maskObj.Parameters.Name},'clFitOrder'));
        pObj.Visible = 'on';
        pObj = maskObj.Parameters(strcmpi({maskObj.Parameters.Name},'cdFitLims'));
        pObj.Visible = 'on';
        pObj = maskObj.Parameters(strcmpi({maskObj.Parameters.Name},'cdFitOrder'));
        pObj.Visible = 'on';
    case 'off'
        pObj = maskObj.Parameters(strcmpi({maskObj.Parameters.Name},'clFitLims'));
        pObj.Visible = 'off';
        pObj = maskObj.Parameters(strcmpi({maskObj.Parameters.Name},'clFitOrder'));
        pObj.Visible = 'off';
        pObj = maskObj.Parameters(strcmpi({maskObj.Parameters.Name},'cdFitLims'));
        pObj.Visible = 'off';
        pObj = maskObj.Parameters(strcmpi({maskObj.Parameters.Name},'cdFitOrder'));
        pObj.Visible = 'off';
end
