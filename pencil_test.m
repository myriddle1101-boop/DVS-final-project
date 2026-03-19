clc; clear; close all;

image_path = "D:\ic\DVS\final project\test11.jpg";

params.spread_angle = 45;      % Hatching Angle (0-180): Direction of pencil strokes
params.line_thickness = 1.0;   % Outline Thickness (0.5-2.0): Simulated lead tip width
params.color_boost = 0.5;      % Saturation Enhancement (1.0-2.0): For vibrant pigments
params.hatch_intensity = 0.5;  % Texture Intensity (0.05-0.25): Simulates lead-on-paper friction
params.paper_tint = 0.95;      % Paper Tone (0.95-1.0): 0.95 for aged paper, 1.0 for pure white
% =================================================

% 1. Pre-processing
img_raw = imread(image_path);
if ~isa(img_raw, 'double'), img = im2double(img_raw); else, img = img_raw; end

% --- Step 1: Color and Contrast Calibration ---
% 1.1 Boost saturation to simulate the rich pigment of colored wax/lead
hsv = rgb2hsv(img);
hsv(:,:,2) = min(1, hsv(:,:,2) * params.color_boost); 
img_vibrant = hsv2rgb(hsv);

% 1.2 Contrast Stretching to normalize the dynamic range
img_adj = imadjust(img_vibrant, stretchlim(img_vibrant), []);

% --- Step 2: Anisotropic Hatching Texture Generation (Simulating Lead Strokes) ---
% 2.1 Generate Stochastic Gaussian Noise
[h, w, ~] = size(img_adj);
raw_noise = randn(h, w);

% 2.2 Morphological Texture Synthesis
% Dilate noise with a linear Structural Element (SE) to create directional "filaments"
se_line = strel('line', 6, params.spread_angle); 
strel('line',6, params.spread_angle + 90)
stylized_texture = imdilate(raw_noise, se_line);
stylized_texture = mat2gray(stylized_texture); 

% 2.3 Chromatic Modulation and Blending
% Replicate texture across RGB channels
texture_rgb = repmat(stylized_texture, [1 1 3]);

% Modulate the hatching texture with local image colors for a "colored lead" effect
colored_hatching = img_adj .* texture_rgb;

% Apply texture via subtraction to simulate pigment deposition on paper grain
img_textured = img_adj - params.hatch_intensity * colored_hatching;

img_textured = max(0, min(1, img_textured));
color_noise = 0.03 * randn(size(img_textured));
img_textured = img_textured + color_noise;
img_textured = max(0,min(1,img_textured));

% --- Step 3: Adaptive Chromatic Outlining---
% 3.1 Extract Canny edges from luminance to simulate structural sketching
gray = rgb2gray(img_textured);
edges = edge(gray, 'canny', [0.06 0.18]);

se_edge = strel('disk', round(params.line_thickness));
edges = imdilate(edges, se_edge);

% 3.2 Adaptive Outlining: Map edges to a darker version of the local color
stroke_colors = img_vibrant / 2.5; 

% --- Step 4: Final Composition and Tonal Enhancement ---
% 4.1 Overlay adaptive chromatic outlines onto the textured base
res_color_pencil = img_textured;
for c = 1:3
    channel = res_color_pencil(:,:,c);
    s_channel = stroke_colors(:,:,c);
    channel(edges) = s_channel(edges);
    res_color_pencil(:,:,c) = channel;
end

% 4.2 Paper Background Simulation & Tonal Compression
res_color_pencil = res_color_pencil * params.paper_tint;
res_color_pencil = imadjust(res_color_pencil, stretchlim(res_color_pencil, [0.01 0.8]), [0 1]);

% 5. Visualization
figure('Name', 'Colored Pencil Debugger (with Preserved Hatching)', 'Color', 'w');

subplot(1,2,1); imshow(img_raw); title('Original Image');
subplot(1,2,2); imshow(res_color_pencil); title('Colored Pencil Style (Retaining Stroke Direction)');

figure('Name', 'Texture & Stroke Detail');
[h, w] = size(res_color_pencil(:,:,1));
roi = res_color_pencil(round(h/3):round(h/2), round(w/3):round(w/2), :);
imshow(imresize(roi, 3));
title('Detail: Observe Anisotropic Hatching and Adaptive Colored Outlines');