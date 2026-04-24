Group Project
https://github.com/myriddle1101-boop/DVS-final-project
Yu Mi, Ruwen Li, Keyu Jiang
1.Introduction
This project aims to develop an image processing application called "Artify", which transforms photographs into artistic styles using computer vision techniques.
We implemented six styles: Pop Art, Swirl Art, Oil Painting, Ink Wash, Colored Pencil, and Mosaic.
The system takes an input image and applies different image processing techniques to generate artistic effects.

Pop Art: 
Our Pop Art stylization pipeline is inspired by the bold colors, high contrast, and graphic repetition seen in works by artists like Andy Warhol. The implementation focuses on simplifying visual content while amplifying color impact and edge definition:
Color Quantization & Posterization: We applied K-means clustering (imsegkmeans) to reduce the image into a small number of dominant colors. This creates the flat, posterized effect characteristic of Pop Art, where gradual shading is replaced with distinct color regions.


High Saturation & Contrast Enhancement: To achieve the vivid and eye-catching palette typical of Pop Art, we boosted saturation in the HSV color space and applied contrast stretching (imadjust). This enhances color intensity and ensures strong visual separation between regions.


Edge Detection & Bold Outlining: We extracted prominent edges using the Canny edge detector. These edges were then thickened using morphological dilation (imdilate) to create bold, comic-style outlines that define shapes clearly.


Halftone Effect Simulation: To mimic the printing techniques used in classic Pop Art, we generated halftone dot patterns by mapping intensity values to dot sizes. This was achieved using periodic sampling and thresholding, giving the image a retro, screen-printed appearance.


Multi-Panel Composition: Inspired by Warhol’s repeated imagery, the processed image can be duplicated into a grid layout with varying color mappings, producing a signature Pop Art collage effect.




Swirl Art:
The Swirl Art effect introduces dynamic, fluid distortions to the image, creating a sense of motion and abstraction reminiscent of expressionist and psychedelic art styles:
Coordinate Transformation & Swirl Distortion: We applied a non-linear coordinate mapping where pixel positions are rotated around a central point based on their radial distance. This swirl transformation creates a vortex-like distortion, with stronger effects near the center.


Radial Weighting Function: The degree of swirling is controlled by a radial function that decreases with distance from the center. This ensures a smooth transition between highly distorted central regions and relatively stable outer areas.


Interpolation & Resampling: Since pixel locations are remapped to non-integer coordinates, we used bilinear interpolation (interp2) to reconstruct the image smoothly, avoiding artifacts such as gaps or aliasing.


Color Enhancement & Smoothing: After geometric distortion, we enhanced saturation and applied slight Gaussian smoothing (imgaussfilt) to blend color transitions and reinforce the fluid, dream-like quality of the image.


Multi-Center Swirl: For more complex artistic effects, multiple swirl centers can be introduced, each with different strengths and radii. This produces layered distortions and a more chaotic, abstract composition.


Oil Painting: 
We have implemented an Oil Painting Stylization pipeline that simulates the thick texture and vibrant color palettes characteristic of classical oil masterpieces. Our approach moves beyond simple blurring by integrating several advanced image processing stages:
Color Saturation & Contrast Enhancement: We began by boosting the saturation in the HSV color space to mimic the rich pigments used in oil paints. Contrast stretching was applied as a final touch to ensure the visual depth of the artwork.
Edge-Preserving Smoothing: Before stylization, we used a Bilateral Filter (imbilatfilt) to remove photographic noise while strictly preserving sharp boundaries, ensuring the 'paint' doesn't look muddy.
Color Quantization via K-means Clustering: To simulate the limited palette of an artist, we applied K-means clustering (imsegkmeans) to group pixels into k dominant colors, effectively recreating the 'blocked-in' look of oil painting.
Stroke Simulation via Morphological Opening: We used morphological opening with line-structuring elements (strel('line')) at multiple angles. This simulates the physical direction of brushstrokes and gives the image a non-photographic, painterly texture.
Relief & Lighting Effects: By calculating the image gradient (lightness variation), we generated a relief map that was overlaid onto the image. This creates the 'impasto' illusion—the appearance of thick, 3D paint layers on a canvas."
Ink Wash:
Ink Diffusion Simulation: To recreate the effect of ink spreading on absorbent rice paper, we applied a Gaussian Low-pass Filter (imgaussfilt). By adjusting the blur_sigma, we can control the degree of 'bleeding' or tonal softness, transforming sharp photographic edges into smooth, misty gradients.
Edge Extraction via Gradient Analysis: Traditional ink paintings rely on expressive brush outlines. We utilized the Sobel Gradient operator (imgradient) to calculate the magnitude of intensity changes. By inverting this gradient map, we successfully simulated 'dry brush' strokes, where high-contrast edges are rendered as dark ink lines.
Tone Manipulation & 'The Five Colors of Ink': In Chinese art, variation in ink density is crucial. We used Contrast Stretching (imadjust and stretchlim) to map the grayscale values into a range that emphasizes deep blacks and delicate grays, effectively simulating the 'Five Colors of Ink' theory.
Paper Tinting: To avoid a sterile 'digital' look, we introduced a paper_tint parameter to shift the white point, mimicking the natural, off-white tone of aged Xuan paper."

