function aeroTable = loadAeroTable(fileName,clFitLimits,clFitOrder,...
    cdFitLimits,cdFitOrder,OE,AR,useFit)

% Build full path to the library of aero files
basePath = fullfile(fileparts(which('aeroSurface_ul.slx'))); % Find location of unit library
files = dir(basePath); % Get directories within that directory
files = files(3:end);
files = files([files.isdir] == 1);
% find the one with "lib" in the name
files = files(contains({files.name},'Lib','IgnoreCase',true));

% Path to the library
basePath = fullfile(files.folder,files.name);
fileName = fullfile(basePath,fileName);

% Read in raw data
aeroTableRaw = readRawAeroData(fileName);

% Find Reynolds number
[row,col] = find(strcmpi(aeroTableRaw,'re'));
aeroTable.Re = aeroTableRaw{row,col+2}*10^aeroTableRaw{row,col+4};

% Find airfoil name
[row,col] = find(strcmpi(aeroTableRaw,'for:'));
aeroTable.foilName = [aeroTableRaw{row,col+1} num2str(aeroTableRaw{row,col+2})];

% Store filename
[~,aeroTable.fileName] = fileparts(fileName);

% Find vector of angles of attack
[row,col] = find(strcmpi(aeroTableRaw,'alpha'));
aeroTable.alpha = [aeroTableRaw{row+2:end,col}]*(pi/180);

% Find vector of lift coefficients
[row,col] = find(strcmpi(aeroTableRaw,'cl'));
aeroTable.cl    = [aeroTableRaw{row+2:end,col}];

% Prandtl lifting line lift coefficient correction
aeroTable.cl = aeroTable.cl/(1+1/AR);

% find drag coefficients
[row,col] = find(strcmpi(aeroTableRaw,'cd'));
aeroTable.cdUncorrected    = [aeroTableRaw{row+2:end,col}];

% Lift coefficient at minimum drag
aeroTable.cl0   = aeroTable.cl(aeroTable.cdUncorrected == min(aeroTable.cdUncorrected));

% Drag Correction(s)
aeroTable.cd            = min(aeroTable.cdUncorrected)+((aeroTable.cl-aeroTable.cl0(1)).^2)./(pi*OE*AR);
aeroTable.cdPrandtl1    = aeroTable.cdUncorrected     +((aeroTable.cl.^2)/(pi*AR))*((AR+1)/(AR+2)).^2;
aeroTable.cdPrandtl2    = min(aeroTable.cdUncorrected)+((4*pi*aeroTable.alpha.^2)/(AR))*((1)/(1+2/AR))^2;
aeroTable.cdPrandtl3    = aeroTable.cdUncorrected     +((4*pi*aeroTable.alpha.^2)/(AR))*((1)/(1+2/AR))^2;
aeroTable.cdPrandtl4    = aeroTable.cdUncorrected     +((aeroTable.cl.^2)/(AR))*((1)/(1+2/AR))^2;

clStartAlpha    = min([clFitLimits(1) aeroTable.alpha]);
clEndAlpha      = max([clFitLimits(2) aeroTable.alpha]);
cdStartAlpha    = min([cdFitLimits(1) aeroTable.alpha]);
cdEndAlpha      = max([cdFitLimits(2) aeroTable.alpha]);

% Crop data to range specified by used
idx = 1:length(aeroTable.alpha);
alphaClCrop = aeroTable.alpha(idx(abs(clStartAlpha-aeroTable.alpha)==min(abs(clStartAlpha-aeroTable.alpha))):...
    idx(abs(clEndAlpha-aeroTable.alpha)==min(abs(clEndAlpha-aeroTable.alpha))));
clCrop      = aeroTable.cl(idx(abs(clStartAlpha-aeroTable.alpha)==min(abs(clStartAlpha-aeroTable.alpha))):...
    idx(abs(clEndAlpha-aeroTable.alpha)==min(abs(clEndAlpha-aeroTable.alpha))));
alphaCdCrop = aeroTable.alpha(idx(abs(cdStartAlpha-aeroTable.alpha)==min(abs(cdStartAlpha-aeroTable.alpha))):...
    idx(abs(cdEndAlpha-aeroTable.alpha)==min(abs(cdEndAlpha-aeroTable.alpha))));
cdCrop      = aeroTable.cd(idx(abs(cdStartAlpha-aeroTable.alpha)==min(abs(cdStartAlpha-aeroTable.alpha))):...
    idx(abs(cdEndAlpha-aeroTable.alpha)==min(abs(cdEndAlpha-aeroTable.alpha))));

% Do the polyfits
aeroTable.clPoly = polyfit(alphaClCrop,clCrop,clFitOrder);
aeroTable.cdPoly = polyfit(alphaCdCrop,cdCrop,cdFitOrder);

if useFit
    % Evaluatae the polynomial at the specified range of alpha
    aeroTable.clFit = polyval(aeroTable.clPoly,aeroTable.alpha);
    aeroTable.cdFit = polyval(aeroTable.cdPoly,aeroTable.alpha);
    aeroTable.cl = aeroTable.clFit;
    aeroTable.cd = aeroTable.cdFit;
end

% Append data to the start and end of cl and cd so that lookup tables work
% properly (zero lift, max drag if alpha runs off end).
aeroTable.alpha(end+1) = aeroTable.alpha(end) + (aeroTable.alpha(end)-aeroTable.alpha(end-1));
aeroTable.alpha = [aeroTable.alpha(1)-(aeroTable.alpha(2)-aeroTable.alpha(1)) aeroTable.alpha];

aeroTable.cd(end+1) = aeroTable.cd(end);
aeroTable.cd = [aeroTable.cd(1) aeroTable.cd];

aeroTable.cl(end+1) = 0;
aeroTable.cl = [0 aeroTable.cl];

aeroTable.clStartAlpha  = clStartAlpha;
aeroTable.clEndAlpha    = clEndAlpha;
aeroTable.cdStartAlpha  = cdStartAlpha;
aeroTable.cdEndAlpha    = cdEndAlpha;

end