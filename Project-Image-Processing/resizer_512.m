% Define image directory
folder = "Project-Image-Processing/";
save_folder = "Project-Image-Processing/Resized/"; % Folder to save resized images

% Ensure save folder exists
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

% Read, Resize, and Save images
img_city = imresize(imread(fullfile(folder, "city-skyline-night.jpg")), [512, 512]);
imwrite(img_city, fullfile(save_folder, "city-skyline-night_resized.jpg"));

img_bird = imresize(imread(fullfile(folder, "toucan-bird.jpg")), [512, 512]);
imwrite(img_bird, fullfile(save_folder, "toucan-bird_resized.jpg"));

img_mountain = imresize(imread(fullfile(folder, "mountain-landscape.jpg")), [512, 512]);
imwrite(img_mountain, fullfile(save_folder, "mountain-landscape_resized.jpg"));

img_lion = imresize(imread(fullfile(folder, "lion-in-wild.jpg")), [512, 512]);
imwrite(img_lion, fullfile(save_folder, "lion-in-wild_resized.jpg"));

img_cabin = imresize(imread(fullfile(folder, "snowy-cabin.jpg")), [512, 512]);
imwrite(img_cabin, fullfile(save_folder, "snowy-cabin_resized.jpg"));

disp("All images resized and saved successfully!");




