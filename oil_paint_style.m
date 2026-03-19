function out = oil_paint_style(img, k, sat_val, s_len, r_strength)
    % oil_paint_style: Simulates an oil painting effect using color 
    % quantization, directional morphological filtering, and relief mapping.

    if nargin < 3, sat_val = 1.7; end    % Saturation multiplier
    if nargin < 4, s_len = 10; end       % Length of the simulated brushstrokes
    if nargin < 5, r_strength = 0.4; end % Intensity of the 3D relief/impasto effect

    % Ensure data is in double precision for arithmetic operations
    if ~isa(img, 'double'), img = im2double(img); end
    
    % --- Step 1: Chrominance Pre-processing ---
    hsvImg = rgb2hsv(img);
    hsvImg(:,:,2) = min(1, hsvImg(:,:,2) * sat_val); 
    img_vibrant = hsv2rgb(hsvImg);
    
    % --- Step 2: Edge-Preserving Smoothing ---
    img_smooth = imbilatfilt(img_vibrant, 0.15, 8); 
    
    % --- Step 3: K-means Clustering & Color Reconstruction ---
    [L, centers] = imsegkmeans(im2uint8(img_smooth), k);
    [h, w, ~] = size(img);
    res_q = zeros(h, w, 3);
    centers_db = double(centers) / 255;
    for i = 1:3
        res_q(:,:,i) = reshape(centers_db(L, i), [h, w]);
    end
    
    % --- Step 4: Brushstroke Simulation---
    % Utilize linear Structural Elements (strel) to simulate directional strokes
    se1 = strel('line', s_len, 45);
    se2 = strel('line', s_len, 135);
    out_p1 = imopen(res_q, se1);
    out_p2 = imopen(res_q, se2);
    res_stroke = (out_p1 + out_p2) / 2;
    
    % --- Step 5: Surface Relief/Impasto Enhancement---
    gray = rgb2gray(res_stroke);
    [dx, dy] = gradient(gray);
    relief = dx + dy; % Combine directional derivatives to simulate lighting
    
    out = res_stroke;
    for c = 1:3
        % Superimpose the relief map to create the illusion of paint thickness
        out(:,:,c) = out(:,:,c) + r_strength * relief;
    end
    
    % --- Step 6: Final Enhancement & Contrast Stretching ---
    out = imsharpen(out, 'Radius', 2, 'Amount', 1.2);
    out = imadjust(out, stretchlim(out), []);
end