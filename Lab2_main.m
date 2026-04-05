clear; clc; close all;

%% =========================
%  INPUT DATA / PARAMETERS
%  =========================
csv_file = 'U_I.csv';

% Rotor data
m = 15.7e-3;      % kg  (15.7 g)
r = 11.5e-3;      % m   (11.5 mm)
gear_ratio = 48;

% From Lab 2 manual / Lab 1 fallback
L = 0.0047;       % H
Umax = 9.0;       % V
k_avg_lab1 = 0.1802;   % rad/(s*%)
Tm_avg_lab1 = 0.0806;  % s

%% =========================
%  PART 1. READ U-I DATA
%  =========================
T = readtable(csv_file, 'Delimiter', ';');

U_percent = T{:,1};
U = str2double(strrep(string(T{:,2}), ',', '.'));
I = str2double(strrep(string(T{:,3}), ',', '.'));

%% =========================
%  PART 2. CALCULATE R
%  U = R*I
%  =========================
R = sum(U .* I) / sum(I.^2);

%% =========================
%  PART 3. CALCULATE J
%  =========================
J_ed = (m * r^2) / 2;
J = gear_ratio^2 * J_ed;

%% =========================
%  PART 4. FALLBACK ke, km
%  from Lab 1 average k
%  omega_ss = k * U_percent
%  U_volts = (U_percent/100)*Umax
%  U = ke * omega_ss
%  => ke = Umax/(100*k)
%  =========================
ke = Umax / (100 * k_avg_lab1);
km = ke;

%% =========================
%  PART 5. TIME CONSTANTS
%  =========================
Tya = L / R;                 % electrical time constant
Tm = Tm_avg_lab1;            % use Lab 1 average as fallback

%% =========================
%  PRINT RESULTS
%  =========================
fprintf('===== FINAL PARAMETERS =====\n');
fprintf('R   = %.6f Ohm\n', R);
fprintf('J   = %.8f kg*m^2\n', J);
fprintf('L   = %.6f H\n', L);
fprintf('ke  = %.6f V*s/rad\n', ke);
fprintf('km  = %.6f N*m/A\n', km);
fprintf('Tya = %.6f s\n', Tya);
fprintf('Tm  = %.6f s\n', Tm);

%% =========================
%  PART 6. GRAPH 1: U(I)
%  =========================
I_line = linspace(min(I), max(I), 200);
U_line = R * I_line;

figure('Name','U(I)');
plot(I, U, 'o', 'LineWidth', 1.5, 'MarkerSize', 7);
hold on;
plot(I_line, U_line, '-', 'LineWidth', 2);
grid on;
xlabel('Current I, A');
ylabel('Voltage U, V');
title('Dependence U(I)');
legend('Experimental data', sprintf('Fit: U = %.4f I', R), 'Location', 'best');

%% =========================
%  PART 7. GRAPH 2: U(omega_ss)
%  Since Lab 2 omega files are missing, use Lab 1 average model
%  for positive commands 10:5:50
%  =========================
Upr = (10:5:50)';                       % percent
U_omega = (Upr / 100) * Umax;           % volts
omega_ss = k_avg_lab1 * Upr;            % rad/s

% least-squares fit for U = ke * omega
ke_fit = sum(U_omega .* omega_ss) / sum(omega_ss.^2);

omega_line = linspace(min(omega_ss), max(omega_ss), 200);
U_fit_line = ke_fit * omega_line;

figure('Name','U(omega)');
plot(omega_ss, U_omega, 'o', 'LineWidth', 1.5, 'MarkerSize', 7);
hold on;
plot(omega_line, U_fit_line, '-', 'LineWidth', 2);
grid on;
xlabel('\omega_{ss}, rad/s');
ylabel('U, V');
title('Dependence U(\omega_{ss})');
legend('Approx. data from Lab 1', sprintf('Fit: U = %.4f \\omega', ke_fit), 'Location', 'best');

%% =========================
%  PART 8. MODEL RESPONSE IN MATLAB
%  Full Lab 2 state model:
%    dω/dt = (km/J) I
%    dI/dt = (1/L)U - (ke/L)ω - (R/L)I
%    dθ/dt = ω
%  =========================
Uctrl = 2.75;   % example input voltage
tspan = [0 1];

f = @(t,x) [ ...
    (km/J) * x(2); ...
    (1/L)*Uctrl - (ke/L)*x(1) - (R/L)*x(2); ...
    x(1) ...
    ];

x0 = [0; 0; 0];   % [omega; I; theta]
[t, x] = ode45(f, tspan, x0);

omega = x(:,1);
curr  = x(:,2);
theta = x(:,3);

figure('Name','State response');
plot(t, omega, 'LineWidth', 2);
grid on;
xlabel('t, s');
ylabel('\omega, rad/s');
title('Angular speed \omega(t)');

figure('Name','Current response');
plot(t, curr, 'LineWidth', 2);
grid on;
xlabel('t, s');
ylabel('I, A');
title('Current I(t)');

figure('Name','Angle response');
plot(t, theta, 'LineWidth', 2);
grid on;
xlabel('t, s');
ylabel('\theta, rad');
title('Angle \theta(t)');

%% =========================
%  SAVE RESULTS
%  =========================
results = table(R, J, L, ke, km, Tya, Tm);
writetable(results, 'lab2_parameters.csv');