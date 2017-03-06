function [e, u, y1, y2, t]=PD(a, N, Ts, v)
% Stomme för regulator-block. Kan användas för att lägga till och anpassa till olika
% klassiska, tidsdiskreta regulatorer
% Argument (anpassas efter ändamål)
% a: arduino-objektet som Matlab använder för att kommunicera med Arduino
% N: antal samplingar
% Ts: samplingstiden mellan samplingar
% v: börvärde i digitala enheter (0..1023)

% Resultat (anpassas efter ändamål)
% e: vektor med N mätningar av felsignalen
% u: vektor med N mätningar av styrsignalen
% y1, y2: vektor med N mätningar av process-svaren == ärvärden
% t: tidsdiskret tidsvektor 1:N

% Initialisering av variablerna ---------------------------------------------------------------
e=zeros(1, N);
vv=zeros(1, N);
u=zeros(1, N);
y1=zeros(1, N);
y2=zeros(1, N);
t=zeros(1,N);
start=0; elapsed=0; ok=0; % används för att upptäcka för korta samplingstider
k=0; % samplingsindex
for j=1:N
    vv(j)=v;
end

% Konfigurering av in- och utgångar -----------------------------------------------------
% Arduino ingångar
% analoga ingångar ’A0’ och ’A1’ behöver inte konfigureras. 0..1023
% ’A0’: y
% analoga utgångar behöver inte heller konfigureras. DAC1-> PWM, DAC0 -> DAC,
% 0..255
% ’DAC0’: u
analogRead(a, 'A0');
analogRead(a, 'A1');
% cyklisk exekvering av samplingar
for k=1:N % slinga kommer att köras N-gångar, varje gång tar exakt Ts-sekunder
    start = cputime; %startar en timer för att kunna mäta tiden för en loop
    if ok <0 % testar om samplingen är för kort
        k;
        disp('samplingstiden är för lite! Ök värdet för Ts');
        return
    end
    % uppdatera tidsvektorn
    t(k)=k;
    
    % läs ingångsvärde sensorvärden
    y1(k)= analogRead(a, 'A0'); % mät ärvärdet
    y2(k)= analogRead(a, 'A1'); % mät ärvärdet
    
    % beräkna felvärdet som skillnad mellan ärvärdet och börvärdet
    e(k)=v-y1(k);
    
    % Regulatorblock
    % beräkna styrvärdet, t.ex p-regulator med förstärkning Kp=1
    if(k==1)
        u(k)= 1*(e(k)+(1/Ts)*e(k));
    else
        
        u(k)= 1*(e(k)+(1/Ts)*(e(k)-e(k-1))); % PID-regulator, Kp=1, Td=1, Ti=100, Ts=0.8s
    end
    % begränsa styrvärdet till lämpliga värden, vattenmodellen t.ex. u >=0 och u <255, samt
    %      heltal
    if u(k)> 255
        u(k)=255;
    end
    if u(k) < 0
        u(k) = 0;
    end
    % skriva ut styrvärdet
    analogWrite(a, u(k), 'DAC0'); %DAC-utgång
    %online-plot
    plot(t,y1,'k',t,y2,'y',t,u,'m',t,e,'b:');
    elapsed=cputime-start; % räknar åtgången tid i sekunder
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
legend('Övre tank','Nedre tank', 'Styrsignal', 'Fel-signal','Börvärde');
savefile=('PD.mat')
save(savefile,'y1', 'y2', 'e', 'u')
% -------------------------------------------------------------------------------------------