Colored Pencil: 
Color Enhancement: We utilized HSV color space manipulation and contrast stretching (imadjust) to create the vibrant base required for artistic styles.
Directional Hatching Texture: Instead of static textures, we used morphological dilation with a line-structuring element (strel('line')) on random noise to simulate realistic, hand-drawn pencil strokes.
Adaptive Edge Outlining: We implemented a Canny edge detector to extract structural details, followed by morphological dilation to control stroke thickness, ensuring the 'sketch' has defined boundaries."
Mosaic: 
Color Quantization: To simulate the limited set of stone or glass tiles available to a mosaic artist, we used K-means clustering (kmeans) in the HSV and RGB color spaces. This reduces the image’s color depth to a user-defined color_count, ensuring each 'tile' belongs to a distinct palette.
Block-based Tiling: To create the physical structure of tiles, we utilized Nearest Neighbor interpolation via imresize. By downsampling the image and then upscaling it back to its original dimensions, we achieved a uniform grid of blocks (tiles), where each block represents the average color of its corresponding area.
Grout Line Generation: To separate the tiles, we extracted the boundaries using Gradient Analysis (imgradientxy). We then applied Morphological Dilation (imdilate) with a square structuring element to thicken these boundaries, creating realistic 'grout lines' or gaps between the tiles.
Color Vibrancy & Contrast Adjustment: Mosaic art is known for its vividness. We boosted the Saturation channel in the HSV space and applied a final Contrast Stretch (imadjust) to make the colors pop, mimicking the reflective properties of glass tiles.

2. How to run and the results
2.1 Project Architecture and File Structure
Overview of System Design
The software architecture for this project is designed to balance integrated visualization with independent modular debugging. The repository is organized into three distinct tiers: the main execution entry, the functional back-end, and individual test scripts.
Main Execution Entry
test_final.m: This is the core master script of the project. Executing this file triggers the full pipeline, sequentially calling all six artistic transformation algorithms. It culminates in an optimized 2x3 subplot gallery, providing a comprehensive side-by-side comparison of the diverse visual outputs.
Encapsulated Style Functions
These files contain the underlying algorithmic logic, encapsulated as standard MATLAB functions to ensure reusability and clean code integration.
applyPopArt.m / applySwirlPopArt.m: Handles color quantization and geometric warping logic.
oil_paint_style.m: Implements K-means clustering and relief texture mapping.
ink_style.m: Manages Gaussian-based ink diffusion and edge weighting.
pencil_sketch_style.m: Executes adaptive hatching and texture filtering.
applyMosaicStyle.m: Processes grid-based quantization and boundary morphology.
Individual Style Test Scripts
For targeted development or high-resolution single-style output, the following standalone scripts are provided. Each script is pre-configured with optimized parameters for its respective style:
ink_test.m / oilpainting_test.m / pop_art.m / pencil_test.m / mosaic.m : Running these scripts allows the user to debug a specific style in isolation without the overhead of the full 2x3 gallery.
2.2 Running steps
1. Environment Setup
Software: Requires MATLAB (R2021b or later) with the Image Processing Toolbox installed.
File Organization: Ensure the main script test_final.m and all auxiliary function files are stored in the same working directory to maintain dependency links.
2. Image Path Configuration
Set Source: Open test_final.m and locate the imread command
Update Path: Replace the placeholder string with the specific path to your input image.
3. Detailed Parameter Tuning
Users can customize the artistic output by modifying the following arguments within the script:
Color Quantization (k / levels): Controls the complexity of the palette. Lowering these values simplifies the image into iconic color blocks, characteristic of Pop Art.
Spatial Filtering (b_sigma / blur): Adjusts the degree of "ink bleeding" or smoothing. Higher sigma values produce a more ethereal, diffused Ink Wash effect.
Artistic Texture (tile_size / s_len): Controls the physical scale of the style elements. For example, increasing tile_size generates larger mosaic pieces, while s_len dictates the length of simulated oil paint brushstrokes.
Contrast & Saturation (vibrancy / gamma): Fine-tunes the visual pop of the result. imadjust logic is often applied internally to ensure the output utilizes the full dynamic range.
4. Execution and Output
The script generates a comprehensive 2x3 subplot gallery, allowing for an immediate side-by-side qualitative comparison of all implemented algorithms.
2.3 Test results
2.3.1 Pop Art


