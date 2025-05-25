function V = IDW(x, y, v, X, Y, K)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Function: Inverse Distance Weighted (IDW) algorithm for scattered data surface interpolation
% Inputs:
%   x, y, v -- Vectors of scattered data points
%   X, Y -- Vectors or matrices of coordinates for unknown points
%   K -- Number of points to be used in the weighting calculation
% Outputs:
%   V -- Vector or matrix of values for the unknown points
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%%
%N = length(x);  % Number of scattered points
M = numel(X); % Number of unknown points
%d = zeros(N,1); % Distances from each scattered point (xi, yi) to the unknown point (Xj, Yj)
%w = d; % Weights of each scattered point (xi, yi) for the unknown point (Xj, Yj)
V = zeros(size(X)); % Values of the unknown points, Z(X, Y)
%%
epsilon = 1e-5; % Tolerance for comparison with zero
for j = 1:M  % Loop through all unknown points
    % Calculate the distances from each scattered point (xi, yi) to the unknown point (Xj, Yj)
    dx = x - X(j);  
    dy = y - Y(j);
    dist = dx.^2 + dy.^2; % or sqrt(dx.^2 + dy.^2);
    % Find the K nearest points
    [dist, IX] = sort(dist, 'ascend'); % Sort in ascending order
    d = dist(1:K);  % The K smallest distances  
    if any(d) <= epsilon % Special case handling
        V(j) = v(IX(1));
    else
        w = 1 ./ d; % Calculate the weights for these K points
        D = sum(w); % Sum of weights
        V(j) = sum(w .* v(IX(1:K))) / D; % Calculate the value for the unknown point
        % IX(1:K) is the index vector of these K points in the sample sequence
    end
end
end