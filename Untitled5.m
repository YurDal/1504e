% Uppskattning av stigtid tr (tiden det tar f�r signalen att stiga fr�n 10% av b�rv�rden till 90%)
b = 140;
dT = 0.8;
t=0;
vv=0;
% newy2 = zeros(1, 250)
% for k = 250:500
%     newy2(k) = y2(k);
%     k = k + 1;
% end
% s= find((newy2>=b*0.1) & (newy2<=b*0.9)); %samplingar n�r h2 �r mellan 10% och 90%
% tr =(max(s)-min(s)) % stigtid i sekunder
% 
% max(y2)-b %om det �r negativ s� finns ingen �versv�ngning
% it= min( find((newy2>=b*0.95) & (newy2<=b*1.05) ))



for j=1:500
    vv(j)=140;
    t(j)=j;
end
plot(t,y2,'k',t,u,'m', t, vv,'r--', t, e, 'b:');
xlabel('samples k')
ylabel('y, u')
title('PID-reglering-AS')
legend('Nedre tank', 'Styrsignal','B�rv�rde', 'felsignal');