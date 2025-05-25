function V = Bilinear_depth(x,y,z,X,Y)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Function: Interpolate water depth data on a rectangular grid to query points using the bilinear method.
% Inputs:
%   x, y, z -- Vectors of scattered bathymetric data points
%   X, Y -- Vectors or matrices of coordinates for unknown points
% Outputs:
%   V -- Vector or matrix of interpolated values of water depth for the unknown points
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

N = length(x);  % Number of scattered data points
M = numel(X); % Number of unknown points

xRange = unique(x); % Sorted in ascending order
yRange = flip(unique(y)); % Sorted in descending order
DX = xRange(2) - xRange(1); % Resolution of the x-coordinates
DY = yRange(2) - yRange(1); % Resolution of the y-coordinates, typically the same as DX but negative
m = length(yRange); % Number of rows in the depth matrix
n = length(xRange); % Number of columns in the depth matrix
Z = transpose(reshape(z, [n, m])); % Depth matrix
V = zeros(size(X)); % Interpolated z-values for the unknown points, V(X,Y)
%%

for j = 1:M  % Loop through all unknown points
    % Determine the indices of the previous points of X(j) and Y(j) in xRange and yRange, 
    % i.e., the four surrounding points
    IX1 = fix((X(j) - xRange(1)) / DX) + 1;
    IY1 = fix((Y(j) - yRange(1)) / DY) + 1;
    IX2 = min(IX1 + 1, n);
    IY2 = min(IY1 + 1, m);
    Q11 = [xRange(IX1), yRange(IY1), Z(IY1, IX1)]; % Top-left corner
    Q12 = [xRange(IX2), yRange(IY1), Z(IY1, IX2)]; % Top-right corner
    Q21 = [xRange(IX1), yRange(IY2), Z(IY2, IX1)]; % Bottom-left corner
    Q22 = [xRange(IX2), yRange(IY2), Z(IY2, IX2)]; % Bottom-right corner
       
    % Interpolate in the x-direction
    t1 = (X(j) - Q11(1)) / DX; % DX = Q12(1) - Q11(1)
    T1 = Q11 + t1 * (Q12 - Q11);
    t2 = t1;
    T2 = Q21 + t2 * (Q22 - Q21);
    
    % Interpolate in the y-direction
    t = (Y(j) - T1(2)) / DY; % DY = T2(2) - T1(2)
    V(j) = T1(3) + t * (T2(3) - T1(3));   
end
end