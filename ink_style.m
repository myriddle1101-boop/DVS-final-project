function out = ink_style(img, blur_sigma, edge_weight, paper_tint)
    % ink_style: Simulates traditional Eastern Ink Wash (Shui-mo) painting
    % using Gaussian diffusion and gradient-based brushstroke emulation.
    if nargin < 2, blur_sigma = 8; end    % Degree of ink diffusion (spreading)
    if nargin < 3, edge_weight = 0.4; end % Intensity of the "dry brush" outlines
    if nargin < 4, paper_tint = 0.9; end  % Base tone of the rice paper (Xuan paper)


    % 1. Pre-processing
    if size(img, 3) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end
    img_db = im2double(gray);

    % 2. Simulate Ink Diffusion
    ink_diffused = imgaussfilt(img_db, blur_sigma);

    % 3. Extract "Dry Brush" Outlines
    [dx, dy] = imgradientxy(img_db);
    [mag, ~] = imgradient(dx, dy);
    % Inverse Intensity Mapping: Areas with high gradients (strong edges)
    ink_edges = max(0, min(1, 1 - (mag * edge_weight)));

    % 4. Composition and Tonal Adjustment
    res = ink_diffused .* ink_edges;
    res = res * paper_tint;
    
    % Final Contrast Stretching
    out = imadjust(res, stretchlim(res, [0.05 0.95]), []);
end