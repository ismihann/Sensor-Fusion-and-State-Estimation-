function a_filtered = filterIMU(a_imu)

window_size = 10;

a_filtered = movmean(a_imu, window_size);

end
