clc; clear; close all;

% Define directories
folder = "F:/Matlab/Project-Image-Processing/Resized/";
save_folder = "F:/Matlab/Project-Image-Processing/Segmented/";

% Ensure save folder exists
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

% List of image files
image_files = dir(fullfile(folder, '*.jpg')); % Adjust extension if needed

% Loop through each image for segmentation
for i = 1:length(image_files)
    % Read image
    img_path = fullfile(folder, image_files(i).name);
    img = imread(img_path);
    
    % --------------------- 1. COLOR SEGMENTATION --------------------- %
    hsv_img = rgb2hsv(img); % Convert to HSV
    ycbcr_img = rgb2ycbcr(img); % Convert to YCbCr

    % Define threshold for segmentation (example: extracting red objects)
    red_mask = (hsv_img(:,:,1) > 0.0 & hsv_img(:,:,1) < 0.1) & ... % Hue range
               (hsv_img(:,:,2) > 0.5 & hsv_img(:,:,2) < 1.0) & ... % Saturation
               (hsv_img(:,:,3) > 0.3 & hsv_img(:,:,3) < 1.0);  % Value

    % Morphological processing to refine segmentation
    red_mask = imfill(red_mask, 'holes');
    red_mask = bwareaopen(red_mask, 200); % Remove small noise

    % Apply mask to original image
    segmented_color = img;
    segmented_color(repmat(~red_mask, [1 1 3])) = 0;

    % --------------------- 2. EDGE DETECTION --------------------- %
    gray_img = rgb2gray(img); % Convert to grayscale
    edges_sobel = edge(gray_img, 'sobel');
    edges_canny = edge(gray_img, 'canny');
    edges_prewitt = edge(gray_img, 'prewitt');

    % Morphological enhancement
    se = strel('disk', 2);
    enhanced_edges = imdilate(edges_canny, se); % Dilate edges

    % --------------------- 3. CLUSTERING SEGMENTATION (K-MEANS) --------------------- %
    % Reshape image into 2D array for clustering
    img_reshaped = double(reshape(img, [], 3));
    
    % Apply K-means clustering
    num_clusters = 3; % Number of clusters
    [cluster_idx, cluster_centers] = kmeans(img_reshaped, num_clusters, 'Replicates', 3);
    
    % Reconstruct clustered image
    clustered_img = reshape(cluster_centers(cluster_idx, :), size(img));

    % Convert to binary mask for noise removal
    binary_clustered = imbinarize(rgb2gray(uint8(clustered_img))); 
    cleaned_cluster = bwareaopen(binary_clustered, 500);

    % --------------------- SAVE OUTPUT IMAGES --------------------- %
    [~, name, ~] = fileparts(image_files(i).name); % Get filename without extension

    imwrite(segmented_color, fullfile(save_folder, name + "_color_seg.jpg"));
    imwrite(edges_canny, fullfile(save_folder, name + "_edges.jpg"));
    imwrite(cleaned_cluster, fullfile(save_folder, name + "_kmeans.jpg"));

    % Display results
    figure;
    subplot(2,3,1), imshow(img), title('Original Image');
    subplot(2,3,2), imshow(segmented_color), title('Color Segmentation');
    subplot(2,3,3), imshow(edges_canny), title('Canny Edge Detection');
    subplot(2,3,4), imshow(clustered_img, []), title('K-means Clustering');
    subplot(2,3,5), imshow(cleaned_cluster), title('Noise Removed Clusters');
end

disp("Segmentation completed and images saved!");
