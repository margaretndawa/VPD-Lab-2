function build_lab2_simulink()

modelName = 'lab2_motor_model';

% Parameters in base workspace
assignin('base','R',4.416757130168756);
assignin('base','J',0.0023919264);
assignin('base','L',0.0047);
assignin('base','ke',0.499445061043285);
assignin('base','km',0.499445061043285);
assignin('base','Uctrl',2.75);  % example: from your measured data

if bdIsLoaded(modelName)
    close_system(modelName,0);
end

if exist([modelName '.slx'],'file')
    delete([modelName '.slx']);
end

new_system(modelName);
open_system(modelName);

set_param(modelName,'StopTime','1');

% Blocks
add_block('simulink/Sources/Constant', [modelName '/U']);
set_param([modelName '/U'], 'Value', 'Uctrl', 'Position', [30 80 60 100]);

add_block('simulink/Math Operations/Sum', [modelName '/Sum_I']);
set_param([modelName '/Sum_I'], 'Inputs', '+++', 'Position', [140 70 160 130]);

add_block('simulink/Math Operations/Gain', [modelName '/1_over_L_U']);
set_param([modelName '/1_over_L_U'], 'Gain', '1/L', 'Position', [90 80 120 100]);

add_block('simulink/Math Operations/Gain', [modelName '/minus_ke_over_L']);
set_param([modelName '/minus_ke_over_L'], 'Gain', '-ke/L', 'Position', [90 150 130 170]);

add_block('simulink/Math Operations/Gain', [modelName '/minus_R_over_L']);
set_param([modelName '/minus_R_over_L'], 'Gain', '-R/L', 'Position', [90 220 130 240]);

add_block('simulink/Continuous/Integrator', [modelName '/Integrator_I']);
set_param([modelName '/Integrator_I'], 'Position', [200 85 230 115]);

add_block('simulink/Math Operations/Gain', [modelName '/km_over_J']);
set_param([modelName '/km_over_J'], 'Gain', 'km/J', 'Position', [290 85 340 115]);

add_block('simulink/Continuous/Integrator', [modelName '/Integrator_omega']);
set_param([modelName '/Integrator_omega'], 'Position', [390 85 420 115]);

add_block('simulink/Continuous/Integrator', [modelName '/Integrator_theta']);
set_param([modelName '/Integrator_theta'], 'Position', [500 85 530 115]);

add_block('simulink/Sinks/To Workspace', [modelName '/I_out']);
set_param([modelName '/I_out'], 'VariableName', 'I_out', 'Position', [260 20 330 40]);

add_block('simulink/Sinks/To Workspace', [modelName '/omega_out']);
set_param([modelName '/omega_out'], 'VariableName', 'omega_out', 'Position', [440 20 530 40]);

add_block('simulink/Sinks/To Workspace', [modelName '/theta_out']);
set_param([modelName '/theta_out'], 'VariableName', 'theta_out', 'Position', [560 20 650 40]);

% Connections
add_line(modelName, 'U/1', '1_over_L_U/1');
add_line(modelName, '1_over_L_U/1', 'Sum_I/1');

add_line(modelName, 'Sum_I/1', 'Integrator_I/1');
add_line(modelName, 'Integrator_I/1', 'km_over_J/1');
add_line(modelName, 'km_over_J/1', 'Integrator_omega/1');
add_line(modelName, 'Integrator_omega/1', 'Integrator_theta/1');

add_line(modelName, 'Integrator_I/1', 'I_out/1');
add_line(modelName, 'Integrator_omega/1', 'omega_out/1');
add_line(modelName, 'Integrator_theta/1', 'theta_out/1');

add_line(modelName, 'Integrator_omega/1', 'minus_ke_over_L/1');
add_line(modelName, 'minus_ke_over_L/1', 'Sum_I/2');

add_line(modelName, 'Integrator_I/1', 'minus_R_over_L/1');
add_line(modelName, 'minus_R_over_L/1', 'Sum_I/3');

save_system(modelName);
open_system(modelName);
end