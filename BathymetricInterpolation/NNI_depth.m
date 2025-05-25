function V = NNI_depth(x,y,z,X,Y)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Function: Interpolate water depth data on a rectangular grid to query points using the Nearest Neighbor Interpolation (NNI) method.
% Inputs:
%   x, y, z -- Vectors of scattered bathymetric data points
%   X, Y -- Vectors or matrices of coordinates for unknown points
% Outputs:
%   V -- Vector or matrix of interpolated values of water depth for the unknown points
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


N = length(x);  % Number of scattered data points
M = numel(X); % Number of unknown points

xRange = unique(x); % Increasing order
yRange = flip(unique(y)); % Decreasing order
DX = xRange(2) - xRange(1); % Resolution of x coordinates
DY = yRange(2) - yRange(1); % Resolution of y coordinates, usually the same as x but negative
m = length(yRange); % Number of rows in the depth matrix
n = length(xRange); % Number of columns in the depth matrix
Z = transpose(reshape(z, [n, m])); % Depth matrix
V = zeros(size(X)); % Values of z for unknown points, Z(X,Y)
%%

for j = 1:M  % Loop through all unknown points
    % Determine the indices of the previous points of X(j) and Y(j) in xRange and yRange, i.e., the four surrounding points
    IX1 = fix((X(j) - xRange(1)) / DX) + 1;
    IY1 = fix((Y(j) - yRange(1)) / DY) + 1;
    IX2 = min(IX1 + 1, n);
    IY2 = min(IY1 + 1, m);
    Q11 = [xRange(IX1), yRange(IY1), Z(IY1, IX1)]; % Top-left corner
    Q12 = [xRange(IX2), yRange(IY1), Z(IY1, IX2)]; % Top-right corner
    Q21 = [xRange(IX1), yRange(IY2), Z(IY2, IX1)]; % Bottom-left corner
    Q22 = [xRange(IX2), yRange(IY2), Z(IY2, IX2)]; % Bottom-right corner
    
    % Calculate the squared distances from the four points to the unknown point (Xj, Yj)
    d11 = (power(X(j) - Q11(1), 2) + power(Y(j) - Q11(2), 2));
    d12 = (power(X(j) - Q12(1), 2) + power(Y(j) - Q12(2), 2));
    d21 = (power(X(j) - Q21(1), 2) + power(Y(j) - Q21(2), 2));
    d22 = (power(X(j) - Q22(1), 2) + power(Y(j) - Q22(2), 2));
    
    dist = [d11, d12, d21, d22];
    depth = [Q11(3), Q12(3), Q21(3), Q22(3)]; % Depths of the four points
    
    % Sort distances in ascending order
    [~, IX] = sort(dist);
    % Find the nearest point, and use its depth as the depth of the query point
    V(j) = depth(IX(1));
end
end