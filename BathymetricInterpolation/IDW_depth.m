function V = IDW_depth(x, y, z, X, Y)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Function: Interpolate water depth data on a rectangular grid to query points using the Inverse Distance Weighted (IDW) method.
% Inputs:
%   x, y, z -- Vectors of scattered bathymetric data points
%   X, Y -- Vectors or matrices of coordinates for unknown points
% Outputs:
%   V -- Vector or matrix of interpolated values of water depth for the unknown points
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%%
N = length(x);  % Number of scattered points
M = numel(X); % Number of unknown points
epsilon = 1e-5; % Tolerance for comparison with zero

xRange = unique(x); % Sorted in ascending order
yRange = flip(unique(y)); % Sorted in descending order
DX = xRange(2) - xRange(1); % Resolution of x coordinates
DY = yRange(2) - yRange(1); % Resolution of y coordinates, typically the same as DX but negative
m = length(yRange); % Number of rows in the depth matrix
n = length(xRange); % Number of columns in the depth matrix
Z = transpose(reshape(z, [n, m])); % Depth matrix
V = zeros(size(X)); % Interpolated z-values for unknown points, V(X,Y)
%%
for j = 1:M  % Loop through all unknown points
    % Determine the surrounding points of X(j), Y(j)
    selectorX = (X(j) - 2 * DX <= xRange & xRange <= X(j) + 2 * DX); % Selector for points with x-coordinates within ¡À2DX of X(j)
    selectorY = (Y(j) + 2 * DY <= yRange & yRange <= Y(j) - 2 * DY); % Selector for points with y-coordinates within ¡À2DY of Y(j), note that DY is negative
    x1 = xRange(selectorX);
    y1 = yRange(selectorY); 
    Z1 = Z(selectorY, selectorX);
    X1 = repmat(x1, size(Z1, 1), 1);
    Y1 = repmat(y1', 1, size(Z1, 2));
        
    % Call the IDW function to calculate the value at the unknown point (X(j), Y(j))
    K = numel(Z1);
    v = IDW(X1(:), Y1(:), Z1(:), [X(j)], [Y(j)], K);  % Note: The query point vector contains only one point (X(j), Y(j))
    V(j) = v(1);
end
end