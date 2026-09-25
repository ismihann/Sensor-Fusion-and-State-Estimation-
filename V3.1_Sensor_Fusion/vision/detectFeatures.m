function [points, features] = detectFeatures(I)

% Görüntüyü gri seviyeye çevir
grayImage = im2gray(I);

% Görüntüde belirgin köşe/noktaları bul
points = detectHarrisFeatures(grayImage);

% Bulunan noktaların özelliklerini hesapla
[features, points] = extractFeatures(grayImage, points);

end