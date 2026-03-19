function out = pencil_sketch_style(img, s_angle, intensity, thickness, boost)
    % Parameter initialization
    if nargin < 2, s_angle = 45; end
    if nargin < 3, intensity = 0.5; end
    if nargin < 4, thickness = 1.0; end
    if nargin < 5, boost = 0.5; end

    if ~isa(img, 'double'), img = im2double(img); end

    % --- Step 1: Chrominance Enhancement ---
    hsv = rgb2hsv(img);
    hsv(:,:,2) = min(1, hsv(:,:,2) * boost); 
    img_vibrant = hsv2rgb(hsv);
    img_adj = imadjust(img_vibrant, stretchlim(img_vibrant), []);

    % --- Step 2: Anisotropic Hatching Texture---
    [h, w, ~] = size(img_adj);
    raw_noise = randn(h, w);
    % Simulate directional pencil strokes using a linear Structural Element (SE)
    se_line = strel('line', 6, s_angle); 
    stylized_texture = imdilate(raw_noise, se_line);
    stylized_texture = mat2gray(stylized_texture); 
    
    % Adaptive Color Hatching Logic:
    texture_rgb = repmat(stylized_texture, [1 1 3]);
    colored_hatching = img_adj .* texture_rgb; 
    
    % Blending: Subtract texture from base to simulate graphite/wax deposition
    img_textured = img_adj - intensity * colored_hatching;
    img_textured = img_textured + 0.03 * randn(size(img_textured));
    img_textured = max(0, min(1, img_textured));

    % --- Step 3: Adaptive Chromatic Outlining ---
    gray = rgb2gray(img_textured);
    edges = edge(gray, 'canny', [0.06 0.18]);
    edges = imdilate(edges, strel('disk', round(thickness)));
    
    stroke_colors = img_vibrant / 2.5; 

    % --- Step 4: Final Synthesis & Tonal Mapping (Lab 6) ---
    out = img_textured;
    for c = 1:3
        channel = out(:,:,c);
        s_channel = stroke_colors(:,:,c);
        channel(edges) = s_channel(edges);
        out(:,:,c) = channel;
    end
   
    out = imadjust(out, stretchlim(out, [0.01 0.8]), [0 1]);
end