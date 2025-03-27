clc; clear; close all;

% Define directories
resized_folder = "F:/Matlab/Project-Image-Processing/Resized/"; % Folder with resized images
labels = ["City", "Bird", "Mountain", "Lion", "Cabin"]; % Scene categories

% Get image files
image_files = dir(fullfile(resized_folder, '*.jpg'));
num_images = length(image_files);

% Feature storage
features = [];
class_labels = [];

% ---------------- FEATURE EXTRACTION ---------------- %
for i = 1:num_images
    % Read image
    img_path = fullfile(resized_folder, image_files(i).name);
    img = imread(img_path);
    
    % Convert to grayscale for texture analysis
    gray_img = rgb2gray(img);

    % ---- 1. Color Histogram Feature ----
    color_hist = [];
    for channel = 1:3 % Extract histograms from RGB channels
        hist_vals = imhist(img(:,:,channel), 16); % 16 bins per channel
        color_hist = [color_hist; hist_vals(:)];
    end
    color_hist = color_hist / sum(color_hist); % Normalize

    % ---- 2. Texture Feature (GLCM) ----
    glcm = graycomatrix(gray_img, 'Offset', [0 1; -1 1; -1 0; -1 -1]); % Co-occurrence matrix
    stats = graycoprops(glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
    texture_features = [stats.Contrast, stats.Correlation, stats.Energy, stats.Homogeneity];

    % Combine features
    image_features = [color_hist; texture_features(:)];
    features = [features; image_features']; % Store in feature matrix

    % Assign class label (based on filename)
    for j = 1:length(labels)
        if contains(image_files(i).name, lower(labels(j)))
            class_labels = [class_labels; j]; % Store class index
            break;
        end
    end
end

% Convert to table for classification
feature_table = array2table(features);
feature_table.Label = categorical(class_labels);

% ---------------- TRAIN CLASSIFIERS ---------------- %

% Train Multi-Class SVM using fitcecoc
SVMModel = fitcecoc(features, class_labels);

% Train K-Nearest Neighbors (KNN)
KNNModel = fitcknn(features, class_labels, 'NumNeighbors', 3);

% ---------------- TEST CLASSIFICATION ---------------- %
% Example: Classify a new image
test_img = imread(fullfile(resized_folder, image_files(1).name)); % Change test image if needed
test_gray = rgb2gray(test_img);

% Extract features for test image
test_hist = [];
for channel = 1:3
    hist_vals = imhist(test_img(:,:,channel), 16);
    test_hist = [test_hist; hist_vals(:)];
end
test_hist = test_hist / sum(test_hist);

test_glcm = graycomatrix(test_gray, 'Offset', [0 1; -1 1; -1 0; -1 -1]);
test_stats = graycoprops(test_glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
test_texture = [test_stats.Contrast, test_stats.Correlation, test_stats.Energy, test_stats.Homogeneity];

% Combine features for prediction
test_features = [test_hist; test_texture(:)]';

% Predict using SVM (Multi-Class)
predicted_label_SVM = predict(SVMModel, test_features);
disp("SVM Predicted Class: " + labels(predicted_label_SVM));

% Predict using KNN
predicted_label_KNN = predict(KNNModel, test_features);
disp("KNN Predicted Class: " + labels(predicted_label_KNN));
