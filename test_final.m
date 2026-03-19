clc; clear; close all;

% --- 1. Load Source Image ---
I = imread("D:\ic\DVS\final project\test7.jpg"); %change your path here

fprintf('Processing artistic transformations, please wait...\n');
% --- 2. Style 1: Standard Pop Art ---
% Parameters: Image, Quantization Levels (6), Gamma (0.4), Outline Thickness (1)
res1 = applyPopArt(I, 6, 0.4, 1);

% --- 3. Style 2: Swirl Pop Art (Geometric Distortion) ---
% Parameters: Image, Levels, Gamma, Outline, Swirl Intensity (4), Influence Radius (1000)
res2 = applySwirlPopArt(I, 8, 0.5, 1, 4, 1000);

% --- 4. Style 3: Oil Painting (Enhanced Brushstrokes) ---
% Parameters: Image, K-clusters (10), Saturation (1.8), Stroke Length (15), Relief Intensity (0.5)
k = 10;
sat = 1.8;
s_len = 15;
rel = 0.5;
res3 = oil_paint_style(I, k, sat, s_len, rel);

% --- 5. Style 4: Ink Wash Style (Eastern Aesthetics) ---
% Parameters: Image, Diffusion/Blur (15), Edge Weight (0.3), Paper Brightness (0.9)
% Note: Higher sigma (15) creates better ink diffusion; lower weight (0.3) yields a poetic feel.
b_sigma = 15;
e_weight = 0.3;
p_tint = 0.9;
res4 = ink_style(I, b_sigma, e_weight, p_tint);

% --- 6. Style 5: Colored Pencil (Adaptive Hatching) ---
% Parameters: Image, Texture Intensity (0.5), Stroke Thickness (1.0), Color Boost (0.5)
p_angle = 45;
p_inten = 0.5;
p_thick = 1.0;
p_boost = 0.5;
res5 = pencil_sketch_style(I, p_angle, p_inten, p_thick, p_boost);

% --- 7. Style 6: Mosaic Style ---
% Parameters: Image, Tile Size (16), Color Quantization (12), Gap Strength (0.5), Vibrancy (1.4)
res6 = applyMosaicStyle(I, 16, 12, 0.5, 1.4);

fprintf('All styles generated successfully.\n');
% --- 8. Final Visualization (Optimized 2x3 Layout) ---
figure('Name', 'Imperial DVS Final Project: Art Style Gallery', 'Color', 'w');

subplot(2,3,1); imshow(res1); title('1. Pop Art');
subplot(2,3,2); imshow(res2); title('2. Swirl Art');
subplot(2,3,3); imshow(res3); title('3. Oil Painting');
subplot(2,3,4); imshow(res4); title('4. Ink Wash');
subplot(2,3,5); imshow(res5); title('5. Colored Pencil');
subplot(2,3,6); imshow(res6); title('6. Mosaic Style');
