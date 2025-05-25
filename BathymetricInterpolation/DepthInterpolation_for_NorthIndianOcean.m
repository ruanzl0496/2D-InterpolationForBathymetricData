% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpolate the bathymetry of the North Indian Ocean to the unstructured triangular grid of FVCOM
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;clear all; close all
%% Load and preprocess the bathymetry xyz file
depth = load('NorthIndianOcean.xyz'); % Load data
tmp = depth(:, 3);
tmp(tmp == -99999 | isnan(tmp)) = 0; % Set invalid depth values to 0
depth(:, 3) = tmp; % Update depth values
fprintf('Loading and preprocessing of the bathymetry xyz file completed.\n');

%% Load grid data
fid = fopen('NorthIndianOcean_grd.14', 'rt'); % Open file
line = fgetl(fid); % Skip the first line
cellNum = fscanf(fid, '%d', 1);  % Read the number of triangular cells
nodeNum = fscanf(fid, '%d', 1); % Read the number of grid nodes
nodes = fscanf(fid, '%f', [4, nodeNum]); % Read data into a matrix with dimensions [M, N], stored column-wise
nodes = nodes'; % Transpose
nodes(:, 1) = []; % Remove the first column (index column)
triangles = fscanf(fid, '%f', [5, cellNum]); % Read data into a matrix with dimensions [M, N], stored column-wise
triangles = triangles'; % Transpose
triangles(:, [1, 2]) = []; % Remove the first column (index column) and the second column (fixed value 3)
fclose(fid); % Close file
fprintf('Loading of grid data completed.\n');

%% Call interpolation methods
Mobj.lon = nodes(:, 1);
Mobj.lat = nodes(:, 2);
Mobj.tri = triangles;
x = depth(:, 1); y = depth(:, 2); v = depth(:, 3);
disp('Starting bilinear bathymetry interpolation...');
tic; % Start timer
Mobj.depth_Bilinear = Bilinear_depth(x, y, v, Mobj.lon, Mobj.lat);
elapsedTime_Bilinear = toc; % End timing and assign elapsed time to variable
Mobj.depth_Bilinear(Mobj.depth_Bilinear > 0) = 0; % Set depth values for land points to 0
Mobj.depth_Bilinear = -Mobj.depth_Bilinear; % Convert depth values from negative to positive

Mobj.depth = Mobj.depth_Bilinear;
disp(['Bilinear bathymetry interpolation completed, a total of ', num2str(length(Mobj.lon)), ' nodes interpolated.']);

tic; % Start timer
Mobj.depth_NNI = NNI_depth(x, y, v, Mobj.lon, Mobj.lat);
elapsedTime_NNI = toc; % End timing and assign elapsed time to variable
Mobj.depth_NNI(Mobj.depth_NNI > 0) = 0; % Set depth values for land points to 0
Mobj.depth_NNI = -Mobj.depth_NNI; % Convert depth values from negative to positive
disp(['Nearest Neighbor bathymetry interpolation completed, a total of ', num2str(length(Mobj.lon)), ' nodes interpolated.']);

tic; % Start timer
Mobj.depth_IDW = IDW_depth(x, y, v, Mobj.lon, Mobj.lat);
elapsedTime_IDW = toc; % End timing and assign elapsed time to variable
Mobj.depth_IDW(Mobj.depth_IDW > 0) = 0; % Set depth values for land points to 0
Mobj.depth_IDW = -Mobj.depth_IDW; % Convert depth values from negative to positive
disp(['Inverse Distance Weighting bathymetry interpolation completed, a total of ', num2str(length(Mobj.lon)), ' nodes interpolated.']);

tic; % Start timer
Mobj.depth_IDWR = IDWR_depth(x, y, v, Mobj.lon, Mobj.lat);
elapsedTime_IDWR = toc; % End timing and assign elapsed time to variable
Mobj.depth_IDWR(Mobj.depth_IDWR > 0) = 0; % Set depth values for land points to 0
Mobj.depth_IDWR = -Mobj.depth_IDWR; % Convert depth values from negative to positive
disp(['Inverse Distance Weighting with Range bathymetry interpolation completed, a total of ', num2str(length(Mobj.lon)), ' nodes interpolated.']);

