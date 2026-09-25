function prediction = integrateIMU2D(imu)

% İvmeden hızı hesapla
prediction.vx = cumtrapz(imu.time, imu.ax);
prediction.vy = cumtrapz(imu.time, imu.ay);

% Hızdan konumu hesapla
prediction.x = cumtrapz(imu.time, prediction.vx);
prediction.y = cumtrapz(imu.time, prediction.vy);

% Zaman bilgisini sakla
prediction.time = imu.time;

end