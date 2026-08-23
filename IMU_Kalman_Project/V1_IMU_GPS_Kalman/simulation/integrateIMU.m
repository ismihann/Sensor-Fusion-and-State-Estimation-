function [v_imu, x_imu] = integrateIMU(t, a_filtered)

% Initial conditions
v0 = 0;
x0 = 0;

% Acceleration -> velocity
v_imu = v0 + cumtrapz(t, a_filtered);

% Velocity -> position
x_imu = x0 + cumtrapz(t, v_imu);

end