%% Call the MATLAB built-in function scatteredInterpolant for interpolation
tic; % Start timer
F = scatteredInterpolant(x, y, v); % Create interpolation function F
F.Method = 'nearest'; % Set interpolation method
Mobj.depth_nearest = F(Mobj.lon, Mobj.lat); % Perform interpolation using F
elapsedTime_nearest = toc; % End timing and assign elapsed time to variable
Mobj.depth_nearest(Mobj.depth_nearest > 0) = 0; % Set depth values for land points to 0
Mobj.depth_nearest = -Mobj.depth_nearest; % Convert depth values from negative to positive

tic; % Start timer
F = scatteredInterpolant(x, y, v); % Create interpolation function F
F.Method = 'linear'; % Set interpolation method
Mobj.depth_linear = F(Mobj.lon, Mobj.lat); % Perform interpolation using F
elapsedTime_linear = toc; % End timing and assign elapsed time to variable
Mobj.depth_linear(Mobj.depth_linear > 0) = 0; % Set depth values for land points to 0
Mobj.depth_linear = -Mobj.depth_linear; % Convert depth values from negative to positive

tic; % Start timer
F = scatteredInterpolant(x, y, v); % Create interpolation function F
F.Method = 'natural'; % Set interpolation method
Mobj.depth_natural = F(Mobj.lon, Mobj.lat); % Perform interpolation using F
elapsedTime_natural = toc; % End timing and assign elapsed time to variable
Mobj.depth_natural(Mobj.depth_natural > 0) = 0; % Set depth values for land points to 0
Mobj.depth_natural = -Mobj.depth_natural; % Convert depth values from negative to positive

disp('Interpolation using scatteredInterpolant completed.');

%% Compare elapsed times
elapsedTimes = [elapsedTime_NNI, elapsedTime_IDW, elapsedTime_IDWR, elapsedTime_Bilinear, elapsedTime_nearest, elapsedTime_linear, elapsedTime_natural];
figure('Position', [200, 200, 500, 300]);

x = 1:length(elapsedTimes);
stem(x, elapsedTimes, 'linewidth', 2, 'markersize', 10, 'MarkerEdgeColor', 'red', 'MarkerfaceColor', 'green');

% Set y-axis to logarithmic scale
set(gca, 'yscale', 'log');
% Set format of y-axis tick labels
set(gca, 'XTick', x);
set(gca, 'XTickLabel', {'NNI', 'IDW', 'IDWR', 'Bilinear', '\it nearest', '\it linear', '\it natural'}); % Note: MATLAB uses \ for escaping, not '
xlim([0, length(elapsedTimes) + 1]);
ylim([10^(-1), 10^3]);
xlabel('Methods');
ylabel('Elapsed Time (s)');
set(gca, 'FontName', 'Times New Roman');
grid on;
ax = gca;
ax.Position = [0.15, 0.15, 0.8, 0.8];

%% Calculate RMSE and RRMSE compared to system interpolation methods (natural, linear, nearest)
rmse_Bilinear_toNatural = sqrt(mean((Mobj.depth_Bilinear-Mobj.depth_natural).^2));
rmse_NNI_toNatural = sqrt(mean((Mobj.depth_NNI-Mobj.depth_natural).^2));
rmse_IDW_toNatural = sqrt(mean((Mobj.depth_IDW-Mobj.depth_natural).^2));
rmse_IDWR_toNatural = sqrt(mean((Mobj.depth_IDWR-Mobj.depth_natural).^2));

rmse_Bilinear_toLinear = sqrt(mean((Mobj.depth_Bilinear-Mobj.depth_linear).^2));
rmse_NNI_toLinear = sqrt(mean((Mobj.depth_NNI-Mobj.depth_linear).^2));
rmse_IDW_toLinear = sqrt(mean((Mobj.depth_IDW-Mobj.depth_linear).^2));
rmse_IDWR_toLinear = sqrt(mean((Mobj.depth_IDWR-Mobj.depth_linear).^2));

