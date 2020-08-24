
function updateSliderNumLabels(app,event,varind,varNames,T)
    
    app.Labels.(varNames{varind}).Text = num2str(event.Value);
    refreshdata(uilabel(app.UITabs.(T)))
    
end


