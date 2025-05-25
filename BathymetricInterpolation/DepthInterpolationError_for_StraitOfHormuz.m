% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpolate the bathymetry data of the Strait of Hormuz to the FVCOM triangular grid
% using the IDW method, and evaluate the interpolation error.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all; close all
%% Read and preprocess the bathymetry xyz file
depth = load('StraitOfHormuz.xyz'); % Load data

depth = depth(depth(:,3) < 0,:);  % Select oceanic points
depth(:,3) = -depth(:,3); % Convert negative bathymetry values (in the third column) to positive

depth = depth(depth(:,1) >= 59 & depth(:,1) <= 60 & depth(:,2) >= 25 & depth(:,2) <= 25.5,:); % Select points within a specific range
fprintf('Bathymetry xyz file read and preprocessed.\n');

%% Randomly select 1/10 of the data as interpolation points and the remaining 9/10 as sample points
n = length(depth);
n_i = round(0.1 * n);
n_s = n - n_i;

% Create a random number stream to ensure reproducibility of results
s = RandStream('mlfg6331_64');
% Randomly select without replacement
index = 1:n; % Indices of all data points
index_i = datasample(s, index, n_i, 'Replace', false); % Indices of interpolation points
index_s = setdiff(index, index_i);  % Indices of sample points

% Interpolation point data
depth_i = depth(index_i,:); % Includes true values for interpolation comparison
% depth_i(:,end+1) = 0; % Add a new column at the end and initialize it to 0 for storing interpolated values
% Sample point data
depth_s = depth(index_s,:);
%% Call the interpolation method
x = depth_s(:,1); y = depth_s(:,2); v = depth_s(:,3);
X = depth_i(:,1); Y = depth_i(:,2);
disp('Starting IDW bathymetry interpolation...');
tic;  % Start timer
depth_i(:,end+1) = IDW(x, y, v, X, Y, 4); % Add a new column at the end of depth_i to store interpolated values
elapsedTime_IDW = toc;  % End timing and assign elapsed time to variable

%% Plotting
figure('Position',[200,200,800,300])
plot(depth_i(:,3),'s:r'); hold on
%plot(Mobj.depth_NNI(index),'o--g');
% plot(Mobj.depth_nearest(index),'*-y');
% plot(Mobj.depth_linear(index),'s-k');
plot(depth_i(:,4),'*-b');
xlabel('{\it k}')
ylabel('Bathymetry (m)')
%legend('Bilinear','Nearest Neighbor','scatteredInterpolant-natural')
legend('Real','IDW')
set(gca, 'FontName','Times New Roman');
grid on
ax=gca;
ax.Position=[0.1    0.15    0.85    0.8];

%% Calculate RMSE and RRMSE with respect to true values
rmse_IDW = sqrt(mean((depth_i(:,3)-depth_i(:,4)).^2));
rrmse_IDW = rmse_IDW / mean(depth_i(:,3));

%% Plot a subset of bathymetric data
figure
scatter(depth(:,1),depth(:,2),10,depth(:,3),'fill')
colormap(flipud(jet)) % colormap(flipud(cool))
colorbar
xlim([59-0.1;60+0.1]);
ylim([25-0.05;25.5+0.05]);
xtickformat('%.1f^{\\circ}E');  ytickformat('%0.1f^{\\circ}N')
xtick=59:0.2:60;
set(gca,'xTick',xtick);   % Modify x-axis tick interval
set(gca,'yTick',25:0.1:25.5);   % Modify y-axis tick interval
title('Subset of Bathymetric Data')
set(gca, 'FontName','Times New Roman');
%% Plot sample set
figure
scatter(depth_s(:,1),depth_s(:,2),10,depth_s(:,3),'fill')
colormap(flipud(jet)) % colormap(flipud(cool))
colorbar
xlim([59-0.1;60+0.1]);
ylim([25-0.05;25.5+0.05]);
xtickformat('%.1f^{\\circ}E');  ytickformat('%0.1f^{\\circ}N')
xtick=59:0.2:60;
set(gca,'xTick',xtick);   % Modify x-axis tick interval
set(gca,'yTick',25:0.1:25.5);   % Modify y-axis tick interval
title('Sample Set')
set(gca, 'FontName','Times New Roman');
%% Plot actual bathymetric data of test set
figure
scatter(depth_i(:,1),depth_i(:,2),10,depth_i(:,3),'fill')
colormap(flipud(jet)) % colormap(flipud(cool))
colorbar
xlim([59-0.1;60+0.1]);
ylim([25-0.05;25.5+0.05]);
xtickformat('%.1f^{\\circ}E');  ytickformat('%0.1f^{\\circ}N')
xtick=59:0.2:60;
set(gca,'xTick',xtick);   % Modify x-axis tick interval
set(gca,'yTick',25:0.1:25.5);   % Modify y-axis tick interval
title('Actual Bathymetric Data of Test Set')
set(gca, 'FontName','Times New Roman');
%% Plot estimated bathymetric data of test set
figure
scatter(depth_i(:,1),depth_i(:,2),10,depth_i(:,4),'fill')
colormap(flipud(jet)) % colormap(flipud(cool))
colorbar
xlim([59-0.1;60+0.1]);
ylim([25-0.05;25.5+0.05]);
xtickformat('%.1f^{\\circ}E');  ytickformat('%0.1f^{\\circ}N')
xtick=59:0.2:60;
set(gca,'xTick',xtick);   % Modify x-axis tick interval
set(gca,'yTick',25:0.1:25.5);   % Modify y-axis tick interval
title('Estimated Bathymetric Data of Test Set')
set(gca, 'FontName','Times New Roman');