rmse_Bilinear_toNearest = sqrt(mean((Mobj.depth_Bilinear-Mobj.depth_nearest).^2));
rmse_NNI_toNearest = sqrt(mean((Mobj.depth_NNI-Mobj.depth_nearest).^2));
rmse_IDW_toNearest = sqrt(mean((Mobj.depth_IDW-Mobj.depth_nearest).^2));
rmse_IDWR_toNearest = sqrt(mean((Mobj.depth_IDWR-Mobj.depth_nearest).^2));

m_natural = mean(Mobj.depth_natural);
rrmse_Bilinear_toNatural = rmse_Bilinear_toNatural/m_natural;
rrmse_NNI_toNatural = rmse_NNI_toNatural/m_natural;
rrmse_IDW_toNatural = rmse_IDW_toNatural/m_natural;
rrmse_IDWR_toNatural = rmse_IDWR_toNatural/m_natural;

m_linear = mean(Mobj.depth_linear);
rrmse_Bilinear_toLinear = rmse_Bilinear_toLinear/m_linear;
rrmse_NNI_toLinear = rmse_NNI_toLinear/m_linear;
rrmse_IDW_toLinear = rmse_IDW_toLinear/m_linear;
rrmse_IDWR_toLinear = rmse_IDWR_toLinear/m_linear;

m_nearest = mean(Mobj.depth_nearest);
rrmse_Bilinear_toNearest = rmse_Bilinear_toNearest/m_nearest;
rrmse_NNI_toNearest = rmse_NNI_toNearest/m_nearest;
rrmse_IDW_toNearest = rmse_IDW_toNearest/m_nearest;
rrmse_IDWR_toNearest = rmse_IDWR_toNearest/m_nearest;

figure('Position',[200,200,450,300])
rmse=[rmse_NNI_toNearest,rmse_IDW_toNearest,rmse_IDWR_toNearest,rmse_Bilinear_toNearest;
    rmse_NNI_toLinear,rmse_IDW_toLinear,rmse_IDWR_toLinear,rmse_Bilinear_toLinear;
    rmse_NNI_toNatural,rmse_IDW_toNatural,rmse_IDWR_toNatural,rmse_Bilinear_toNatural    
    ];
b1=bar(rmse,1,'EdgeColor','k','LineWidth',1);

% Fill the bar chart using the hatchfill2 function
hatchfill2(b1(1),'single','HatchAngle',45,'HatchDensity',30,'HatchColor','k');
hatchfill2(b1(2),'cross','HatchAngle',45,'HatchDensity',30,'HatchColor','k');
hatchfill2(b1(3),'single','HatchAngle',-45,'HatchDensity',30,'HatchColor','k');
hatchfill2(b1(4),'single','HatchAngle',0,'HatchDensity',30,'HatchColor','k');

b1(1).FaceColor = [1 0.6 0.6];
b1(2).FaceColor = [0.6 1 0.6];
b1(3).FaceColor = [0.6 0.6 1];
b1(4).FaceColor = [0 1 1];

legendData = {'NNI','IDW','IDWR','Bilinear'};
[legend_h, object_h, plot_h, text_str] = legendflex(b1, legendData,'nrow',1, 'FontSize', 9, 'Location', 'NorthWest');

hatchfill2(object_h(5), 'single', 'HatchAngle', 45, 'HatchDensity', 15, 'HatchColor', 'k');
hatchfill2(object_h(6), 'cross', 'HatchAngle', 45, 'HatchDensity', 15, 'HatchColor', 'k');
hatchfill2(object_h(7), 'single', 'HatchAngle', -45, 'HatchDensity', 15, 'HatchColor', 'k');
hatchfill2(object_h(8), 'single', 'HatchAngle', 0, 'HatchDensity', 15, 'HatchColor', 'k');

