function dynamicFigureLocations()

ss = get(0,'ScreenSize');
ss = [ss(3) ss(4)];

fig_wid = 560;
fig_hgt = 420;

max_horz = floor(ss(1)/fig_wid);
max_vert = floor(ss(2)/fig_hgt);

val = zeros(max_horz*max_vert,4);

kk = 1;
for jj = 1:max_vert
    for ii = 1:max_horz
        val(kk,:) = [(ii-1)*fig_wid  ss(2)-(1.2*fig_hgt*jj) fig_wid fig_hgt ];
        kk = kk+1;
    end
end
val = repmat(val,5,1);

% assign figure location
fig = gcf;
set(fig,'Position',val(fig.Number,:));



end