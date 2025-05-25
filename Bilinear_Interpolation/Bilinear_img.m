function newImg = Bilinear_img(img, scale)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Function: Bilinear interpolation for scaling matrices or images
% Input:    img -- Original image file name or matrix
%           scale -- Scaling factor, i.e., the multiple of scaling. If a vector, [scaleX, scaleY]
% Output:   newImg -- Scaled image matrix
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%% Step 1: Preprocess the data
if ~exist('img', 'var') || isempty(img)
    error('The input image "img" is undefined or empty.');
end
if ~exist('scale', 'var') || isempty(scale) || numel(scale) > 2
    error('The scaling vector "scale" is undefined, empty, or contains more than two elements.');
end
if isstr(img)
    [img, M] = imread(img);
end
if any(scale) <= 0
    error('The scaling factor "scale" must be greater than 0.');
end

%% Step 2: Determine the size of the new image based on the original image and scaling factor, and create the new image
[height, width, channel] = size(img);
if length(scale) == 1
    scaleX = scale;
    scaleY = scale;
else
    scaleX = scale(1);
    scaleY = scale(2);
end
newHeight = round(height * scaleY); % Calculate the height of the scaled image, rounded to the nearest integer
newWidth = round(width * scaleX); % Calculate the width of the scaled image, rounded to the nearest integer
newImg = zeros(newHeight, newWidth, channel); % Create the new image
% Recalculate the scaling factors. Note: The input scaling factors represent the ratio of pixel counts, while the distance between the first and last pixels on the coordinate axis is one less than the number of pixels.
scaleX = (newWidth - 1) / (width - 1);
scaleY = (newHeight - 1) / (height - 1);

%% Step 3: Expand the image edges by adding one row at the bottom and one column on the right to facilitate calculations for boundary pixels
imgEx = zeros(height + 1, width + 1, channel);
imgEx(1:height, 1:width, :) = img; % Copy the original image to the expanded image
imgEx(height + 1, 1:width, :) = img(height, :, :); % Copy the last row of the original image to the last row of the expanded image
imgEx(1:height, width + 1, :) = img(:, width, :); % Copy the last column of the original image to the last column of the expanded image
imgEx(height + 1, width + 1, :) = img(height, width, :); % Copy the bottom-right pixel of the original image to the bottom-right pixel of the expanded image

%% ============================================================
% Step 4: Map the pixel (j, i) in the new image to the position (u1, v1) in the original image, and interpolate the pixel value at (u1, v1) using the surrounding four pixels
% The four surrounding pixels are:
% Top-left: (u, v), Top-right: (u+1, v)
% Bottom-left: (u, v+1), Bottom-right: (u+1, v+1)
% % ====================================================================
for j = 1:newWidth % Scan the image column by column
    u1 = (j - 1) / scaleX + 1;
    u = floor(u1);
    dx = u1 - u; % For pixels in the same column, u1, v1, and dx are constant and do not need to be recalculated in the inner loop
    for i = 1:newHeight
        % (i, j) represents the coordinates in the new image, while (u1, v1) represents the coordinates in the original image
        % Note: (u1, v1) may not be integers
        v1 = (i - 1) / scaleY + 1;
        v = floor(v1);
        dy = v1 - v;

        % Interpolate in the x-direction
        t1 = dx;
        t2 = dx;
        Z1 = imgEx(v, u, :) + t1 * (imgEx(v, u + 1, :) - imgEx(v, u, :));
        Z2 = imgEx(v + 1, u, :) + t2 * (imgEx(v + 1, u + 1, :) - imgEx(v + 1, u, :));
        % Interpolate in the y-direction
        t = dy;
        newImg(i, j, :) = Z1 + t * (Z2 - Z1);
    end
end
newImg = uint8(newImg);
end