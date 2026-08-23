function [a_imu, bias, noise] = simulateIMU(a_true)

% IMU noise and bias parameters
noise_std = 0.1;     % Noise standard deviation
bias = 0.05;         % Constant sensor bias

% Generate random measurement noise
noise = noise_std * randn(size(a_true));

% Generate IMU measurement
a_imu = a_true + bias + noise;

end 