set(gca, 'FontSize', 11);
set(gca, 'XMinorTick','on', 'XMinorGrid','on', 'YMinorTick','on', 'YMinorGrid','on');
set(gca,'XTickLabel',{'\it nearest','\it linear','\it natural'});
xlabel('Methods supported in {\it scatteredInterpolant} function ')
ylabel('RMSE(m)')
set(gca, 'FontName','Times New Roman');
%ylim([0,8]);
ax=gca;
ax.Position=[0.12    0.15    0.87    0.8];

figure('Position',[200,200,600,300])
rrmse=[rrmse_NNI_toNearest,rrmse_IDW_toNearest,rrmse_IDWR_toNearest,rrmse_Bilinear_toNearest;
    rrmse_NNI_toLinear,rrmse_IDW_toLinear,rrmse_IDWR_toLinear,rrmse_Bilinear_toLinear;
    rrmse_NNI_toNatural,rrmse_IDW_toNatural,rrmse_IDWR_toNatural,rrmse_Bilinear_toNatural    
    ];
b2=bar(rrmse,1,'EdgeColor','k','LineWidth',1);

% Fill the bar chart using the hatchfill2 function
hatchfill2(b2(1),'single','HatchAngle',45,'HatchDensity',30,'HatchColor','k');
hatchfill2(b2(2),'cross','HatchAngle',45,'HatchDensity',30,'HatchColor','k');
hatchfill2(b2(3),'single','HatchAngle',-45,'HatchDensity',30,'HatchColor','k');
hatchfill2(b2(4),'single','HatchAngle',0,'HatchDensity',30,'HatchColor','k');

b2(1).FaceColor = [1 0.6 0.6];
b2(2).FaceColor = [0.6 1 0.6];
b2(3).FaceColor = [0.6 0.6 1];
b2(4).FaceColor = [0 1 1];

legendData = {'NNI','IDW','IDWR','Bilinear'};
[legend_h, object_h, plot_h, text_str] = legendflex(b2, legendData,'nrow',1, 'FontSize', 9, 'Location', 'NorthWest');

hatchfill2(object_h(5), 'single', 'HatchAngle', 45, 'HatchDensity', 15, 'HatchColor', 'k');
hatchfill2(object_h(6), 'cross', 'HatchAngle', 45, 'HatchDensity', 15, 'HatchColor', 'k');
hatchfill2(object_h(7), 'single', 'HatchAngle', -45, 'HatchDensity', 15, 'HatchColor', 'k');
hatchfill2(object_h(8), 'single', 'HatchAngle', 0, 'HatchDensity', 15, 'HatchColor', 'k');

set(gca, 'FontSize', 11);
set(gca, 'XMinorTick','on', 'XMinorGrid','on', 'YMinorTick','on', 'YMinorGrid','on');
%set(gca,'TickLabelInterpreter','latex');
set(gca,'XTickLabel',{'\it nearest','\it linear','\it natural'});
xlabel('Methods supported in {\it scatteredInterpolant} function ')
ylabel('RRMSE')
set(gca, 'FontName','Times New Roman');
ylim([0,0.2]);
ax=gca;
ax.Position=[0.12    0.17    0.83    0.78];

%% Plotting bathymetry data
figure('Position', [200, 200, 800, 300])

index = randsample(length(Mobj.depth_Bilinear), 100); % Randomly select 100 indices
hold on
stem(Mobj.depth_natural(index), '-s', 'linewidth', 2, 'markersize', 12, 'MarkerEdgeColor', 'blue', 'MarkerfaceColor', 'y');
stem(Mobj.depth_Bilinear(index), '-.or', 'linewidth', 1, 'markersize', 6, 'MarkerEdgeColor', 'red', 'MarkerfaceColor', 'g');

% Set the y-axis to logarithmic scale
set(gca, 'yscale', 'log');
xlabel('{\it n}')
ylabel('Bathymetry (m)')
legend('Bilinear', 'Natural')
set(gca, 'FontName', 'Times New Roman');
grid on
ax = gca;
ax.Position = [0.1, 0.15, 0.85, 0.8];