2.3.2  Swirl Art




2.3.3 Oil Painting


2.3.4 Ink Wash


2.3.5 Colored Pencil

2.3.6. Mosaic


2.3.7 Overall effects
 
3. Evaluation
3.1 Pop Art
What it can do:
The Pop Art implementation effectively transforms images into bold, high-contrast artworks with simplified color regions. By applying K-means clustering, it reduces complex color gradients into a limited palette, creating a strong posterized effect, while HSV-based saturation enhancement and contrast stretching make the colors vivid and visually striking. Edge detection using the Canny operator combined with morphological dilation produces thick, clear outlines that emphasize object boundaries, and the halftone simulation further adds a retro, print-like aesthetic.
What it cannot do:
The approach relies on global color quantization, which may lead to loss of fine details and subtle tonal variations, making some regions overly simplified. The halftone effect is only an approximation and lacks the natural irregularities of real printing, and the edge outlines are uniform without artistic variation. Overall, the method prioritizes strong visual impact over detail preservation and realism.

3.2 Swirl Art
What it can do:
The Swirl Art implementation introduces dynamic geometric distortions through radial coordinate transformation, creating a vortex-like visual effect. The use of a radial weighting function ensures smooth transitions between distorted and undistorted regions, while bilinear interpolation maintains image continuity without major artifacts. Additional color enhancement and Gaussian smoothing help produce a fluid and abstract appearance, and adjustable parameters allow flexible control over the strength and style of the effect.
What it cannot do:
Because the transformation is purely mathematical and lacks semantic awareness, all regions are distorted equally, which can make important objects difficult to recognize. Strong swirl effects may also reduce fine details and texture, and the method is limited to a single transformation model, restricting the diversity of artistic outcomes.

3.3 Oil Painting
What it can do:
The oil painting implementation is highly effective at transforming a standard photograph into a stylized piece that mimics the "Impasto" technique (thick application of paint). 
Abstraction through Color Quantization: By utilizing K-means clustering, the algorithm successfully simplifies the complex color continuous gradients of a photo into a finite set of artistic palettes. This replicates how an artist blocks in colors on a canvas.
Edge-Preserving Stylization: The use of a Bilateral Filter ensures that while the interior of color regions is smoothed to look like paint, the critical boundaries of objects remain sharp, preventing the "blurry photo" look common in simpler filters.
Simulated Surface Texture: The core strength lies in the Morphological Opening using directional line elements. This successfully re-shapes the clustered color regions into brush-like strokes.
Visual Depth and "Impasto" Effect: By calculating Image Gradients and overlaying them as a relief map, the algorithm creates a convincing 3D illusion of paint thickness and light interaction on the canvas surface.
What it cannot do:
Fixed Stroke Direction: The current implementation uses two fixed angles for morphological operations. Real oil paintings feature strokes that follow the "flow" or contours of the objects (e.g., curved strokes for a face), which this global approach cannot replicate.
Computational Complexity: The K-means clustering stage (imsegkmeans) is computationally expensive. Processing high-resolution images can lead to significant delays, making it less suitable for real-time applications compared to simpler convolution-based filters.
Loss of Fine Semantic Detail: Because the color quantization and smoothing are aggressive, small but important details (such as the catchlight in an eye or fine text) may be merged into larger color blocks and lost entirely.
Lack of Pigment Blending: The algorithm treats colors as discrete clusters. It does not simulate the physical "wet-on-wet" blending of oil paints where two colors transition into each other through physical mixing.
The algorithm strikes a strong balance between color manipulation and structural modification. While it excels at creating the atmospheric and textural feel of a traditional oil painting, it remains a procedural approximation that lacks the adaptive brushwork and physical pigment modeling of a human artist.

