clear; clc; close all;

%% --- Parameters ---
poi1 = 0.1;                     % Poisson's ratio of sample
mody = [0.1e6, 0.5e6, 1e6, 4e6, 7e6, 10e6];   % Young's modulus (Pa)
v0 = 0.26;                      % Initial velocity (m/s)

%% --- Abaqus data (not used for scaling now) ---
k_abaqus = [
    1000000    1.746240578
    5000000    1.333728932
    10000000   1.32597368
    40000000   1.15310178
    100000000  1.08218132
    200000000  1.053948882
    300000000  1.04348296
    500000000  1.035025573
    700000000  1.030619376
    1000000000 1.02452853
];

%% --- System properties ---
E  = 200e9;             % Pa
R  = 19.05e-3 / 2;      % m
v  = 0.29;              % Poisson’s ratio
Es = 200e9;             % Sensor’s Young modulus (Pa)
vs = 0.29;              % Poisson’s ratio sensor
m  = 28.21 / 1000;      % Mass of spheres (kg)
ms = 29.85 / 1000;      % Sensor mass (kg)
g  = 9.81;              % Gravity (m/s^2)
cont1 = length(mody);

%% --- Mass distribution ---
masas = zeros(1,17);
masas(1) = m;
for i = 1:16
    if i == 8
        masas(i+1) = ms + masas(i);
    else
        masas(i+1) = m + masas(i);
    end
end

%% --- Preallocate storage ---
TOFM = zeros(1, cont1);
all_k_factors = zeros(1, cont1);
convergence_flags = zeros(1, cont1);

%% --- Solver options ---
options = odeset('RelTol',1e-6,'AbsTol',1e-10);

%% --- Simulation interval setup ---
base_interval = [0, 0.002];     % Start interval (seconds)
interval_increment = 0.0002;    % Increment step (seconds)
max_attempts = 15;              % Max attempts per case

%% --- Main loop ---
for j = 1:cont1
    Ew = mody(j);
    vw = poi1;

    % k_factor constant
    k_factor = 1;
    all_k_factors(j) = k_factor;

    % --- Compute contact parameters ---
    A  = E*(2*R)^0.5 / (3*(1 - v^2));
    Aw = 4*(R)^0.5/3 * (((1 - v^2)/E + (1 - vw^2)/Ew)^(-1));
    As = (4*sqrt(R)/3) * ((1 - v^2)/E + (1 - vs^2)/Es)^(-1);

    % --- Deformations ---
    d = zeros(1,17);
    for i = 1:17
        if i == 8 || i == 9
            d(i) = (masas(i)*g/As)^(2/3);
        elseif i == 17
            d(i) = (masas(i)*g/Aw)^(2/3);
        else
            d(i) = (masas(i)*g/A)^(2/3);
        end
    end

    % --- Initial Conditions ---
    U0 = zeros(34,1);
    U0(18) = v0; % initial velocity of first sphere

    %% --- Fixed increment interval logic ---
    Intervalo = base_interval;
    converged = false;

    for attempt = 1:max_attempts
        [t, U] = ode45(@(t,U) ode7(t,U,A,Aw,d,m,g,As,ms,k_factor), Intervalo, U0, options);

        % --- Force calculation ---
        FA9  = As.*(d(8) - U(:,9) + U(:,8)).^(3/2);
        FA91 = As.*(d(9) - U(:,10) + U(:,9)).^(3/2);
        F1   = real(FA91);

        % --- Detect peaks ---
        [pks, locs] = findpeaks(F1, t, 'MinPeakHeight', 40);

        if numel(locs) >= 2
            TOFM(j) = locs(2) - locs(1);
            converged = true;
            fprintf('✓ Converged for E = %.2e Pa | Attempt %d | TOF = %.4f s | Interval %.6e s\n', ...
                Ew, attempt, TOFM(j), Intervalo(2));
            break;
        else
            % Extend interval
            Intervalo(2) = Intervalo(2) + interval_increment;
            fprintf('→ Extending interval for E = %.2e Pa (Attempt %d) → %.6e s\n', ...
                Ew, attempt+1, Intervalo(2));
        end
    end

    if ~converged
        TOFM(j) = NaN;
        warning('✗ Failed to converge for E = %.2e Pa after %d attempts.', Ew, max_attempts);
    end

    convergence_flags(j) = converged;
    fprintf('Progress: %.1f%% completed.\n', 100*j/cont1);
end

%% --- Display summary ---
results = table(mody(:), all_k_factors(:), TOFM(:), convergence_flags(:), ...
    'VariableNames', {'E_modulus_Pa', 'k_factor', 'TOF_s', 'Converged'});

disp('Simulation results summary:');
disp(results);

%% --- Plot results ---
figure;
plot(mody, TOFM, '-o', 'LineWidth', 1.5);
xlabel('Young''s Modulus (Pa)');
ylabel('TOF (s)');
title('Time-of-Flight vs. Material Stiffness');
grid on;
