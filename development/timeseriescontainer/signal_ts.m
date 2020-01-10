% Example script to test and demonstrate the signal class

%% First create a scalar signal object 
sScalar = signal(rand(100,1),linspace(0,1,100),'Name','newSig');

% Then plot it
sScalar.plot

% Or plot it with all the normal options
sScalar.plot('Color','k','LineWidth',2,'DisplayName','Custom Signal')
legend

%% Now, create a vector-valued signal, 3 by 1 
sVec = signal(rand(3,1,100),linspace(0,1,100),'Name','newSig');

% Now plot it with some options
sVec.plot('LineWidth',1.5,'LineStyle',':')

%% Now, create a matrix-valued signal, 3 by 2
sMat = signal(rand(3,2,100),linspace(0,1,100),'Name','newSig');

% Now plot it with some options
sMat.plot('LineWidth',1.5,'LineStyle','--')

%% Now, crop the matrix valued signal using a GUI (click start and end times on the plot)
sMat = sMat.guicrop;

% Plot the new, cropped data
sMat.plot


