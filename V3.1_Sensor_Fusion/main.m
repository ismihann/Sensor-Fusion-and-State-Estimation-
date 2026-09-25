clear;
clc;
close all;

%% Vision klasorunu MATLAB path'ine ekle
addpath('vision');

%% RGB goruntu klasoru
imageFolder = fullfile('data', 'rgb');

%% Goruntu dosyalarini bul
imageFiles = dir(fullfile(imageFolder, '*.png'));

fprintf('Toplam goruntu sayisi: %d\n', length(imageFiles));

%% Goruntuler bulundu mu?
if isempty(imageFiles)
    error('data/rgb klasorunde PNG goruntusu bulunamadi!');
end

%% Frame 1 ve Frame 50
frame1 = imread(fullfile(imageFolder, imageFiles(1).name));
frame50 = imread(fullfile(imageFolder, imageFiles(50).name));

%% Frame 1 ve Frame 50'yi goster
figure;

subplot(1,2,1);
imshow(frame1);
title('Frame 1');

subplot(1,2,2);
imshow(frame50);
title('Frame 50');

%% Feature Detection
[points1, features1] = detectFeatures(frame1);
[points50, features50] = detectFeatures(frame50);

%% Feature noktalarini goster
figure;

subplot(1,2,1);
imshow(frame1);
hold on;
plot(points1.selectStrongest(100));
title('Frame 1 - Features');
hold off;

subplot(1,2,2);
imshow(frame50);
hold on;
plot(points50.selectStrongest(100));
title('Frame 50 - Features');
hold off;

%% Feature sayilarini yazdir
fprintf('Frame 1 feature sayisi  : %d\n', points1.Count);
fprintf('Frame 50 feature sayisi : %d\n', points50.Count);

%% Feature Matching

indexPairs = matchFeatures(features1, features50);

fprintf('Eslesen feature sayisi: %d\n', size(indexPairs, 1));


%% Eslesen noktalarin koordinatlarini al

matchedPoints1 = points1(indexPairs(:,1));
matchedPoints50 = points50(indexPairs(:,2));


%% Piksel hareketlerini hesapla

xy1 = matchedPoints1.Location;
xy50 = matchedPoints50.Location;

dx = xy50(:,1) - xy1(:,1);
dy = xy50(:,2) - xy1(:,2);


%% Ortalama piksel hareketi

meanDx = mean(dx);
meanDy = mean(dy);

fprintf('Ortalama piksel hareketi:\n');
fprintf('dx = %.2f pixel\n', meanDx);
fprintf('dy = %.2f pixel\n', meanDy);


%% Feature hareketlerini goster

figure;

imshow(frame1);
hold on;

quiver(xy1(:,1), xy1(:,2), dx, dy, 0);

title('Feature Hareketleri - Frame 1 -> Frame 50');

hold off;

%% Guvenilir feature eslesmelerini bul

[tform, inlier1, inlier50] = estimateGeometricTransform2D( ...
    matchedPoints1, matchedPoints50, ...
    'similarity', ...
    'MaxNumTrials', 2000, ...
    'MaxDistance', 2);
    
fprintf('Guvenilir eslesme sayisi: %d\n', sum(inlier1));

%% Guvenilir eslesmeleri ayir

inlierIndices = find(inlier1);

inlierPoints1 = matchedPoints1(inlierIndices);
inlierPoints50 = matchedPoints50(inlierIndices);

%% Guvenilir eslesmeleri goster

figure;

showMatchedFeatures(frame1, frame50, ...
    inlierPoints1, inlierPoints50, ...
    'montage');

title('Guvenilir Feature Eslesmeleri');

%% Guvenilir landmark hareketleri

inlierXY1 = inlierPoints1.Location;
inlierXY50 = inlierPoints50.Location;

inlierDx = inlierXY50(:,1) - inlierXY1(:,1);
inlierDy = inlierXY50(:,2) - inlierXY1(:,2);


meanInlierDx = mean(inlierDx);
meanInlierDy = mean(inlierDy);

fprintf('Guvenilir landmarklarin ortalama hareketi:\n');
fprintf('dx = %.2f pixel\n', meanInlierDx);
fprintf('dy = %.2f pixel\n', meanInlierDy);

depthFolder = fullfile('data', 'depth');

depthFiles = dir(fullfile(depthFolder, '*.png'));

fprintf('Toplam depth goruntusu: %d\n', length(depthFiles));

%% Frame 1 RGB ve Depth kontrolu

depth1 = imread(fullfile(depthFolder, depthFiles(1).name));

figure;

subplot(1,2,1);
imshow(frame1);
title('RGB - Frame 1');

subplot(1,2,2);
imshow(depth1);
title('Depth - Frame 1');

%% Kamera parametreleri

fx = 525.0;
fy = 525.0;
cx = 319.5;
cy = 239.5;

%% Ilk guvenilir feature'in 3B koordinatini bul

inlierXY1 = inlierPoints1.Location;

u = inlierXY1(1,1);
v = inlierXY1(1,2);

depthValue = depth1(round(v), round(u));

fprintf('\nIlk guvenilir feature:\n');
fprintf('Pixel koordinati: u = %.2f, v = %.2f\n', u, v);
fprintf('Depth ham degeri: %d\n', depthValue);

% Depth'i metreye cevir
Z = double(depthValue) / 5000;

% 3B kamera koordinatlarini hesapla
X = (u - cx) * Z / fx;
Y = (v - cy) * Z / fy;

