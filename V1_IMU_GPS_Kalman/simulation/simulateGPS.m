function [x_gps, gps_noise] = simulateGPS(x_true)

% GPS noise
gps_noise_std = 1.0;   % meters

% Generate GPS measurement noise
gps_noise = gps_noise_std * randn(size(x_true));

% Generate GPS position measurement
x_gps = x_true + gps_noise;

end
