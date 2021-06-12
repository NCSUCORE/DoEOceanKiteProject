function cropImages(varargin)


if ~isempty(varargin)
    folderPath = varargin{1};
else
    fprintf('\nPlease select the directory containing your images.\n')
    folderPath = uigetdir();
end

imageFileExtensions = {'png','jpg','jpeg'};
files =  dir(fullfile(folderPath,filesep,sprintf('*.%s',imageFileExtensions{1})));

for ii = 2:length(imageFileExtensions)
    files = [files; dir(fullfile(folderPath,filesep,sprintf('*.%s',imageFileExtensions{ii})))];
end

for ii = 1:length(files)
    imgProps = imfinfo(fullfile(files(ii).folder,filesep,files(ii).name));
    
    if strcmpi(imgProps.ColorType,'indexed')
        % Find the row of the colormap that contains all values equal to
        % the max value, subtract 1 to account for zero indexing
        whiteVal = find(sum(imgProps.Colormap==1,2)==max(imgProps.Colormap(:))*size(imgProps.Colormap==1,2))-1;
    else
        whiteVal = 255;
    end
    
    img = imread(fullfile(files(ii).folder,filesep,files(ii).name));
    
    if size(img,3) == 1
        imgFlat = img(:,:)~=whiteVal ;
    else
        imgFlat = img(:,:,1)~=whiteVal | img(:,:,2)~=whiteVal | img(:,:,3)~=whiteVal;
    end
    
    xLims = find(sum(imgFlat,1));
    xLims = [max([xLims(1)-1,1]) min([xLims(end)+1 size(imgFlat,2)])];
    yLims = find(sum(imgFlat,2));
    yLims = [max([yLims(1)-1,1]) min([yLims(end)+1 size(imgFlat,1)])];
    imCrop = imcrop(img,[xLims(1) yLims(1) xLims(2)-xLims(1) yLims(2)-yLims(1)]);
    
    if isfield(imgProps,'Colormap') && ~isempty(imgProps.Colormap)
        imwrite(imCrop,imgProps.Colormap,fullfile(files(ii).folder,filesep,files(ii).name))
    else
        imwrite(imCrop,fullfile(files(ii).folder,filesep,files(ii).name))
    end
    
end