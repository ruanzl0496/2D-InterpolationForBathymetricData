function newImg = IDW_img(img, scale)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Function: Inverse Distance Weighted (IDW) Interpolation for Scaling Matrices or Images
% Input:    img--The original image file name or matrix
%           scale--Scaling factor, i.e., the multiple for scaling. If it is a vector, then [scaleX, scaleY]
% Output:   newImg--The scaled image matrix 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%% Step1: Preprocess the data
if ~exist('img', 'var') || isempty(img)
    error('The input image img is not defined or is empty!');
end
if ~exist('scale', 'var') || isempty(scale) || numel(scale) > 2
    error('The scale vector is not defined, is empty, or contains more than 2 elements!');
end
if isstr(img)
    [img, M] = imread(img);
end
if any(scale) <= 0
    error('The scaling factor scale must be greater than 0!');
end

%% Step2: Determine the size of the new image based on the original image and scaling factor, and create the new image
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
% Recalculate the scaling factors. Note that the input scaling factors represent the ratio of pixel counts, while the distance between the first and last pixels on the coordinate axis is one less than the number of pixels.
scaleX = (newWidth - 1) / (width - 1);
scaleY = (newHeight - 1) / (height - 1);

%% Step3: Expand the edges of the image by adding one row at the bottom and one column on the right to facilitate calculations for boundary pixels
imgEx = zeros(height + 1, width + 1, channel); 
imgEx(1:height, 1:width, :) = img; % Copy the original image to the expanded image
imgEx(height + 1, 1:width, :) = img(height, :, :); % Copy the last row of the original image to the last row of the expanded image
imgEx(1:height, width + 1, :) = img(:, width, :); % Copy the last column of the original image to the last column of the expanded image
imgEx(height + 1, width + 1, :) = img(height, width, :); % Copy the bottom-right pixel of the original image to the bottom-right pixel of the expanded image

%% ============================================================
% Step4: Map the pixel (j, i) in the new image to the position (u1, v1) in the original image, and interpolate the pixel value at (u1, v1) using its surrounding four pixels
% The four surrounding points are: Top-left (u, v), Top-right (u + 1, v),
%                                  Bottom-left (u, v + 1), Bottom-right (u + 1, v + 1)
% % ====================================================================
epsilon = 1e-5; % Tolerance for comparison with zero
for j = 1:newWidth % Scan the image column by column
    u1 = (j - 1) / scaleX + 1;
    u = floor(u1);
    dx = u1 - u; % For pixels in the same column, v1, v, and dx are fixed, so they do not need to be recalculated in the inner loop
    a = dx * dx; c = (1 - dx) * (1 - dx);
    for i = 1:newHeight
        % (j, i) represents the coordinates in the new image, while (u1, v1) represents the coordinates in the original image
        % Note: (u1, v1) may not be integers
        v1 = (i - 1) / scaleY + 1; 
        v = floor(v1); 
        dy = v1 - v;
        
        % Inverse distances to the surrounding four points
        b = dy * dy; d = (1 - dy) * (1 - dy); 
        
        if b + a <= epsilon % Special case handling
            newImg(i, j, :) = imgEx(v, u, :);
        elseif d + a <= epsilon
            newImg(i, j, :) = imgEx(v, u + 1, :);
        elseif b + c <= epsilon
            newImg(i, j, :) = imgEx(v + 1, u, :);
        elseif d + c <= epsilon
            newImg(i, j, :) = imgEx(v + 1, u + 1, :);
        else % General case handling
            w11 = 1 / sqrt(a + b); % Inverse distance from (u1, v1) to the top-left point (u, v)
            w12 = 1 / sqrt(b + c); % Inverse distance from (u1, v1) to the top-right point (u + 1, v)
            w21 = 1 / sqrt(a + d); % Inverse distance from (u1, v1) to the bottom-left point (u, v + 1)
            w22 = 1 / sqrt(c + d); % Inverse distance from (u1, v1) to the bottom-right point (u + 1, v + 1)
            D = w11 + w12 + w21 + w22; % Sum of inverse distances
            newImg(i, j, :) = (w11 * imgEx(v, u, :) + w12 * imgEx(v, u + 1, :)...
                + w21 * imgEx(v + 1, u, :) + w22 * imgEx(v + 1, u + 1, :)) / D; % Inverse Distance Weighting (IDW)
        end
        
    end
end
newImg = uint8(newImg);

end