function imu = simulateIMU2D(motion)

% IMU bias değerleri
biasX = 0.05;
biasY = -0.03;

% IMU noise standart sapması
noiseStd = 0.05;


% Rastgele noise üret
noiseX = noiseStd * randn(size(motion.ax));
noiseY = noiseStd * randn(size(motion.ay));

% IMU ölçümleri
imu.ax = motion.ax + biasX + noiseX;
imu.ay = motion.ay + biasY + noiseY;

% Zaman bilgisini sakla
imu.time = motion.time;

end