%% Output bathymetry data
out = 'NorthIndianOcean_dep.dat';
fid = fopen(out, 'w');
fprintf(fid, 'Node Number = %d\n', length(Mobj.depth)); % Write the number of nodes
fprintf(fid, '%.6f  %.6f  %.6f\n', [Mobj.lon, Mobj.lat, Mobj.depth]'); % Write bathymetry data for each node
fclose(fid);
disp(['Bathymetry data has been saved to the file ', out])

%% Plotting triangular mesh
% Mobj.lon = nodes(:,1);
% Mobj.lat = nodes(:,2);
% Mobj.tri = triangles;

vertices = [Mobj.lon, Mobj.lat]; % Vertex coordinates
faces = Mobj.tri; % Indices of vertices for each triangle
% Use patch to draw the triangular mesh and fill it
col = zeros(size(Mobj.lon)); % Vertex color mapping values
% col = h; % Vertex color mapping values
figure('Position', [200, 200, 800, 400])

patch('Faces', faces, 'Vertices', vertices, ...
      'FaceColor', [204, 236, 255] / 255, ... % Fill color
      'EdgeColor', 'k', 'linewidth', 1); % Draw polygons
% colormap('jet')
% colorbar

% hold on;
% triplot(Mobj.tri, Mobj.lon, Mobj.lat, 'color', 'k', 'linewidth', 1);  % Plot triangular mesh
xtickformat('%d^{\\circ}E')
ytickformat('%d^{\\circ}N')
xlim([min(Mobj.lon) - 0.3, max(Mobj.lon) + 0.3]);
ylim([min(Mobj.lat) - 0.3, max(Mobj.lat) + 0.3]);
set(gca, 'xTick', [min(Mobj.lon):10:max(Mobj.lon)]);   % Modify x-axis tick interval
set(gca, 'yTick', [min(Mobj.lat):5:max(Mobj.lat)]);  % Modify y-axis tick interval
grid on
box on
set(gca, 'GridLineStyle', ':', 'GridColor', 'k', 'GridAlpha', 0.5) % Set grid lines
set(gca, 'FontName', 'Times New Roman');

%% Plotting a triangular mesh with interpolated water depth
vertices = [Mobj.lon Mobj.lat]; % Sequence of vertices
faces = Mobj.tri; % Vertex indices for each triangle
% col = Mobj.depth; % Vertex color mapping values  % Note: Mobj.depth can be Mobj.depth_Bilinear, Mobj.depth_NNI, or Mobj.depth_IDW
col = Mobj.depth_Bilinear; % Vertex color mapping values  % Note: Mobj.depth can be Mobj.depth_Bilinear, Mobj.depth_NNI, or Mobj.depth_IDW
% col = Mobj.depth_NNI; % Vertex color mapping values  % Note: Mobj.depth can be Mobj.depth_Bilinear, Mobj.depth_NNI, or Mobj.depth_IDW
figure('Position',[200,200,800,400])
patch('Faces',faces,'Vertices',vertices,'FaceVertexCData',col,...
      'FaceColor','interp',... % Interpolated vertex colors on the surface
      'EdgeColor','none','LineWidth',1); % Plotting polygons
colormap(flipud(jet)) % colormap(flipud(cool))
colorbar

% hold on;
% triplot(Mobj.tri,Mobj.lon,Mobj.lat,'Color','k','LineWidth',1);  % Plotting triangular mesh
xtickformat('%d^{\\circ}E');  ytickformat('%d^{\\circ}N')
xlim([min(Mobj.lon)-0.3,max(Mobj.lon)+0.3]); ylim([min(Mobj.lat)-0.3,max(Mobj.lat)+0.3])
set(gca,'XTick',[min(Mobj.lon):10:max(Mobj.lon)]);   % Modify x-axis tick interval
set(gca,'YTick',[min(Mobj.lat):5:max(Mobj.lat)]);  % Modify y-axis tick interval
grid on
set(gca,'GridLineStyle',':','GridColor','k','GridAlpha',0.5) % Set grid lines
set(gca, 'FontName','Times New Roman');
box on
ax = gca;
ax.Position = [0.07    0.1    0.83    0.84];