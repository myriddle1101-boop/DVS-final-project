clc; clear; close all;

image_path = "D:\ic\DVS\final project\test12.jpg"; 

params.tile_size = 16;      % Tile Dimension (8-20): Determines the "pixelated" scale
params.color_count = 16;     % Cluster Count K (4-16): Simulates limited ceramic tile palettes
params.edge_strength = 0.4; % Cement Gap Intensity (0.1-1.0): Darkness of tile borders
params.vibrancy = 1.3;      % Color Saturation (1.0-1.8): Simulates glazed tile aesthetics
% =========================================================================


% 1. Image Loading and Pre-processing
img_raw = imread(image_path);
if size(img_raw, 3) ~= 3
    
    img_raw = repmat(img_raw, [1 1 3]);
end
img = im2double(img_raw);
[h, w, ~] = size(img);

%% Step 1: Color Quantization

% 1.1 Chrominance Enhancement
hsv = rgb2hsv(img);
hsv(:,:,2) = min(1, hsv(:,:,2) * params.vibrancy);
img_vibrant = hsv2rgb(hsv);

% 1.2 Vector Quantization (Reshaping to [Pixels x 3])
pixel_data = reshape(img_vibrant, h*w, 3);

% 1.3 K-means Clustering
[cluster_idx, cluster_centers] = kmeans(pixel_data, params.color_count, ...
    'Distance', 'sqeuclidean', 'Replicates', 3, 'MaxIter', 500);

% 1.4 Reconstruction of the Quantized Image
quantized_pixels = cluster_centers(cluster_idx, :);
img_quantized = reshape(quantized_pixels, h, w, 3);

%% Step 2: Spatial Block Synthesis 
% Creates rigid "tiled" boundaries using Nearest-Neighbor Interpolation.

% 2.1 Align Dimensions to multiples of Tile Size
new_h = floor(h / params.tile_size) * params.tile_size;
new_w = floor(w / params.tile_size) * params.tile_size;
img_cropped = imresize(img_quantized, [new_h, new_w]);

% 2.2 Downsampling: Signal decimation into a low-resolution grid
small_img = imresize(img_cropped, 1/params.tile_size, 'nearest');

% 2.3 Upsampling: Nearest-neighbor reconstruction to generate blocks
img_tiles = imresize(small_img, [new_h, new_w], 'nearest');

%% Step 3: Cement Gap Generation

% 3.1 Extract Horizontal and Vertical Gradients from the blocky image
gray_tiles = rgb2gray(img_tiles);
[dx, dy] = imgradientxy(gray_tiles);
gradient_mag = sqrt(dx.^2 + dy.^2);

% 3.2 Morphological Processing
se_edge = strel('square', 2);
se_dilate = strel('disk', round(params.tile_size/4));
edge_mask = imdilate(gradient_mag > 0.05, se_edge); 
patch_mask = imdilate(edge_mask, se_dilate);       

% 3.3 Composite Cement Gaps
res_mosaic = img_tiles;
for c = 1:3
    channel = res_mosaic(:,:,c);
    channel(edge_mask) = channel(edge_mask) * (1 - params.edge_strength);
    res_mosaic(:,:,c) = channel;
end

%% Step 4: Final Tonal Adjustment
res_mosaic = imadjust(res_mosaic, stretchlim(res_mosaic, [0.01 0.99]), []);

%% Visualization
figure('Name', 'Mosaic Style Generator', 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);

subplot(1,2,1); imshow(img_raw); title('Original Image');
subplot(1,2,2); imshow(res_mosaic); title(sprintf('Mosaic Style (Tiles:%d, K:%d)', params.tile_size, params.color_count));


figure('Name', 'Mosaic Detail Close-up');
[h_m, w_m, ~] = size(res_mosaic);
roi_rect = [round(w_m/3), round(h_m/3), 200, 200];
crop_mosaic = imcrop(res_mosaic, roi_rect);
imshow(imresize(crop_mosaic, 3));
title('Detail: Observe the blocky tiles and cement gaps');
