function [x_kalman, P] = kalmanFilter(t, a_imu, x_gps)

% KALMANFILTER
% IMU acceleration and GPS position measurements are fused
% to estimate position and velocity.

%% Initial state
% State vector:
% x(1) = position
% x(2) = velocity
x = [0; 0];

%% Initial uncertainty
% Initial uncertainty of the state estimate
P = eye(2);

%% Time step
dt = t(2) - t(1);

%% State transition matrix
% Describes how position and velocity evolve over time.
F = [1 dt;
    0 1];

%% Control/input matrix
% Describes the effect of acceleration on position and velocity.
B = [0.5 * dt^2;
    dt];

%% Measurement matrix
% GPS measures position only.
H = [1 0];

%% Process noise covariance
% Represents uncertainty in the motion model and IMU-based prediction.
% Larger Q -> rely more on GPS measurements.
% Smaller Q -> rely more on the IMU-based prediction.

Q = [0.1 0;
    0 0.1];

%% GPS measurement noise covariance

R = 1^2;

%% Number of samples
N = length(t);

%% Storage for Kalman estimates
% Row 1 -> position
% Row 2 -> velocity
x_kalman = zeros(2, N);

%% Kalman Filter loop
for k = 2:N

    %% 1. Prediction
    % Predict the next state using IMU acceleration.
    x = F * x + B * a_imu(k);

    %% 2. Prediction uncertainty
    % Update uncertainty after the prediction step.
    P = F * P * F' + Q;

    %% 3. GPS measurement
    z = x_gps(k);

    %% 4. Innovation
    % Difference between GPS measurement and predicted measurement.
    y = z - H * x;

    %% 5. Innovation covariance
    S = H * P * H' + R;

    %% 6. Kalman Gain
    % Determines how strongly the measurement affects the estimate.
    K = P * H' / S;

    %% 7. Correction
    % Correct the predicted state using the GPS measurement.
    x = x + K * y;

    %% 8. Update uncertainty
    P = (eye(2) - K * H) * P;

    %% 9. Store estimate
    x_kalman(:, k) = x;

end

end 

