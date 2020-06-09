function newObj = guicrop(obj,sigName)
%% Crop signals based on user input in GUI

newObj = signalcontainer(obj);
hFig = newObj.(sigName).plot;
[x,~] = ginput(2);
close(hFig);
newObj = newObj.crop(min(x),max(x));
end