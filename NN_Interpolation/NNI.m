function vq = NNI(x, y, v, xq, yq)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Function: Nearest neighbor algorithm for scattered data surface interpolation
% Inputs:
%   x, y, v -- Vectors of scattered data points
%   xq, yq -- Vectors or matrices of coordinates for unknown points
% Outputs:
%   vq -- Vector or matrix of interpolated values for the unknown points
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    xqLen = numel(xq); % Number of elements in xq
    xLen = numel(x); % Number of elements in x
    vq = zeros(size(xq)); % Initialize the output vector with zeros
    
    for i = 1:xqLen  % Loop through each query point (xqi, yqi)
        %% Step 1: Find the nearest point to (xqi, yqi)
        % dist = sqrt((xq(i)-x).^2 + (yq(i)-y).^2);  % 
        % Calculate the distance from (xqi, yqi) to each known point; 
        % Note: The square root is not necessary for comparison
        dist = (xq(i)-x).^2 + (yq(i)-y).^2;  % Calculate the squared distance from (xqi, yqi) to each known point
        dist_min = dist(1); % Initialize the minimum distance
        k = 1; % Index of the nearest point
        for j = 2:xLen
            if dist(j) < dist_min
                dist_min = dist(j); % Update the minimum distance
                k = j; % Update the index of the nearest point
            end
        end
        vq(i) = v(k); % Assign the value of the nearest point to the output
    end

end