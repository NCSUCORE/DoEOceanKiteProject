function [Pmax,el,thrL] = getPmaxAtDepth(depth,vFlow,Depth,Pavg,elevation,thrLength)

dmin = depth-12.5;  dmax = depth+12.5;
vec1 = squeeze(Depth(:,:,vFlow));  [Ix1,Iy1] = find(vec1 < dmin);  
for j = 1:numel(Ix1)
    Pavg(Ix1(j),Iy1(j),vFlow) = NaN;    Depth(Ix1(j),Iy1(j),vFlow) = NaN;
end
vec2 = squeeze(Depth(:,:,vFlow));  [Ix2,Iy2] = find(vec2 > dmax);
for j = 1:numel(Ix2)
    Pavg(Ix2(j),Iy2(j),vFlow) = NaN;    Depth(Ix2(j),Iy2(j),vFlow) = NaN;
end

Pmax = max(max(Pavg(:,:,vFlow)));
[Ix,Iy] = find(Pavg(:,:,vFlow)==Pmax);
el = elevation(min(Iy));
thrL = thrLength(min(Ix));
end

