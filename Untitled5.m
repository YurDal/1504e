t=[1:450]
 aa = zeros(1,450);
% s = 449;
% A = zeros(449, 2);
% R = zeros(1, 2);
% for k = 2:450
%     y(s) = yf1(k);
%     A(k-1, 1) = yf1(s);
%     A(k-1, 2) = 50;
%     s = s - 1;
% end
% Y=y';
% R = A\Y;
% a=R(1,1)
% b=R(2,1)
% 
% G1=tf([b],[1 -a],1)
% step(G2,450)
for k=1:450
    aa(k)= sim1(k+1,1);
end
plot (t,aa)
hold on
plot (t,1/50*y1)
xlabel('samples k')
ylabel('Amplitut')
title('Sammansatta graf - �vre vattentank')
legend('Simulation', 'M�tv�rde');

















% % Uppskattning av stigtid tr (tiden det tar f�r signalen att stiga fr�n 10% av b�rv�rden till 90%)
% b = 140;
% dT = 0.8;
% t=0;
% vv=0;
% % newy2 = zeros(1, 250)
% % for k = 250:500
% %     newy2(k) = y2(k);
% %     k = k + 1;
% % end
% % s= find((newy2>=b*0.1) & (newy2<=b*0.9)); %samplingar n�r h2 �r mellan 10% och 90%
% % tr =(max(s)-min(s)) % stigtid i sekunder
% %
% % max(y2)-b %om det �r negativ s� finns ingen �versv�ngning
% % it= min( find((newy2>=b*0.95) & (newy2<=b*1.05) ))
%
% b-mean(y2(length(y1)-15:length(y2)))
%
% % for j=1:500
% %     vv(j)=140;
% %     t(j)=j;
% % end
% % plot(t,y2,'k',t,u,'m', t, vv,'r--', t, e, 'b:');
% % xlabel('samples k')
% % ylabel('y, u')
% % title('PID-reglering-AS')
% % legend('Nedre tank', 'Styrsignal','B�rv�rde', 'felsignal');