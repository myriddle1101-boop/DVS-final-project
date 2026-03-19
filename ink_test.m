clc; clear; close all;

% --- 1. Parameter Tuning Section ---
image_path = "D:\ic\DVS\final project\test5.jpg";

params.blur_sigma = 15;      % Ink Diffusion: Higher values simulate wet paper absorption
params.dark_boost = 1.2;      % Ink Intensity (1.0-2.0): Enhances black/white contrast
params.edge_weight = 0.4;     % Dry Brush/Outline Strength (0.5-2.0): Higher for sharper contours
params.paper_tint = 0.8;     % Paper Luminance (0.8-1.0): Simulates off-white rice paper
% =================================================

% 1. Pre-processing
img_raw = imread(image_path);
if size(img_raw, 3) == 3
    gray = rgb2gray(img_raw);
else
    gray = img_raw;
end
img = im2double(gray);

% 2. Simulate Ink Diffusion 
% Utilizing Gaussian Blur to simulate isotropic water penetration in rice paper fibers.
ink_diffused = imgaussfilt(img, params.blur_sigma);

% 3. Structural Outlining
% Computing image gradients using the Sobel operator.
[dx, dy] = imgradientxy(img);
[mag, ~] = imgradient(dx, dy);


ink_edges = imcomplement(mag * params.edge_weight);
ink_edges = clamp(ink_edges, 0, 1);

% 4. Composite Ink Wash Effect
res_ink = ink_diffused .* ink_edges;

% 5. Tonal Adjustment & Paper Texture
res_ink = res_ink * params.paper_tint;
res_ink = imadjust(res_ink, stretchlim(res_ink, [0.05 0.95]), []);

% 6. Visualization
figure('Name', 'Ink Wash Style Debugger', 'Color', 'w');

subplot(1,3,1); imshow(img_raw); title('Original Image');
subplot(1,3,2); imshow(ink_diffused); title('Step 1: Diffusion');
subplot(1,3,3); imshow(res_ink); title('Step 2: Final');

figure('Name', 'Stroke Detail');
[h, w] = size(res_ink);
roi = res_ink(round(h/3):round(h/2), round(w/3):round(w/2));
imshow(imresize(roi, 4));
title('Detail: Notice the blended edges and brush lines');

% Helper Function: Value Clamping
function out = clamp(in, low, high)
    out = max(low, min(high, in));
end

% clc; clear; close all;

% image_path = "D:\ic\DVS\final project\test1.jpg"; 
% blur_size = 15;
% canny_thresh = [0.05 0.15]; 
% 
% % 1. Pre-processing
% img_raw = imread(image_path);
% if size(img_raw, 3) == 3
%     gray = rgb2gray(img_raw);
% else
%     gray = img_raw;
% end
% img = im2double(gray);
% [h, w] = size(img);
% 
% %% Experiment I: Edge Operator Comparison (Dry Brush Simulation)
% % 1. Sobel Operator (Gradient Magnitude) - Selected Approach
% [dx, dy] = imgradientxy(img);
% [sobel_mag, ~] = imgradient(dx, dy);
% sobel_edges = imcomplement(clamp(sobel_mag * 1.5, 0, 1)); 
% 
% % 2. Canny Operator (Binary Mask) - Alternative Approach
% canny_mask = edge(img, 'canny', canny_thresh);
% canny_edges = imcomplement(im2double(canny_mask)); 
% 
% %% Experiment II: Filter Comparison (Ink Diffusion Simulation)
% % 3.Gaussian Filter - Selected Approach
% gauss_blur = imgaussfilt(img, blur_size/3); 
% 
% % 4. Mean Filter (Box Filter)
% mean_blur = imfilter(img, fspecial('average', blur_size));
% 
% %%Visualization of Results
% figure('Name', 'Ink Wash Algorithm Comparison', 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
% 
% % Edge Operator Comparison
% subplot(2,2,1); imshow(sobel_edges); title('A. Sobel Gradient');
% subplot(2,2,2); imshow(canny_edges); title('B. Canny Binary');
% 
% % Row 2: Filtering Comparison
% subplot(2,2,3); imshow(gauss_blur); title('C. Gaussian Blur');
% subplot(2,2,4); imshow(mean_blur); title('D. Mean Blur');
% 
% % Close-up detail comparison (Gaussian vs Mean)
% figure('Name', 'Blur Detail Close-up');
% roi_rect = [round(w/3), round(h/3), 200, 200];
% crop_gauss = imcrop(gauss_blur, roi_rect);
% crop_mean = imcrop(mean_blur, roi_rect);
% imshow([imresize(crop_gauss, 3), imresize(crop_mean, 3)]);
% title('Left：Gaussian | Right：Mean');
% 
% function out = clamp(in, low, high)
%     out = max(low, min(high, in));
% end