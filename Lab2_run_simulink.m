clear; clc; close all;

build_lab2_simulink;

simOut = sim('lab2_motor_model');

figure;
plot(I_out.time, I_out.signals.values, 'LineWidth', 2);
grid on;
xlabel('t, s');
ylabel('I, A');
title('Simulink current I(t)');

figure;
plot(omega_out.time, omega_out.signals.values, 'LineWidth', 2);
grid on;
xlabel('t, s');
ylabel('\omega, rad/s');
title('Simulink angular speed \omega(t)');

figure;
plot(theta_out.time, theta_out.signals.values, 'LineWidth', 2);
grid on;
xlabel('t, s');
ylabel('\theta, rad');
title('Simulink angle \theta(t)');