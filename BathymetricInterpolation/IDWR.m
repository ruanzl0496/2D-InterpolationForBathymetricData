function V = IDWR(x, y, v, X, Y, K)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Scattered Data Surface Interpolation using Inverse Distance Weighted Regression (IDWR) Algorithm
% Inputs:
%   x, y, v -- Vectors of scattered data points
%   X, Y -- Vectors or matrices of coordinates for unknown points
%   K -- Number of points to be used in the weighted calculation
% Outputs:
%   V -- Vector or matrix of values for unknown points
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%%
% N = length(x);  % Number of scattered points
M = numel(X); % Number of unknown points
%d = zeros(N,1); % Distances from each scattered point (xi, yi) to the unknown point (Xj, Yj)
%w = d; % Weights of each scattered point (xi, yi) for the unknown point (Xj, Yj)
V = zeros(size(X)); % Values of unknown points Z(X, Y)
%%
epsilon = 1e-5; % Tolerance for comparison with zero
for j = 1:M  % Loop through all unknown points
    % Calculate the distances from each scattered point (xi, yi) to the unknown point (Xj, Yj)
    dx = x - X(j);  dy = y - Y(j);
    % dist = sqrt(dx.*dx + dy.*dy);
    dist = (dx.^2 + dy.^2);  % Squared distances
    % Find the K closest points
    [dist, IX] = sort(dist, 'ascend'); % Sort in ascending order
    d = dist(1:K);  % IX(1:K) is the index vector of these K points in the sample sequence  
    if any(d) <= epsilon % Special case handling
        V(j) = v(IX(1));
    else
        w = 1 ./ d; % Calculate the weights of these K points for the unknown point (Xj, Yj)
        D = sum(w); % Sum of weights
        y_IDW = sum(w .* v(IX(1:K))) / D; % Calculate the IDW value for the unknown point
        V(j) = y_IDW + K * (sum(v(IX(1:K))) - K * y_IDW ) / (K^2 - sum(d) * D);
    end
end
end