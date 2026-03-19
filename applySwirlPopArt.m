function final_img = applySwirlPopArt(img, levels, gamma, edgeThickness, strength, radius)
   % 1. Basic Pre-processing
    if ~isa(img, 'double')
        img = im2double(img);
    end
    % Apply Bilateral Filtering to preserve edges while smoothing flat regions
    filtered = imbilatfilt(img, 0.1, 5);
    quantized = round(filtered * levels) / levels;

    % 2. Execute Swirl/Vortex Distortion
    [h, w, ~] = size(quantized);
    [X, Y] = meshgrid(1:w, 1:h);
    % Define the center of the transformation (Image Center)
    cx = w / 2;
    cy = h / 2;
    
    dx = X - cx;
    dy = Y - cy;
    r = sqrt(dx.^2 + dy.^2);
    
    % Compute the distortion intensity based on radial distance
    mask = r < radius;
    theta = zeros(h, w);
    % Exponential decay of rotation strength as distance increases
    theta(mask) = strength * exp(-r(mask) / radius);
    
    % Perform Forward Mapping Calculations
    x_new = X; 
    y_new = Y;
    x_new(mask) = cx + dx(mask).*cos(theta(mask)) - dy(mask).*sin(theta(mask));
    y_new(mask) = cy + dx(mask).*sin(theta(mask)) + dy(mask).*cos(theta(mask));
    
   % --- Boundary Constraint: Prevent black borders and maintain rectangle ---
    % Clamping out-of-bounds coordinates to the nearest edge pixel
    x_new = max(1, min(w, x_new));
    y_new = max(1, min(h, y_new));
    
    swirled = zeros(size(quantized));
    for c = 1:3
       
        swirled(:,:,c) = interp2(X, Y, quantized(:,:,c), x_new, y_new, 'linear');
    end

    % 3. Post-processing and Edge Enhancement
    art_img_adj = imadjust(swirled, [], [], gamma);
    
    % Convert to Grayscale for Edge Detection
    gray = rgb2gray(art_img_adj);
    edges = edge(gray, 'Canny');
    if edgeThickness > 0
        edges = imdilate(edges, strel('disk', edgeThickness));
    end

    final_img = art_img_adj;
    for k = 1:3
        ch = final_img(:,:,k);
        ch(edges) = 0; 
        final_img(:,:,k) = ch;
    end
end