clear; clc; close all;

csv_file = 'U_I.csv';

m = 15.7e-3;      % kg
r = 11.5e-3;      % m
gear_ratio = 48;

L = 0.0047;       % H
Umax = 9.0;       % V
k_avg_lab1 = 0.1802;
Tm_avg_lab1 = 0.0806;

T = readtable(csv_file, 'Delimiter', ';');

U_percent = T{:,1};
U = str2double(strrep(string(T{:,2}), ',', '.'));
I = str2double(strrep(string(T{:,3}), ',', '.'));

R = sum(U .* I) / sum(I.^2);

J_ed = (m * r^2) / 2;
J = gear_ratio^2 * J_ed;

ke = Umax / (100 * k_avg_lab1);
km = ke;
Tya = L / R;
Tm = Tm_avg_lab1;

fprintf('===== FINAL PARAMETERS =====\n');
fprintf('R   = %.6f Ohm\n', R);
fprintf('J   = %.8f kg*m^2\n', J);
fprintf('L   = %.6f H\n', L);
fprintf('ke  = %.6f V*s/rad\n', ke);
fprintf('km  = %.6f N*m/A\n', km);
fprintf('Tya = %.6f s\n', Tya);
fprintf('Tm  = %.6f s\n', Tm);

% Create folder for graphs
outFolder = 'lab2_graphs';
if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

%% 1) Separate U(I) graph for each voltage
uvals = unique(U_percent);
colors = lines(length(uvals));

for kidx = 1:length(uvals)
    u0 = uvals(kidx);
    idx = (U_percent == u0);

    U_k = U(idx);
    I_k = I(idx);

    if numel(U_k) < 2
        continue;
    end

    R_k = sum(U_k .* I_k) / sum(I_k.^2);

    I_line = linspace(min(I_k), max(I_k), 100);
    U_line = R_k * I_line;

    figure;
    plot(I_k, U_k, 'o', 'LineWidth', 1.5, 'MarkerSize', 7);
    hold on;
    plot(I_line, U_line, '-', 'LineWidth', 2);
    grid on;
    xlabel('Current I, A');
    ylabel('Voltage U, V');
    title(sprintf('U(I) for U%% = %g', u0));
    legend('Experimental data', sprintf('Fit: U = %.4f I', R_k), 'Location', 'best');

    saveas(gcf, fullfile(outFolder, sprintf('UI_%g.png', u0)));
end

%% 2) Combined U(I) graph for all voltages
figure;
hold on;
legendText = cell(length(uvals),1);

for kidx = 1:length(uvals)
    u0 = uvals(kidx);
    idx = (U_percent == u0);

    U_k = U(idx);
    I_k = I(idx);

    if numel(U_k) < 2
        continue;
    end

    plot(I_k, U_k, 'o', 'Color', colors(kidx,:), 'LineWidth', 1.2, 'MarkerSize', 5);
    legendText{kidx} = sprintf('U%% = %g', u0);
end

grid on;
xlabel('Current I, A');
ylabel('Voltage U, V');
title('Combined U(I) for all voltages');
legend(legendText, 'Location', 'best');
saveas(gcf, fullfile(outFolder, 'UI_all.png'));

%% 3) Separate model graphs for chosen voltages
model_voltages = [10 15 20 25 30 35 40 45 50];

for kidx = 1:length(model_voltages)
    upr = model_voltages(kidx);
    Uctrl = (upr/100) * Umax;

    f = @(t,x) [ ...
        (km/J) * x(2); ...
        (1/L)*Uctrl - (ke/L)*x(1) - (R/L)*x(2); ...
        x(1)];

    [t, x] = ode45(f, [0 1], [0;0;0]);

    omega = x(:,1);
    curr  = x(:,2);
    theta = x(:,3);

    figure;
    plot(t, omega, 'LineWidth', 2);
    grid on;
    xlabel('t, s');
    ylabel('\omega, rad/s');
    title(sprintf('Speed response for U%% = %d', upr));
    saveas(gcf, fullfile(outFolder, sprintf('omega_%d.png', upr)));

    figure;
    plot(t, curr, 'LineWidth', 2);
    grid on;
    xlabel('t, s');
    ylabel('I, A');
    title(sprintf('Current response for U%% = %d', upr));
    saveas(gcf, fullfile(outFolder, sprintf('current_%d.png', upr)));

    figure;
    plot(t, theta, 'LineWidth', 2);
    grid on;
    xlabel('t, s');
    ylabel('\theta, rad');
    title(sprintf('Angle response for U%% = %d', upr));
    saveas(gcf, fullfile(outFolder, sprintf('theta_%d.png', upr)));
end

%% 4) Combined model graphs for all voltages
figure; hold on;
for kidx = 1:length(model_voltages)
    upr = model_voltages(kidx);
    Uctrl = (upr/100) * Umax;

    f = @(t,x) [ ...
        (km/J) * x(2); ...
        (1/L)*Uctrl - (ke/L)*x(1) - (R/L)*x(2); ...
        x(1)];

    [t, x] = ode45(f, [0 1], [0;0;0]);
    plot(t, x(:,1), 'LineWidth', 1.5);
end
grid on;
xlabel('t, s');
ylabel('\omega, rad/s');
title('Combined speed responses');
legend(string(model_voltages) + "%", 'Location', 'best');
saveas(gcf, fullfile(outFolder, 'omega_all.png'));

figure; hold on;
for kidx = 1:length(model_voltages)
    upr = model_voltages(kidx);
    Uctrl = (upr/100) * Umax;

    f = @(t,x) [ ...
        (km/J) * x(2); ...
        (1/L)*Uctrl - (ke/L)*x(1) - (R/L)*x(2); ...
        x(1)];

    [t, x] = ode45(f, [0 1], [0;0;0]);
    plot(t, x(:,2), 'LineWidth', 1.5);
end
grid on;
xlabel('t, s');
ylabel('I, A');
title('Combined current responses');
legend(string(model_voltages) + "%", 'Location', 'best');
saveas(gcf, fullfile(outFolder, 'current_all.png'));

figure; hold on;
for kidx = 1:length(model_voltages)
    upr = model_voltages(kidx);
    Uctrl = (upr/100) * Umax;

    f = @(t,x) [ ...
        (km/J) * x(2); ...
        (1/L)*Uctrl - (ke/L)*x(1) - (R/L)*x(2); ...
        x(1)];

    [t, x] = ode45(f, [0 1], [0;0;0]);
    plot(t, x(:,3), 'LineWidth', 1.5);
end
grid on;
xlabel('t, s');
ylabel('\theta, rad');
title('Combined angle responses');
legend(string(model_voltages) + "%", 'Location', 'best');
saveas(gcf, fullfile(outFolder, 'theta_all.png'));

results = table(R, J, L, ke, km, Tya, Tm);
writetable(results, fullfile(outFolder, 'lab2_parameters.csv'));
