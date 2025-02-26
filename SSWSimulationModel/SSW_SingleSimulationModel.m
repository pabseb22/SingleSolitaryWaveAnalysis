clear all;
%% Programa para generar la simulacion del choque y obtener TOF con Poisson y E Dados y guardar datos
poi1 = 0.3; %% Modulo de Poisson a analizar en el rango de E

mody = [16e6]; %% Pa
%mody = [16e6, 38e6, 58e6, 81e6, 123e6, 210e6, 445e6]; %% Pa

% Se pide al usuario el intervalo en el que se evaluará la función
Intervalo = [0  0.0026];

v0 = 0.26; %%Velocidad sin Placa 0.26


% Given data for k interpolation
k_abaqus = [
10000000	1.32597368
40000000	1.15310178
100000000	1.08218132
200000000	1.053948882
300000000	1.04348296
500000000	1.035025573
700000000	1.030619376
1000000000	1.02452853
];

cont1= length(mody); 

E = 200*10^9; % PA
R = 19.05*10^(-3)/2; % m
v = 0.29;% adimensional Modulo Poison 
Es = 200*10^9; % E del sensor
vs = 0.29;
m = 28.21/1000; % Masa de las esferas
g = 9.81; % Gravedad: m/s^2
ms=29.85/1000; % masa del sensor
masas(1)=m;


for i=1:16
    if i==8
        masas(i+1)=ms+masas(i);
    else
        masas(i+1)=m+masas(i);
    end
end

%%%%%%% Inicio de armar condiones y resolucion iterativa
folderName = 'Numerical_Saw_Bones_Data';

all_k_factors = {};
all_TOF = {};

for j=1:cont1

filename = sprintf('PCF_%.2f_num_data_poi%.2f_v0%.2f.mat', mody(j)/1e6, poi1,v0);

Ew = mody(j); % PA modulo sobre el que impactan las esferas
vw = poi1; % poison de lo que impacta el suelo

% Interpolate the k factor based on the given Young's modulus
k_factor = interp1(k_abaqus(:,1), k_abaqus(:,2), Ew, 'linear');

A = E*(2*R)^0.5/(3*(1 - v^2)); % Ecuacion de contacto entre esferas
Aw=4*(R)^0.5/3*(((1 - v^2)/E+(1 - vw^2)/Ew)^(-1)); % Ecuacion de contacto entre esfera y muestra
As = ((4*sqrt(R))/3)*((1 - v^2)/E + (1 - vs^2)/Es)^-1; %Ecuacion de Contacto Sensor y Esfera: Cilindro

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

figure
plot(t, FA91)
filePath = fullfile(folderName, filename);
%saveData
save(filePath, "FA91","t")
F1 = real(FA91);
[pks,locs] = findpeaks(F1,t, 'MinPeakHeight' , 40);
TOFM(j) = locs(2) - locs(1);
% Print TOF and k_factor values for each iteration
fprintf('Iteration %d: TOF = %.10f, k_factor = %.10f\n', j, TOFM(j), k_factor);
all_k_factors = [all_k_factors; k_factor];
all_TOF = [all_TOF; TOFM(j)];
clearvars -except poi1 cont1 mody E R v Es vs rho m g ms masas TOFM v0 k_abaqus Intervalo folderName all_k_factors all_TOF
end

all_k_factors
all_TOF

