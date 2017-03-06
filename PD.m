function [e, u, y1, y2, t]=PD(a, N, Ts, v)
% Stomme f�r regulator-block. Kan anv�ndas f�r att l�gga till och anpassa till olika
% klassiska, tidsdiskreta regulatorer
% Argument (anpassas efter �ndam�l)
% a: arduino-objektet som Matlab anv�nder f�r att kommunicera med Arduino
% N: antal samplingar
% Ts: samplingstiden mellan samplingar
% v: b�rv�rde i digitala enheter (0..1023)

% Resultat (anpassas efter �ndam�l)
% e: vektor med N m�tningar av felsignalen
% u: vektor med N m�tningar av styrsignalen
% y1, y2: vektor med N m�tningar av process-svaren == �rv�rden
% t: tidsdiskret tidsvektor 1:N

% Initialisering av variablerna ---------------------------------------------------------------
e=zeros(1, N);
vv=zeros(1, N);
u=zeros(1, N);
y1=zeros(1, N);
y2=zeros(1, N);
t=zeros(1,N);
start=0; elapsed=0; ok=0; % anv�nds f�r att uppt�cka f�r korta samplingstider
k=0; % samplingsindex
for j=1:N
    vv(j)=v;
end

% Konfigurering av in- och utg�ngar -----------------------------------------------------
% Arduino ing�ngar
% analoga ing�ngar �A0� och �A1� beh�ver inte konfigureras. 0..1023
% �A0�: y
% analoga utg�ngar beh�ver inte heller konfigureras. DAC1-> PWM, DAC0 -> DAC,
% 0..255
% �DAC0�: u
analogRead(a, 'A0');
analogRead(a, 'A1');
% cyklisk exekvering av samplingar
for k=1:N % slinga kommer att k�ras N-g�ngar, varje g�ng tar exakt Ts-sekunder
    start = cputime; %startar en timer f�r att kunna m�ta tiden f�r en loop
    if ok <0 % testar om samplingen �r f�r kort
        k;
        disp('samplingstiden �r f�r lite! �k v�rdet f�r Ts');
        return
    end
    % uppdatera tidsvektorn
    t(k)=k;
    
    % l�s ing�ngsv�rde sensorv�rden
    y1(k)= analogRead(a, 'A0'); % m�t �rv�rdet
    y2(k)= analogRead(a, 'A1'); % m�t �rv�rdet
    
    % ber�kna felv�rdet som skillnad mellan �rv�rdet och b�rv�rdet
    e(k)=v-y1(k);
    
    % Regulatorblock
    % ber�kna styrv�rdet, t.ex p-regulator med f�rst�rkning Kp=1
    if(k==1)
        u(k)= 1*(e(k)+(1/Ts)*e(k));
    else
        
        u(k)= 1*(e(k)+(1/Ts)*(e(k)-e(k-1))); % PID-regulator, Kp=1, Td=1, Ti=100, Ts=0.8s
    end
    % begr�nsa styrv�rdet till l�mpliga v�rden, vattenmodellen t.ex. u >=0 och u <255, samt
    %      heltal
    if u(k)> 255
        u(k)=255;
    end
    if u(k) < 0
        u(k) = 0;
    end
    % skriva ut styrv�rdet
    analogWrite(a, u(k), 'DAC0'); %DAC-utg�ng
    %online-plot
    plot(t,y1,'k',t,y2,'y',t,u,'m',t,e,'b:');
    elapsed=cputime-start; % r�knar �tg�ngen tid i sekunder
    ok=(Ts-elapsed); % sparar tidsmarginalen i ok
    
    pause(ok); %pausar resterande samplingstid
end % slut av samplingarna ----------------------------------------------------------------------

% plotta en fin slutbild,
plot(t,y1,'k',t,y2,'y',t,u,'m',t,e,'b:');
hold on
plot(t,vv,'r--')
xlabel('samples k')
ylabel('y, u')
title('PD-reglering')
legend('�vre tank','Nedre tank', 'Styrsignal', 'Fel-signal','B�rv�rde');
savefile=('PD.mat')
save(savefile,'y1', 'y2', 'e', 'u')
% -------------------------------------------------------------------------------------------

