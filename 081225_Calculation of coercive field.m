e0=8.8541878176E-12;    %真空中介電常數(F/m)   (C^2/N/m^2)
e33=43.5*e0;            %LT沿Z軸
Ps=0.55;                %(C/m^2)
a1=1/(2*e33);
a2=a1/Ps^2;
P=-1:0.01:1;
G=-a1/2*P.^2+a2/4*P.^4;
E=-a1*P+a2*P.^3;
deltaE=-a1+3*a2*P.^2;
plot(P,deltaE,P,E,P,10*G);