function J = wingVolumeCost(u,Lscale)

Span = u(2)*Lscale; 
J = Span^3/u(1)^2 ;

end 