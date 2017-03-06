function [e, u, y1, y2, t]=Stegsvar(a, N, Ts, v)
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

u=zeros(1, N);
y1=zeros(1, N);
y2=zeros(1, N);

t=zeros(1,N);
start=0; elapsed=0; ok=0; % används för att upptäcka för korta samplingstider
k=0; % samplingsindex


% Konfigurering av in- och utgångar -----------------------------------------------------
% Arduino ingångar
% analoga ingångar ’A0’ och ’A1’ behöver inte konfigureras. 0..1023
% ’A0’: y
% analoga utgångar behöver inte heller konfigureras. DAC1-> PWM, DAC0 -> DAC,
% 0..255
% ’DAC0’: u
analogRead(a, 'A0');
analogRead(a, 'A1');
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
    y1(k)= analogRead(a, 'A0') -25; % mät ärvärdet
    y2(k)= analogRead(a, 'A1') - 20; % mät ärvärdet
    
    % beräkna felvärdet som skillnad mellan ärvärdet och börvärdet
    e(k)=v-y1(k);
    
    % Regulatorblock
    % beräkna styrvärdet, t.ex p-regulator med förstärkning Kp=1
  
    % begränsa styrvärdet till lämpliga värden, vattenmodellen t.ex. u >=0 och u <255, samt
    %      heltal
     u(k)= 50;
  
    % skriva ut styrvärdet
    analogWrite(a, u(k), 'DAC0'); %DAC-utgång
    %online-plot
    plot(t,y1,'k',t,y2,'y',t,u,'m',t,e,'b:');
    elapsed=cputime-start; % räknar åtgången tid i sekunder
    ok=(Ts-elapsed); % sparar tidsmarginalen i ok
    
    pause(ok); %pausar resterande samplingstid
end % slut av samplingarna ----------------------------------------------------------------------

% plotta en fin slutbild,
windowSize = 5;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
yf1 = filter(b,a,y1);
yf2 = filter(b,a,y2);

plot(t,y1,'k',t,y2,'y',t,u,'m',t,e,'b:');
xlabel('samples k')
ylabel('y, u')
title('PID-reglering')
legend('Övre tank','Nedre tank', 'Styrsignal', 'Fel-signal');

savefile=('stegsvar.mat')
save(savefile,'y1', 'y2', 'yf1', 'yf2')
% -------------------------------------------------------------------------------------------

