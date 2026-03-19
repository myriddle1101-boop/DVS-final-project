clc; clear; close all;

% --- Parameter Settings ---
image_path = "D:\ic\DVS\final project\test7.jpg"; 
k_value = 10;           % Number of clusters (K-means)
saturation_scale = 1.7; % Saturation boost factor
stroke_len = 10;        % Length of the linear brushstrokes
relief_strength = 0.4;  % Relief/Impasto intensity (0.1-0.4) for 3D texture

% Load Source Image
img_raw = imread(image_path);
[h, w, ~] = size(img_raw);
img = im2double(img_raw);

%% 1. Base Version (Original Logic)
[L1, centers1] = imsegkmeans(img_raw, k_value);
res_base = zeros(size(img_raw), 'like', img_raw);
for i = 1:3
    c_plane = centers1(:, i);
    res_base(:,:,i) = reshape(c_plane(L1), [h, w]);
end
res_base = imgaussfilt(res_base, 1); 

%% 2. Optimized Color Block Version 
% A. Saturation Enhancement
hsv = rgb2hsv(img);
hsv(:,:,2) = min(1, hsv(:,:,2) * saturation_scale);
img_vibrant = hsv2rgb(hsv);

% B. Bilateral Filtering + Clustering
img_smooth = imbilatfilt(img_vibrant, 0.1, 5);
[L2, centers2] = imsegkmeans(im2uint8(img_smooth), k_value);

res_opt = zeros(size(img));
c2_db = double(centers2) / 255;
for i = 1:3
    res_opt(:,:,i) = reshape(c2_db(L2, i), [h, w]);
end
% Use Disk Structural Element for Morphological Cleaning
res_opt = imopen(res_opt, strel('disk', 2));
res_opt = imadjust(res_opt, stretchlim(res_opt), []);

%% 3. Advanced Brushstroke Version (Texture Synthesis)
% A. Directional Stroke Stretching (Using Linear Structural Elements)
se1 = strel('line', stroke_len, 45);  
se2 = strel('line', stroke_len, 135); 
res_p1 = imopen(res_opt, se1);
res_p2 = imopen(res_opt, se2);
res_stroke = (res_p1 + res_p2) / 2;

% B. Extract "Paint Thickness" Features (Gradient Operators)
% Compute x and y gradients from the luminance channel
gray = rgb2gray(res_stroke);
[dx, dy] = gradient(gray);

% C. Simulate Optical Relief Effect (Impasto Simulation)
relief = dx + dy; 

% D. Superimpose Relief Texture onto the Stroke Layer
res_final = res_stroke;
for c = 1:3
  
    res_final(:,:,c) = res_final(:,:,c) + relief_strength * relief;
end

% E. Final Detail Sharpening
% Enhance high-frequency components to sharpen stroke boundaries
res_final = imsharpen(res_final, 'Radius', 2, 'Amount', 1.5);
res_final = imadjust(res_final, stretchlim(res_final), []);


%% 4. Results Visualization
figure('Name', 'Oil Painting Master Debugger', 'Color', 'w', 'Units', 'normalized', 'Position', [0.05 0.1 0.9 0.8]);

subplot(2,3,1); imshow(res_base); title('1. Base (Muted/Blurry)');
subplot(2,3,2); imshow(res_opt);  title('2. Optimized (Clean Blocks)');
subplot(2,3,3); imshow(res_final); title('3. Stroke/Relief (Impasto)');

% Base Color Distribution
subplot(2,3,4);
c1_db = double(centers1) / 255; 
scatter3(c1_db(:,1), c1_db(:,2), c1_db(:,3), 100, c1_db, 'filled', 'MarkerEdgeColor', 'k');
xlabel('R'); ylabel('G'); zlabel('B');
title('4. Base Cluster Distribution (K-means)'); 
grid on; axis([0 1 0 1 0 1]); view(3);


% Display Cluster Color Distribution in RGB Space
subplot(2,3,5);
scatter3(c2_db(:,1), c2_db(:,2), c2_db(:,3), 100, c2_db, 'filled', 'MarkerEdgeColor', 'k');
xlabel('R'); ylabel('G'); zlabel('B');
title('5. Optimized Cluster Distribution (K-means)'); 
grid on; axis([0 1 0 1 0 1]); view(3);

% Detail Comparison
subplot(2,3,6);
roi_rect = [round(w/3), round(h/3), 200, 200];
detail_opt = imcrop(res_opt, roi_rect);
detail_final = imcrop(res_final, roi_rect);
imshow([imresize(detail_opt,2), imresize(detail_final,2)]);
title('Left: Color Blocks | Right: Stroke Texture');

sgtitle('Oil Painting Logic: Texture Synthesis with Color Consistency');