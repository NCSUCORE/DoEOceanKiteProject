function newobj = guicrop(obj)
%% Function to crop a timesignal based on user input from a GUI
newobj = timesignal(obj);
hFig = newobj.plot;
[x,~] = ginput(2);
close(hFig);
newobj = newobj.crop(min(x),max(x));
end
