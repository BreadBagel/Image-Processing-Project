clc; clear; close all;

% Load a segmented image (Example: Choose an image from your dataset)
img_path = "Project-Image-Processing/Resized/city-skyline-night_resized.jpg";
img = imread(img_path);
img_gray = rgb2gray(img); % Convert to grayscale

% ---------------- SEGMENTATION ---------------- %
% Apply edge detection (Canny)
edges = edge(img_gray, 'Canny');

% Apply K-means clustering for segmentation
num_clusters = 3; % Define number of clusters
[rows, cols, ~] = size(img);
reshaped_img = double(reshape(img, rows * cols, 3));
[idx, centroids] = kmeans(reshaped_img, num_clusters, 'Replicates', 3);
segmented_img = reshape(idx, rows, cols);

% Morphological operations to enhance edges
segmented_img = medfilt2(segmented_img, [3 3]); % Apply median filter
segmented_img = imfill(segmented_img, 'holes'); % Fill holes

% ---------------- OBJECT DETECTION ---------------- %
% Detect objects using connected component analysis
CC = bwconncomp(segmented_img); % Get connected components
stats = regionprops(CC, 'BoundingBox', 'Centroid', 'Area');

% ---------------- VISUALIZATION ---------------- %
figure;

% 1. Original Image
subplot(1, 3, 1);
imshow(img);
title('Original Image');

% 2. Segmented Image with Different Colors
subplot(1, 3, 2);
colored_labels = label2rgb(segmented_img, 'jet', 'k', 'shuffle'); % Assign colors
imshow(colored_labels);
title('Segmented Image (K-means)');

% 3. Overlay Segmentation & Bounding Boxes
subplot(1, 3, 3);
imshow(img);
hold on;

for i = 1:length(stats)
    % Draw bounding box
    rectangle('Position', stats(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);

    % Draw centroid
    plot(stats(i).Centroid(1), stats(i).Centroid(2), 'go', 'MarkerSize', 10, 'LineWidth', 2);
    
    % Display object label
    text(stats(i).Centroid(1) + 5, stats(i).Centroid(2), ...
        sprintf('Obj %d', i), 'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');
end

title('Object Detection (Bounding Boxes)');
hold off;
