clear;
clc;
close all;

%% V2 - 2D Multi-Sensor Fusion with Kalman Filter

% Simulation klasörünü MATLAB path'ine ekle
addpath('simulation');
addpath('filters');
%% 1. Ortamı oluştur

environment = createEnvironment();

%% 2. Ground Truth hareketi oluştur

motion = generateMotion2D();

%% 3. Sensörleri simüle et


% IMU
imu = simulateIMU2D(motion);

% IMU entegrasyonu
prediction = integrateIMU2D(imu);

% GPS
gps = simulateGPS2D(motion);

% Kamera
camera = simulateCamera2D(motion, environment);

%% 4. Kalman Filter

estimate = kalmanFilter2D(motion, imu, gps, camera);

%% =========================================================
% 5. RMSE ANALYSIS
% ==========================================================

% IMU RMSE
imuRMSE = sqrt(mean( ...
    (prediction.x - motion.x).^2 + ...
    (prediction.y - motion.y).^2));

% GPS RMSE
gpsRMSE = sqrt(mean( ...
    (gps.x - motion.x).^2 + ...
    (gps.y - motion.y).^2));

% Camera RMSE
cameraRMSE = sqrt(mean( ...
    (camera.x - motion.x).^2 + ...
    (camera.y - motion.y).^2));

% Kalman RMSE
kalmanRMSE = sqrt(mean( ...
    (estimate.x - motion.x).^2 + ...
    (estimate.y - motion.y).^2));


%% RMSE sonuçlarını Command Window'da göster

fprintf('\n');
fprintf('========================================\n');
fprintf('          V2 RMSE RESULTS\n');
fprintf('========================================\n');

fprintf('IMU     RMSE : %.4f m\n', imuRMSE);
fprintf('GPS     RMSE : %.4f m\n', gpsRMSE);
fprintf('Camera  RMSE : %.4f m\n', cameraRMSE);
fprintf('Kalman  RMSE : %.4f m\n', kalmanRMSE);

fprintf('========================================\n');


%% 6. Ground Truth vs IMU Prediction

figure;

plot(motion.x, motion.y, 'b', 'LineWidth', 2);
hold on;

plot(prediction.x, prediction.y, 'r--', ...
    'LineWidth', 1.5);

plot(environment.landmarks(:,1), ...
    environment.landmarks(:,2), ...
    'k^', ...
    'MarkerSize', 8, ...
    'LineWidth', 1.5);

xlabel('X Position (m)');
ylabel('Y Position (m)');

title('Ground Truth vs IMU Prediction');

legend('Ground Truth', ...
       'IMU Prediction', ...
       'Landmarks');

grid on;
axis equal;


%% 7. Ground Truth vs IMU Acceleration

figure;

plot(motion.time, motion.ax, ...
    'b', 'LineWidth', 1.5);

hold on;

plot(imu.time, imu.ax, ...
    'r--', 'LineWidth', 1);

xlabel('Time (s)');
ylabel('Acceleration X (m/s^2)');

title('Ground Truth vs IMU - X Acceleration');

legend('Ground Truth', ...
       'IMU');

grid on;


%% 8. Tüm Sensörlerin Karşılaştırılması

figure;

plot(motion.x, motion.y, ...
    'k', 'LineWidth', 2);

hold on;

plot(prediction.x, prediction.y, ...
    'r--', 'LineWidth', 1.5);

plot(gps.x, gps.y, ...
    'b.', 'MarkerSize', 8);

plot(camera.x, camera.y, ...
    'g.', 'MarkerSize', 8);

plot(estimate.x, estimate.y, ...
    'c-', 'LineWidth', 2);

plot(environment.landmarks(:,1), ...
    environment.landmarks(:,2), ...
    'm^', ...
    'MarkerSize', 8, ...
    'LineWidth', 1.5);

xlabel('X Position (m)');
ylabel('Y Position (m)');

title('V2 - Multi-Sensor Comparison');

legend('Ground Truth', ...
       'IMU Prediction', ...
       'GPS', ...
       'Camera', ...
       'Kalman Estimate', ...
       'Landmarks');

grid on;
axis equal;


%% 9. RMSE Karşılaştırma Grafiği

figure;

rmseValues = [imuRMSE, ...
              gpsRMSE, ...
              cameraRMSE, ...
              kalmanRMSE];

bar(rmseValues);

set(gca, ...
    'XTickLabel', ...
    {'IMU', 'GPS', 'Camera', 'Kalman'});

ylabel('RMSE (m)');

title('V2 - RMSE Comparison');

grid on;


%% 10. Kalman vs Ground Truth

figure;

plot(motion.x, motion.y, ...
    'b-', 'LineWidth', 2);

hold on;

plot(estimate.x, estimate.y, ...
    'r--', 'LineWidth', 2);

plot(environment.landmarks(:,1), ...
    environment.landmarks(:,2), ...
    'k^', ...
    'MarkerSize', 8, ...
    'LineWidth', 1.5);

xlabel('X Position (m)');
ylabel('Y Position (m)');

title('Ground Truth vs Kalman Estimate');

legend('Ground Truth', ...
       'Kalman Estimate', ...
       'Landmarks');

grid on;
axis equal;


%% 11. Sonuç

fprintf('\n');

if kalmanRMSE < gpsRMSE && kalmanRMSE < cameraRMSE
    fprintf('Kalman Filter: SENSOR FUSION BASARILI.\n');
    fprintf('Kalman RMSE, GPS ve Camera RMSE''den daha dusuk.\n');
else
    fprintf('Kalman Filter sonucu beklenen seviyede degil.\n');
    fprintf('Kalman parametrelerini incelemek gerekiyor.\n');
end

fprintf('\nV2 simulation tamamlandi.\n');