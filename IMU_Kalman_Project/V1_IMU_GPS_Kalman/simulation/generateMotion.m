function [t, a_true, v_true, x_true] = generateMotion()

% Simulation parameters
fs = 100;          % Sampling frequency (Hz)
T = 10;            % Total simulation time (seconds)
dt = 1/fs;         % Sampling interval

% Time vector
t = 0:dt:T;

% True acceleration
a_true = zeros(size(t));

% 0-2 seconds: acceleration
a_true(t >= 0 & t < 2) = 2;

% 2-6 seconds: constant velocity
a_true(t >= 2 & t < 6) = 0;

% 6-8 seconds: deceleration
a_true(t >= 6 & t < 8) = -2;

% 8-10 seconds: stopped
a_true(t >= 8) = 0;

% Initial conditions
v0 = 0;
x0 = 0;

% Integrate acceleration to obtain velocity
v_true = v0 + cumtrapz(t, a_true);

% Integrate velocity to obtain position
x_true = x0 + cumtrapz(t, v_true);

end 