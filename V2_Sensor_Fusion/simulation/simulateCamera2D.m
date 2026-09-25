function camera = simulateCamera2D(motion, environment)

% Kamera ölçüm gürültüsü
cameraNoiseStd = 0.5;

% Landmarklar
landmarks = environment.landmarks;

% Kamera ölçümlerini saklamak için
camera.x = zeros(size(motion.x));
camera.y = zeros(size(motion.y));

% Her zaman adımında kamera ölçümü
for k = 1:length(motion.time)

    % Gerçek robot konumu
    trueX = motion.x(k);
    trueY = motion.y(k);

    % Robot ile tüm landmarklar arasındaki mesafe
    distances = sqrt( ...
        (landmarks(:,1) - trueX).^2 + ...
        (landmarks(:,2) - trueY).^2);

    % Kameranın görebileceği maksimum mesafe
    maxRange = 30;

    % Görüş alanındaki landmarklar
    visible = distances <= maxRange;

    % Eğer en az bir landmark görülüyorsa
    if any(visible)

        % Görülen landmarkların indeksleri
        visibleIndices = find(visible);

        % En yakın görülen landmark
        [~, localIndex] = min(distances(visibleIndices));
        closestLandmark = visibleIndices(localIndex);

        % En yakın landmarkın konumu
        landmarkX = landmarks(closestLandmark, 1);
        landmarkY = landmarks(closestLandmark, 2);

        % Landmarkın kameraya göre göreli konumu
        relativeX = landmarkX - trueX;
        relativeY = landmarkY - trueY;

        % Göreli ölçümden robot konumunu hesapla
        measuredX = landmarkX - relativeX;
        measuredY = landmarkY - relativeY;

        % Kamera noise'u ekle
        camera.x(k) = measuredX + cameraNoiseStd * randn;
        camera.y(k) = measuredY + cameraNoiseStd * randn;

    else

        % Hiç landmark görülmüyorsa ölçüm yok
        camera.x(k) = NaN;
        camera.y(k) = NaN;

    end
end

% Zaman bilgisi
camera.time = motion.time;

end