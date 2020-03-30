function mags = vectorListMags(vectorList,dimention)
    %Designed to take in a list of 
    if nargin == 1
       [~,dimention]=min(size(vectorList));
    end
    if dimention == 1
       vectorList=vectorList'; 
    end
    
    runTot=zeros(size(vectorList,1),1);
    for i=1:size(vectorList,2)
        runTot=runTot+vectorList(:,i).^2;
    end
    mags=sqrt(runTot);
    if dimention == 1
       mags=mags';
    end
end