fprintf('\n3B landmark koordinati:\n');
fprintf('X = %.4f m\n', X);
fprintf('Y = %.4f m\n', Y);
fprintf('Z = %.4f m\n', Z);

%% Frame 50 depth goruntusunu oku

depth50 = imread(fullfile(depthFolder, depthFiles(50).name));

%% Frame 50'de ayni landmarkin depth degerini bul

inlierXY50 = inlierPoints50.Location;

u50 = inlierXY50(1,1);
v50 = inlierXY50(1,2);

depthValue50 = depth50(round(v50), round(u50));

fprintf('\nFrame 50 ayni landmark:\n');
fprintf('Pixel koordinati: u = %.2f, v = %.2f\n', u50, v50);
fprintf('Depth ham degeri: %d\n', depthValue50);

Z50 = double(depthValue50) / 5000;
X50 = (u50 - cx) * Z50 / fx;
Y50 = (v50 - cy) * Z50 / fy;
fprintf('\nFrame 50 3B landmark koordinati:\n');
fprintf('X = %.4f m\n', X50);
fprintf('Y = %.4f m\n', Y50);
fprintf('Z = %.4f m\n', Z50);

%% Tum guvenilir landmarklari 3B'ye donustur

numInliers = size(inlierXY1, 1);

landmarks3D_1 = zeros(numInliers, 3);
landmarks3D_50 = zeros(numInliers, 3);

for i = 1:numInliers

    % Frame 1 koordinatlari
    u1 = inlierXY1(i,1);
    v1 = inlierXY1(i,2);

    % Frame 50 koordinatlari
    u50 = inlierXY50(i,1);
    v50 = inlierXY50(i,2);

    % Frame 1 depth
    d1 = depth1(round(v1), round(u1));

    % Frame 50 depth
    d50 = depth50(round(v50), round(u50));

    % Depth -> metre
    Z1 = double(d1) / 5000;
    Z50 = double(d50) / 5000;

    % Frame 1 -> 3B
    X1 = (u1 - cx) * Z1 / fx;
    Y1 = (v1 - cy) * Z1 / fy;

    % Frame 50 -> 3B
    X50 = (u50 - cx) * Z50 / fx;
    Y50 = (v50 - cy) * Z50 / fy;

    % Kaydet
    landmarks3D_1(i,:) = [X1 Y1 Z1];
    landmarks3D_50(i,:) = [X50 Y50 Z50];

end

fprintf('\n3B landmark sayisi: %d\n', numInliers);

%% 3B landmarklari goster

figure;

scatter3(landmarks3D_1(:,1), ...
    landmarks3D_1(:,2), ...
    landmarks3D_1(:,3), ...
    'filled');

xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

title('Frame 1 - 3B Landmarklar');

grid on;
axis equal;

%% 3B landmark depth kontrolu

fprintf('\n3B landmark depth degerleri:\n');

for i = 1:numInliers
    fprintf('Landmark %d: Z1 = %.3f m, Z50 = %.3f m\n', ...
        i, landmarks3D_1(i,3), landmarks3D_50(i,3));
end

%% Gecerli depth noktalarini sec

validDepth = landmarks3D_1(:,3) > 0 & ...
    landmarks3D_50(:,3) > 0;

landmarks3D_1_valid = landmarks3D_1(validDepth,:);
landmarks3D_50_valid = landmarks3D_50(validDepth,:);

fprintf('\nGecerli 3B landmark sayisi: %d\n', ...
    size(landmarks3D_1_valid,1));


%% Gecerli 3B landmarklari goster

figure;

scatter3(landmarks3D_1_valid(:,1), ...
    landmarks3D_1_valid(:,2), ...
    landmarks3D_1_valid(:,3), ...
    40, 'filled');

hold on;

scatter3(landmarks3D_50_valid(:,1), ...
    landmarks3D_50_valid(:,2), ...
    landmarks3D_50_valid(:,3), ...
    40, 'filled');

xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

title('Frame 1 ve Frame 50 - 3B Landmarklar');

legend('Frame 1', 'Frame 50');

grid on;
axis equal;


%% Frame 1 -> Frame 50 3B hareket tahmini

P = landmarks3D_1_valid;
Q = landmarks3D_50_valid;

% Nokta merkezlerini hesapla
centroidP = mean(P, 1);
centroidQ = mean(Q, 1);

% Noktaları merkezlerine gore kaydir
P_centered = P - centroidP;
Q_centered = Q - centroidQ;

% H covariance matrisi
H = P_centered' * Q_centered;

% SVD
[U,~,V] = svd(H);

% Rotation matrisi
R = V * U';

% Yansima durumunu kontrol et
if det(R) < 0
    V(:,3) = -V(:,3);
    R = V * U';
end

% Translation vektoru
t = centroidQ' - R * centroidP';

fprintf('\nRotation matrisi R:\n');
disp(R);

fprintf('Translation vektoru t:\n');
disp(t);


%% 3B hareket tahmininin hatasini hesapla

Q_predicted = (R * P')' + t';

% Her landmark icin 3B hata
errors3D = sqrt(sum((Q - Q_predicted).^2, 2));

% Ortalama hata
meanError3D = mean(errors3D);

% RMSE
rmse3D = sqrt(mean(errors3D.^2));

fprintf('\n3B hareket tahmini hatasi:\n');
fprintf('Ortalama hata = %.4f m\n', meanError3D);
fprintf('3B RMSE       = %.4f m\n', rmse3D);