3.4 Ink Wash
What it can do: 
The ink wash implementation is effective at simulating the key visual characteristics of traditional ink painting, particularly the combination of soft tonal diffusion and expressive brush-like outlines. The use of Gaussian filtering produces smooth intensity transitions that resemble ink spreading on absorbent paper, while gradient-based edge extraction preserves structural information in a natural way.
The method works well on images with clear foreground-background separation and moderate detail. It is especially effective for landscapes or portraits where large tonal regions can be simplified into soft gradients.
The parameterized design also allows flexible control over diffusion strength, edge sharpness, and overall tone, enabling users to adjust the level of abstraction.

What it cannot do:
First, it relies heavily on global parameters, which makes it difficult to achieve consistent results across different types of images. Images with complex textures or high-frequency details may appear overly blurred or lose important structures.
Second, the edge extraction is based on simple gradient information, which cannot fully capture the richness of real brush strokes, such as varying stroke width, ink density, or calligraphic variation.
In addition, the method does not model paper texture explicitly, so the final result lacks the subtle surface irregularities seen in real ink wash paintings.

Overall, while the approach captures the general aesthetic, it simplifies many physical and artistic aspects of traditional ink painting.

3.5 Colored Pencil
What it can do:
The colored pencil implementation successfully captures several important characteristics of hand-drawn pencil artwork, including directional hatching, enhanced color saturation, and adaptive colored outlines. The use of directional morphological operations enables the generation of structured stroke patterns, which significantly improves the perceived realism compared to simple filtering methods.
The approach is particularly effective for images with distinct color regions, where the hatching texture can follow the underlying color distribution. The use of color-modulated strokes and non-black outlines also enhances visual coherence, making the result appear more natural and less artificial.
Furthermore, the parameterized design allows control over stroke direction, intensity, and outline thickness, providing flexibility in adjusting the artistic style.

What it cannot do:
The generated hatching texture is based on procedural noise, which may appear repetitive or less natural compared to real hand-drawn strokes.
The approach also assumes a single dominant stroke direction, whereas real pencil drawings often involve multiple overlapping stroke directions and varying pressure.
In addition, edge detection using Canny produces clean but uniform outlines, which lack the subtle variation in thickness and pressure found in real sketches.
Similar to the ink wash method, the performance is sensitive to parameter settings. A configuration that works well for one image may not generalize to others, especially images with complex textures or lighting conditions.

Overall, while the method captures the key visual cues of colored pencil drawings, it remains a simplified approximation of real artistic processes.
3.6 Mosaic
What it can do:
Geometric Precision: The algorithm excels at creating a perfectly aligned, mathematical grid that is synonymous with modern digital mosaic art.
Color Cohesion: By using global K-means clustering, the output maintains a consistent color theme that feels intentional and artistic rather than accidental.
Structural Clarity: The use of morphological dilation for grout lines ensures that the 'tiled' nature of the image is clearly visible even from a distance.
What it cannot do:
Irregular Tiling: Real historical mosaics often use "Opus Tessellatum" (irregularly shaped or hand-cut tiles). Our current grid is strictly rectangular and lacks the organic feel of hand-placed tiles.
Content-Aware Sizing: The tile size is uniform across the entire image. In professional mosaics, artists often use smaller tiles for detailed areas (like faces) and larger tiles for backgrounds.
Texture of Tiles: The tiles are rendered as flat colors. The algorithm does not currently model the internal texture, reflections, or "cracks" found in real stone or ceramic tiles.


