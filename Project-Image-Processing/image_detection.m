clc; clear; close all;

% Define directories
segmented_folder = "F:/Matlab/Project-Image-Processing/Segmented/";
save_folder = "F:/Matlab/Project-Image-Processing/Object_Detection/";

% Ensure save folder exists
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

% Get all segmented images (assuming they are binary masks)
image_files = dir(fullfile(segmented_folder, '*_kmeans.jpg')); % Change pattern if needed

% Loop through each segmented image for object detection
for i = 1:length(image_files)
    % Read segmented binary image
    img_path = fullfile(segmented_folder, image_files(i).name);
    binary_img = imread(img_path);
    
    % Convert to binary (if needed)
    if size(binary_img, 3) == 3
        binary_img = rgb2gray(binary_img);
    end
    binary_img = imbinarize(binary_img); % Ensure it's binary

    % --------------------- OBJECT DETECTION --------------------- %
    % Connected Component Analysis
    CC = bwconncomp(binary_img); % Identify connected components
    stats = regionprops(CC, 'Centroid', 'Area', 'BoundingBox'); % Get object properties

    % Create overlay image
    labeled_img = label2rgb(labelmatrix(CC), 'jet', 'k', 'shuffle');

    % Display results
    figure;
    imshow(labeled_img); hold on;
    title('Object Detection - Connected Components');

    % Loop through detected objects
    for j = 1:length(stats)
        centroid = stats(j).Centroid;
        bbox = stats(j).BoundingBox;
        
        % Draw bounding box
        rectangle('Position', bbox, 'EdgeColor', 'r', 'LineWidth', 2);
        
        % Plot centroid
        plot(centroid(1), centroid(2), 'bo', 'MarkerSize', 5, 'LineWidth', 2);

        % Display area value
        text(centroid(1), centroid(2), sprintf('%.0f px', stats(j).Area), ...
             'Color', 'yellow', 'FontSize', 10, 'FontWeight', 'bold');
    end
    hold off;

    % Save labeled image
    [~, name, ~] = fileparts(image_files(i).name);
    save_path = fullfile(save_folder, name + "_detected.jpg");
    saveas(gcf, save_path); % Save figure as image
end

disp("Object detection completed and images saved!");
