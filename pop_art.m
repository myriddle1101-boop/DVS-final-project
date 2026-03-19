% clc; clear; close all;
%
% %% Step 0: Read original image
% img_raw = imread("D:\ic\DVS\final project\test1.jpg");
% img = im2double(img_raw);
% [h, w, ~] = size(img); % Dynamically obtain the original image size
%
% figure('Name', 'Abstract Art Style Processing Pipeline', 'NumberTitle', 'off', 'Color', 'w');
%
% % Display original image
% subplot(2, 2, 1);
% imshow(img);
% title('1. Original Image');
%
% %% Step 1 & 2: Bilateral filtering and color quantization
% % Preserve smooth edges
% filtered = imbilatfilt(img, 0.1, 5);
%
% % Color quantization (Posterization)
% levels = 6;
% quantized = round(filtered * levels) / levels;
%
% subplot(2, 2, 2);
% imshow(quantized);
% title(['2. Color Quantization (Levels: ', num2str(levels), ')']);
%
% %% Step 3: Swirl distortion - keep rectangular boundary
% % Build coordinate grid consistent with original image size
% [X, Y] = meshgrid(1:w, 1:h);
%
% % Set swirl parameters
% cx = w / 2;       % Automatically set as image center
% cy = h / 2;
% radius = min(h, w) * 0.8; % Influence radius set to 80% of the shorter side
% strength = 3;             % Distortion strength
%
% dx = X - cx;
% dy = Y - cy;
% r = sqrt(dx.^2 + dy.^2);
%
% % Only pixels inside the radius will be distorted
% mask = r < radius;
% theta = zeros(h, w);
% % Pixels closer to the center rotate more, exponential decay
% theta(mask) = strength * exp(-r(mask) / radius);
%
% % Compute mapped coordinates
% x_new = X;
% y_new = Y;
% x_new(mask) = cx + dx(mask).*cos(theta(mask)) - dy(mask).*sin(theta(mask));
% y_new(mask) = cy + dx(mask).*sin(theta(mask)) + dy(mask).*cos(theta(mask));
%
% % Pixel resampling (interpolation)
% art_img = zeros(size(quantized));
% for c = 1:3
%     % 'linear' ensures smooth interpolation, 0 fills out-of-bound pixels with black
%     art_img(:,:,c) = interp2(X, Y, quantized(:,:,c), x_new, y_new, 'linear', 0);
% end
%
% subplot(2, 2, 3);
% imshow(art_img);
% title('3. Swirl Distortion (No Global Rotation)');
%
% %% Step 4 & 5: Contrast enhancement and edge drawing
% % Gamma correction to enhance color depth
% gamma = 0.4;
% art_img_adj = imadjust(art_img, [], [], gamma);
%
% % Canny edge detection
% gray = rgb2gray(art_img_adj);
% edges = edge(gray, 'Canny');
% edges = imdilate(edges, strel('disk', 1)); % Thicken edges
%
% % Overlay edges onto the image (set as black)
% final_img = art_img_adj;
% for k = 1:3
%     channel = final_img(:,:,k);
%     channel(edges) = 0;
%     final_img(:,:,k) = channel;
% end
%
% subplot(2, 2, 4);
% imshow(final_img);
% title('4. Final Artistic Effect');
%
% % Display high-resolution final image in a new window
% figure('Name', 'Final Artistic Work');
% imshow(final_img);


clc; clear; close all;

%% Step 0: Read and prepare the image
img_raw = imread("D:\ic\DVS\final project\test1.jpg");
img = im2double(img_raw);
[h, w, ~] = size(img);

figure('Name', 'Flat Art Style (No Distortion)', 'NumberTitle', 'off', 'Color', 'w');

% Display original image
subplot(1, 3, 1);
imshow(img);
title('1. Original Image');

%% Step 1 & 2: Core artistic processing
% Bilateral filtering: remove noise while preserving strong edges
% 0.1 is spatial sigma, 5 is intensity sigma (can be tuned depending on image details)
filtered = imbilatfilt(img, 0.1, 5);

% Color quantization: restrict colors to several levels to create a paint-like block effect
levels = 10;
quantized = round(filtered * levels) / levels;

subplot(1, 3, 2);
imshow(quantized);
title(['2. Simplified Color Blocks (Levels: ', num2str(levels), ')']);

%% Step 3: Contrast enhancement and edge extraction
% Gamma adjustment to make colors richer
gamma = 1.5;
art_img_adj = imadjust(quantized, [], [], gamma);

% Canny edge detection: capture boundaries of color regions
gray = rgb2gray(art_img_adj);
edges = edge(gray, 'Canny');

% Dilate edges to make lines more visible and create a hand-drawn effect
edges = imdilate(edges, strel('disk', 1));

% Overlay black edges onto the image
final_img = art_img_adj;
for k = 1:3
    channel = final_img(:,:,k);
    channel(edges) = 0; % Set edge pixels to pure black
    final_img(:,:,k) = channel;
end

subplot(1, 3, 3);
imshow(final_img);
title('3. Final Edge Drawing Result');

% Display the final result in a new window
figure('Name', 'Final Flat Art Style');
imshow(final_img);