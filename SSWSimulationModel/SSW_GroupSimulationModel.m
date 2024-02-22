%% Programa para generar la simulacion del choque y obtener TOF con Poisson y E Dados
clear all;
poils = [0.5];
mody = [100e6, 200e6, 500e6, 1000e6]; %% Rango de mod E para analizar
%mody = [10e6];
v0 = 0.26;
interval = 0.0020;

cont1 = length(mody);
E = 200*10^9; % PA
R = 19.05*10^(-3)/2; % m
v = 0.29;% adimensional Modulo Poison 
Es = 200*10^9; % E del sensor
vs = 0.29;
m = 28.21/1000; % Masa de las esferas
g = 9.81; % Gravedad: m/s^2
ms=29.85/1000; % masa del sensor
masas(1)=m;

% Given data for k interpolation
k_abaqus = [
10000000	1.25356786
40000000	1.097157963
100000000	1.044067032
200000000	1.017856401
300000000	1.007975415
500000000	0.987697925
1000000000  0.98
]; %Corregir K de 1000 e6

for i=1:16
    if i==8
        masas(i+1)=ms+masas(i);
    else
        masas(i+1)=m+masas(i);
    end
end

%%%%%%% Inicio de armar condiones y resolucion iterativa

% Create a cell array to store TOF values for each combination of poi1 and mody
TOF_data = cell(length(poils), cont1);

for k = 1:length(poils)
    disp("Process -> ")
    poil = poils(k);
    
    for j = 1:cont1
        Ew = mody(j);
        vw = poil; % poison de lo que impacta el suelo
        A = E*(2*R)^0.5/(3*(1 - v^2));
        Aw=4*(R)^0.5/3*(((1 - v^2)/E+(1 - vw^2)/Ew)^(-1));
        As = ((4*sqrt(R))/3)*((1 - v^2)/E + (1 - vs^2)/Es)^-1;
        % Interpolate the k factor based on the given Young's modulus
        k_factor = interp1(k_abaqus(:,1), k_abaqus(:,2), Ew, 'linear');
        k_factor
        
        for i=1:17
            if i==8
                d(i)=(masas(i)*g/As)^(2/3);
            elseif i==9
                d(i)=(masas(i)*g/As)^(2/3);
            elseif i==17
                d(i)=(masas(i)*g/Aw)^(2/3);
            else
                d(i)=(masas(i)*g/A)^(2/3); 
            end
        end
        
        % for i=1:17
        %     if i<17
        %     d3(i)=((i)*m*g/A)^(2/3);
        %     else
        %     d3(i)=((i)*m*g/Aw)^(2/3);
        %     end 
        % end
        
        % Se pide al usuario el intervalo en el que se evaluará la función
        Intervalo = [0  interval];
        
        % Se escriben las condiciones de frontera.
        U(1) = 0; % desplazamiento
        U(2) = 0;
        U(3) = 0;
        U(4) = 0;
        U(5) = 0;                      
        U(6) = 0;
        U(7) = 0;
        U(8) = 0;
        U(9) = 0;
        U(10) = 0;
        U(11) = 0;
        U(12) = 0;
        U(13) = 0;
        U(14) = 0;
        U(15) = 0;
        U(16) = 0;
        U(17) = 0;
        U(18) = v0;
        U(19) = 0; % Velocidad
        U(20) = 0;
        U(21) = 0;
        U(22) = 0;
        U(23) = 0;
        U(24) = 0;
        U(25) = 0;
        U(26) = 0;
        U(27) = 0;
        U(28) = 0;
        U(29) = 0;
        U(30) = 0;
        U(31) = 0;
        U(32) = 0;
        U(33) = 0;
        U(34) = 0;
        
        %% Se resuelven las ecuaciones
        options = odeset('RelTol',1e-05,'AbsTol',1e-09);
        
        [t,U] = ode45(@(t,U) ode7(t,U,A,Aw,d,m,g,As,ms,k_factor), Intervalo, U',options);
        
        FA9 = As.*( d(8)- U(:,9) + U(:,8)).^(3/2);
        FA91 = As.*(d(9) - U(:,10) + U(:,9)).^(3/2);
        % Calculation of TOF and storage in cell array
        F1 = real(FA91);
        [pks, locs] = findpeaks(F1, t, 'MinPeakHeight', 40);
        TOF_data{k, j} = locs(2) - locs(1);
        
        % Clear variables for the next iteration
        clearvars -except poil mody cont1 E R v Es vs rho m g ms masas v0 TOF_data poils k k_abaqus interval
    end
end

% Save the TOF data into a file
%save('TOFvsYoungAnalysisWithPlate.mat', 'TOF_data');

