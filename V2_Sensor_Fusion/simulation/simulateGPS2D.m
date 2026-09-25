function gps = simulateGPS2D(motion)

% GPS ölçüm gürültüsünün standart sapması
gpsNoiseStd = 1.0;

% X ve Y için rastgele GPS hatası
noiseX = gpsNoiseStd * randn(size(motion.x));
noiseY = gpsNoiseStd * randn(size(motion.y));

% GPS konum ölçümleri
gps.x = motion.x + noiseX;
gps.y = motion.y + noiseY;

% Zaman bilgisini sakla
gps.time = motion.time;

end
