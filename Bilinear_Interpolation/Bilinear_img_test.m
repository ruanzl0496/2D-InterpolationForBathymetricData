clear;
close all;
clc;
%%

% Define the scaling factor
scale = [4, 2];

% Input file name
inFilename = 'squirrel.png';

% Split the file name to extract the base name and extension
tmp = strsplit(inFilename, '.');

% Generate the output file name based on the scaling factor
outFilename = sprintf('Bilinear_%s_x%s.%s', ...
    tmp{1}, strrep(num2str(scale), ' ', '_x'), tmp{2});

% Read the input image
img = imread(inFilename); 

% Scale the image using bilinear interpolation
img_new = Bilinear_img(img, scale); 

% Display the original and scaled images
imgShow(img, img_new); 

% Save the scaled image to a file
imwrite(img_new, outFilename); 