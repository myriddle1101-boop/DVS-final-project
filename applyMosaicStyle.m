function out = applyMosaicStyle(img, tile_size, color_count, edge_strength, vibrancy)
    if nargin < 2, tile_size = 16; end
    if nargin < 3, color_count = 12; end
    if nargin < 4, edge_strength = 0.4; end
    if nargin < 5, vibrancy = 1.3; end

    if ~isa(img, 'double'), img = im2double(img); end
    [h, w, ~] = size(img);

    % --- Step 1: Color Quantization (Lab 6: K-means Clustering) ---
    hsv = rgb2hsv(img);
    hsv(:,:,2) = min(1, hsv(:,:,2) * vibrancy);
    img_v = hsv2rgb(hsv);
    
    pixel_data = reshape(img_v, h*w, 3);
    [cluster_idx, cluster_centers] = kmeans(pixel_data, color_count, ...
        'Distance', 'sqeuclidean', 'Replicates', 1, 'MaxIter', 200);
    quantized_pixels = cluster_centers(cluster_idx, :);
    img_q = reshape(quantized_pixels, h, w, 3);

    % --- Step 2: Block Synthesis---
    new_h = floor(h / tile_size) * tile_size;
    new_w = floor(w / tile_size) * tile_size;
    small_img = imresize(img_q(1:new_h, 1:new_w, :), 1/tile_size, 'nearest');
    img_tiles = imresize(small_img, [new_h, new_w], 'nearest');

    % --- Step 3: Structural Gap Generation ---
    gray_tiles = rgb2gray(img_tiles);
    [dx, dy] = imgradientxy(gray_tiles);
    edge_mask = (sqrt(dx.^2 + dy.^2)) > 0.05;
    edge_mask = imdilate(edge_mask, strel('square', 2)); 

    % --- Step 4: Composition & Tonal Enhancement ---
    out = img_tiles;
    for c = 1:3
        channel = out(:,:,c);
        channel(edge_mask) = channel(edge_mask) * (1 - edge_strength);
        out(:,:,c) = channel;
    end
    out = imadjust(out, stretchlim(out), []);
end