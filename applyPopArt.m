function final_img = applyPopArt(img, levels, gamma, edgeThickness)
   % Ensure the image is in double precision for numerical processing
    if ~isa(img, 'double')
        img = im2double(img);
    end

    % Step 1: Bilateral Filtering 
    filtered = imbilatfilt(img, 0.1, 5);

    % Step 2: Color Quantization
    quantized = round(filtered * levels) / levels;

    % Step 3: Contrast Enhancement via Gamma Correction
    art_img_adj = imadjust(quantized, [], [], gamma);

    % Step 4: Edge Extraction
    gray = rgb2gray(art_img_adj);
    edges = edge(gray, 'Canny');
    if edgeThickness > 0
        edges = imdilate(edges, strel('disk', edgeThickness));
    end

   % Step 5: Edge Overlay
    final_img = art_img_adj;
    for k = 1:3
        ch = final_img(:,:,k);
        ch(edges) = 0; 
        final_img(:,:,k) = ch;
    end
end