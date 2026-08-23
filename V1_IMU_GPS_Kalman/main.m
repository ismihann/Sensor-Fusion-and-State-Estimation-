clc;
clear;
close all;

%% 1. Initialization
%Add the simulation folder to the MATLAB path
addpath('simulation');


%% 2.Generate True Motion
% Generate the ideal motion of the system 
% Outputs:
% t -> time vector 
% a_true -> true acceleration
% v_true -> true velocity 
% x_true ->true position

[t, a_true, v_true, x_true] = generateMotion();


%% 3. Simulate IMU Measurement 
% Simulate an IMU measurement by adding:
% - Constant sensor bias
% - Random measurement noise
%
% Outputs:
% a_imu     -> simulated IMU acceleration
% imu_bias  -> constant sensor bias
% imu_noise -> random measurement noise

[a_imu, imu_bias, imu_noise] = simulateIMU(a_true);


%% 4. Filter IMU Measurement
% Reduce high-frequency measurement noise using
% a moving average filter.

a_filtered = filterIMU(a_imu);


%% 5. Estimate Velocity and Position from IMU
% Integrate the filtered acceleration:
% acceleration -> velocity -> position
%
% This step demonstrates the drift problem caused by
% sensor errors and integration.
[v_imu, x_imu] = integrateIMU(t, a_filtered);



%% 6. Simulate GPS Measurement
% Simulate GPS position measurements by adding
% random measurement noise to the true position.

[x_gps, gps_noise] = simulateGPS(x_true);



%% 7. Kalman Filter Sensor Fusion
% Fuse IMU acceleration and GPS position measurements
% to estimate the system state.
%
% x_kalman(1,:) -> estimated position
% x_kalman(2,:) -> estimated velocity

[x_kalman, P] = kalmanFilter(t, a_imu, x_gps);

%% 8. Visualization
% Compare true position, IMU estimation,
% GPS measurement, and Kalman estimation.

figure;

plot(t, x_true, 'k', 'LineWidth', 2);
hold on;
plot(t, x_imu, 'r--', 'LineWidth', 1.5);
plot(t, x_gps, 'b:', 'LineWidth', 1);
plot(t, x_kalman(1,:), 'g', 'LineWidth', 2);

grid on;

xlabel('Time (s)');
ylabel('Position (m)');
title('Position Estimation Comparison');

legend('True Position', ...
    'IMU Position', ...
    'GPS Position', ...
    'Kalman Position');

%% 9. Performance Evaluation
% Calculate Root Mean Square Error (RMSE)
% for each position estimation method.

rmse_imu = sqrt(mean((x_imu - x_true).^2));
rmse_gps = sqrt(mean((x_gps - x_true).^2));
rmse_kalman = sqrt(mean((x_kalman(1,:) - x_true).^2));

fprintf('\nRMSE Results:\n');
fprintf('IMU    : %.4f m\n', rmse_imu);
fprintf('GPS    : %.4f m\n', rmse_gps);
fprintf('Kalman : %.4f m\n', rmse_kalman);

%% 10. IMU Measurement Comparison
% Compare the true acceleration with the noisy
% and filtered IMU measurements.

figure;

plot(t, a_true, 'k', 'LineWidth', 2);
hold on;

plot(t, a_imu, 'r', 'LineWidth', 1);

plot(t, a_filtered, 'b', 'LineWidth', 1.5);

grid on;

xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');

title('IMU Acceleration: True vs Noisy vs Filtered');

legend('True Acceleration', ...
    'Raw IMU', ...
    'Filtered IMU', ...
    'Location', 'best');

%% 11. IMU Position Drift
% Show how small IMU measurement errors accumulate
% during integration and cause position drift.

figure;

plot(t, x_true, 'k', 'LineWidth', 2);
hold on;

plot(t, x_imu, 'r--', 'LineWidth', 1.5);

grid on;

xlabel('Time (s)');
ylabel('Position (m)');

title('IMU Position Drift');

legend('True Position', ...
    'IMU Estimated Position', ...
    'Location', 'best');

%% 12. Velocity Estimation
% Compare the true velocity with the velocity
% estimated from the filtered IMU acceleration.

figure;

plot(t, v_true, 'k', 'LineWidth', 2);
hold on;

plot(t, v_imu, 'r--', 'LineWidth', 1.5);

grid on;

xlabel('Time (s)');
ylabel('Velocity (m/s)');

title('Velocity Estimation: True vs IMU');

legend('True Velocity', ...
    'IMU Estimated Velocity', ...
    'Location', 'best');

%% 13. Kalman Velocity Estimation
% Compare true velocity with IMU-based and
% Kalman Filter-based velocity estimates.

figure;

plot(t, v_true, 'k', 'LineWidth', 2);
hold on;

plot(t, v_imu, 'r--', 'LineWidth', 1.5);

plot(t, x_kalman(2,:), 'g', 'LineWidth', 2);

grid on;

xlabel('Time (s)');
ylabel('Velocity (m/s)');

title('Velocity Estimation Comparison');

legend('True Velocity', ...
    'IMU Velocity', ...
    'Kalman Velocity', ...
    'Location', 'best');

%% 14. IMU Bias and Noise
% Visualize the effect of sensor bias and random noise
% on the IMU acceleration measurement.

figure;

plot(t, a_true, 'k', 'LineWidth', 2);
hold on;

plot(t, a_true + imu_bias, 'b--', 'LineWidth', 1.5);

plot(t, a_imu, 'r', 'LineWidth', 1);

grid on;

xlabel('Time (s)');
ylabel('Acceleration (m/s^2)');

title('Effect of IMU Bias and Noise');

legend('True Acceleration', ...
    'True Acceleration + Bias', ...
    'IMU Measurement', ...
    'Location', 'best');

%% 15. Final Position Estimation
% Compare all position estimates with the true position.

figure;

plot(t, x_true, 'k', 'LineWidth', 2);
hold on;

plot(t, x_imu, 'r--', 'LineWidth', 1.3);

plot(t, x_gps, 'b:', 'LineWidth', 1.2);

plot(t, x_kalman(1,:), 'g', 'LineWidth', 2);

grid on;

xlabel('Time (s)');
ylabel('Position (m)');

title('Position Estimation: IMU vs GPS vs Kalman');

legend('True Position', ...
    'IMU Position', ...
    'GPS Position', ...
    'Kalman Position', ...
    'Location', 'best');
