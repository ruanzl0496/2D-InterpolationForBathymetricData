function newImg = nearest_img(img, scale)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Function: Nearest Neighbor Interpolation for scaling matrices or images
% Input:    img--Original image file name or matrix
%           scale--Scaling factor, i.e., the multiple for scaling. If it is a vector, then [scaleX, scaleY]
% Output:   newImg--Scaled image matrix
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%% Step 1: Preprocess the data
if ~exist('img', 'var') || isempty(img)
    error('The input image img is not defined or is empty!');
end
if ~exist('scale', 'var') || isempty(scale) || numel(scale) > 2
    error('The scaling factor scale is not defined, is empty, or contains more than 2 elements!');
end
if isstr(img)
    [img, M] = imread(img);
end
if any(scale) <= 0
    error('The scaling factor scale must be greater than 0!');
end

%% Step 2: Determine the size of the new image based on the original image and scaling factor, and create the new image
[height, width, channel] = size(img);
if length(scale) == 1  % Uniform scaling in both horizontal and vertical directions
    scaleX = scale;
    scaleY = scale;
else
    scaleX = scale(1);
    scaleY = scale(2);
end
newHeight = round(height * scaleY); % Calculate the height of the scaled image, rounded to the nearest integer
newWidth = round(width * scaleX); % Calculate the width of the scaled image, rounded to the nearest integer
newImg = zeros(newHeight, newWidth, channel); % Create the new image
% Recalculate the scaling factors. Note that the input scaling factors refer to the ratio of pixel counts, while the distance between the first and last pixels on the coordinate axis is one less than the number of pixels.
scaleX = (newWidth - 1) / (width - 1);
scaleY = (newHeight - 1) / (height - 1);

%% Step 3: Nearest Neighbor Interpolation
for j = 1:newWidth         % Scan the image column-wise. Note that column-wise scanning is more efficient in MATLAB, as it stores data in column-major order!
    v = round((j - 1) / scaleX + 1);
    for i = 1:newHeight % For each element in the current column
        u = round((i - 1) / scaleY + 1); % Round to the nearest integer
        newImg(i, j, :) = img(u, v, :);  % Map the pixel value
    end
end

newImg = uint8(newImg);

end