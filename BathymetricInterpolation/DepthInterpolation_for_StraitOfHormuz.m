% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpolate the bathymetry of the Strait of Hormuz to the unstructured triangular grid of FVCOM
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all; close all
%% Read and preprocess the water depth xyz file
depth = load('StraitOfHormuz.xyz'); % Load the data
tmp = depth(:,3);
tmp(tmp == -99999 | isnan(tmp)) = 0; % Set invalid depth values to 0
depth(:,3) = tmp; % Update the depth data
fprintf('Reading and preprocessing of the water depth xyz file completed.\n')

%% Read mesh data
fid = fopen('StraitOfHormuz_grd.14','rt'); % Open the file
line = fgetl(fid); % Skip the first line
cellNum = fscanf(fid,'%d',1);  % Read the number of triangular cells
nodeNum = fscanf(fid,'%d\n',1); % Read the number of mesh nodes
nodes = fscanf(fid,'%f',[4,nodeNum]); % Read data into a 4xN matrix (data stored column-wise).
nodes = nodes'; % Transpose the matrix
nodes(:,1) = []; % Remove the first column (index column)
triangles = fscanf(fid,'%f',[5,cellNum]); % Read data into a 5xM matrix (data stored column-wise).
triangles = triangles'; % Transpose the matrix
triangles(:,[1,2]) = []; % Remove the first column (index column) and second column (fixed value 3)
fclose(fid); % Close the file
fprintf('Reading of mesh data completed.\n')

%% Call interpolation methods
Mobj.lon = nodes(:,1);
Mobj.lat = nodes(:,2);
Mobj.tri = triangles;
x = depth(:,1); y = depth(:,2); v = depth(:,3);
disp('Starting bilinear water depth interpolation...');
tic;  % Start the timer
Mobj.depth_Bilinear = Bilinear_depth(x, y, v, Mobj.lon, Mobj.lat);
elapsedTime_Bilinear = toc;  % End the timer and store the elapsed time
Mobj.depth_Bilinear(Mobj.depth_Bilinear > 0) = 0; % Set land points to zero depth
Mobj.depth_Bilinear = -Mobj.depth_Bilinear; % Convert water depth from negative to positive

Mobj.depth = Mobj.depth_Bilinear;
disp(['Bilinear interpolation of water depth completed, a total of ',num2str(length(Mobj.lon)),' nodes interpolated.']);

tic;  % Start the timer
Mobj.depth_NNI = NNI_depth(x, y, v, Mobj.lon,Mobj.lat);
elapsedTime_NNI = toc;  % End the timer and store the elapsed time
Mobj.depth_NNI(Mobj.depth_NNI > 0) = 0; % Set land points to zero depth
Mobj.depth_NNI = -Mobj.depth_NNI; % Convert water depth from negative to positive
disp(['Nearest neighbor interpolation of water depth completed, a total of ',num2str(length(Mobj.lon)),' nodes interpolated.']);

tic;  % Start the timer
Mobj.depth_IDW = IDW_depth(x, y, v, Mobj.lon,Mobj.lat);
elapsedTime_IDW = toc;  % End the timer and store the elapsed time
Mobj.depth_IDW(Mobj.depth_IDW > 0) = 0; % Set land points to zero depth
Mobj.depth_IDW = -Mobj.depth_IDW; % Convert water depth from negative to positive
disp(['IDW interpolation of water depth completed, a total of ',num2str(length(Mobj.lon)),' nodes interpolated.']);

tic;  % Start the timer
Mobj.depth_IDWR = IDWR_depth(x, y, v, Mobj.lon,Mobj.lat);
elapsedTime_IDWR = toc;  % End the timer and store the elapsed time
Mobj.depth_IDWR(Mobj.depth_IDWR > 0) = 0; % Set land points to zero depth
Mobj.depth_IDWR = -Mobj.depth_IDWR; % Convert water depth from negative to positive
disp(['IDWR interpolation of water depth completed, a total of ',num2str(length(Mobj.lon)),' nodes interpolated.']);

%% Use the system function scatteredInterpolant to complete interpolation
tic;  % Start the timer
F = scatteredInterpolant(x,y,v); % Create the interpolation function F
F.Method = 'nearest'; % Set the interpolation method
Mobj.depth_nearest = F(Mobj.lon,Mobj.lat); % Call F for interpolation
elapsedTime_nearest = toc;  % End the timer and store the elapsed time
Mobj.depth_nearest(Mobj.depth_nearest > 0) = 0; % Set land points to zero depth
Mobj.depth_nearest = -Mobj.depth_nearest; % Convert water depth from negative to positive

tic;  % Start the timer
F = scatteredInterpolant(x,y,v); % Create the interpolation function F
F.Method = 'linear';
Mobj.depth_linear = F(Mobj.lon,Mobj.lat);
elapsedTime_linear = toc;  % End the timer and store the elapsed time
Mobj.depth_linear(Mobj.depth_linear > 0) = 0; % Set land points to zero depth
Mobj.depth_linear = -Mobj.depth_linear; % Convert water depth from negative to positive

tic;  % Start the timer
F = scatteredInterpolant(x,y,v); % Create the interpolation function F
F.Method = 'natural';
Mobj.depth_natural = F(Mobj.lon,Mobj.lat);
elapsedTime_natural = toc;  % End the timer and store the elapsed time
Mobj.depth_natural(Mobj.depth_natural > 0) = 0; % Set land points to zero depth
Mobj.depth_natural = -Mobj.depth_natural; % Convert water depth from negative to positive

disp('Execution of scatteredInterpolant completed.');
%% Compare elapsed times
elapsedTimes = [elapsedTime_NNI,elapsedTime_IDW,elapsedTime_IDWR,elapsedTime_Bilinear,elapsedTime_nearest,elapsedTime_linear,elapsedTime_natural];
figure('Position',[200,200,500,300])
x = 1:length(elapsedTimes);
stem(x,elapsedTimes,'linewidth',2,'markersize',10,'MarkerEdgeColor','red','MarkerfaceColor','green');

% Set the y-axis to logarithmic scale
set(gca, 'yscale', 'log');
% Set the format of y-axis tick labels
set(gca,'XTick',x);
set(gca,'XTickLabel',{'NNI','IDW','IDWR','Bilinear','\it nearest','\it linear','\it natural'}); % Note: MATLAB uses \ for escaping
xlim([0,length(elapsedTimes)+1]);
ylim([10^(-2),10^2]);
xlabel('Methods');
ylabel('Elapsed time(s)')
set(gca, 'FontName','Times New Roman');
grid on
ax=gca;
ax.Position=[0.15    0.15    0.8    0.8];

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

figure('Position',[200,200,600,300])
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
[legend_h, object_h, plot_h, text_str] = legendflex(b1, legendData,'nrow',2, 'FontSize', 9, 'Location', 'NorthWest', 'FontName','Times New Roman');
hatchfill2(object_h(5), 'single', 'HatchAngle', 45, 'HatchDensity', 15, 'HatchColor', 'k');
hatchfill2(object_h(6), 'cross', 'HatchAngle', 45, 'HatchDensity', 15, 'HatchColor', 'k');
hatchfill2(object_h(7), 'single', 'HatchAngle', -45, 'HatchDensity', 15, 'HatchColor', 'k');
hatchfill2(object_h(8), 'single', 'HatchAngle', 0, 'HatchDensity', 15, 'HatchColor', 'k');

set(gca, 'FontSize', 11);
set(gca, 'XMinorTick','on', 'XMinorGrid','on', 'YMinorTick','on', 'YMinorGrid','on');
set(gca,'XTickLabel',{'\it nearest','\it linear','\it natural'});
xlabel('Methods supported in the {\it scatteredInterpolant} function ')
ylabel('RMSE (m)')
set(gca, 'FontName','Times New Roman');
% ylim([0,8]);
ax=gca;
ax.Position=[0.12    0.15    0.87    0.8];

figure('Position',[200,200,600,300])
set(gca, 'fontname','Times New Roman');
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
[legend_h, object_h, plot_h, text_str] = legendflex(b2, legendData, 'nrow',2, 'FontSize', 9, 'Location', 'NorthWest', 'FontName','Times New Roman');
hatchfill2(object_h(5), 'single', 'HatchAngle', 45, 'HatchDensity', 15, 'HatchColor', 'k');
hatchfill2(object_h(6), 'cross', 'HatchAngle', 45, 'HatchDensity', 15, 'HatchColor', 'k');
hatchfill2(object_h(7), 'single', 'HatchAngle', -45, 'HatchDensity', 15, 'HatchColor', 'k');
hatchfill2(object_h(8), 'single', 'HatchAngle', 0, 'HatchDensity', 15, 'HatchColor', 'k');

set(gca, 'FontSize', 11);
set(gca, 'XMinorTick','on', 'XMinorGrid','on', 'YMinorTick','on', 'YMinorGrid','on');
set(gca,'XTickLabel',{'\it nearest','\it linear','\it natural'});
xlabel('Methods supported in the {\it scatteredInterpolant} function ')
ylabel('RRMSE')
set(gca, 'FontName','Times New Roman');
ylim([0,0.5]);
ax=gca;
ax.Position=[0.12    0.17    0.83    0.78];

%% Plotting bathymetry data
figure('Position',[200,200,800,300])
index = randsample(length(Mobj.depth_Bilinear),100); % Randomly select 100 samples
hold on
stem(Mobj.depth_natural(index),'-s','linewidth',2,'markersize',12,'MarkerEdgeColor','blue','MarkerfaceColor','y');
stem(Mobj.depth_Bilinear(index),'-.or','linewidth',1,'markersize',6,'MarkerEdgeColor','red','MarkerfaceColor','g');

% Set the y-axis to logarithmic scale
set(gca, 'yscale', 'log');
xlabel('{\it n}')
ylabel('Bathymetry (m)')
% legend('Bilinear','Nearest Neighbor','scatteredInterpolant-natural')
legend('Bilinear','{\it natural}')
set(gca, 'FontName','Times New Roman');
grid on
ax=gca;
ax.Position=[0.1    0.15    0.85    0.8];
%% Output bathymetry data
out = 'Hormuz_dep.dat';
fid = fopen(out,'w');
fprintf(fid,'Node Number = %d\n',length(Mobj.depth)); % Write the number of network nodes
fprintf(fid,'%.6f  %.6f  %.6f\n',[Mobj.lon,Mobj.lat,Mobj.depth]'); % Write the bathymetry of each node
fclose(fid);
disp(['Bathymetry data has been saved to file ',out])

%% Plot the triangular mesh
% Mobj.lon = nodes(:,1);
% Mobj.lat = nodes(:,2);
% Mobj.tri = triangles;

vertices = [Mobj.lon Mobj.lat]; % Vertex sequence
faces = Mobj.tri; % Vertex indices of each triangle
% Use patch to draw the triangular mesh and fill it,
col = zeros(size(Mobj.lon)); % Vertex color mapping values
% col = h; % Vertex color mapping values
figure('Position',[200,200,800,400])
patch('Faces',faces,'Vertices',vertices,...%'FaceVertexCData',col,...
      'FaceColor',[204 236 255]/255,...% The face color is the interpolation of vertex colors
      'EdgeColor','k','linewidth',1); % Draw the polygon
% colormap('jet')
% colorbar

% hold on;
% triplot(Mobj.tri,Mobj.lon,Mobj.lat,'color','k','linewidth',1);  % Plot the triangular mesh
xtickformat('%0.1f^{\\circ}E')
ytickformat('%0.1f^{\\circ}N')
xlim([min(Mobj.lon)-0.01,max(Mobj.lon)+0.01]); ylim([min(Mobj.lat)-0.01,max(Mobj.lat)+0.01]);
set(gca,'xTick',[min(Mobj.lon):0.5:max(Mobj.lon)]);   % Modify the x-axis coordinate interval
set(gca,'yTick',[min(Mobj.lat):0.5:max(Mobj.lat)]);  % Modify the y-axis coordinate interval
grid on
set(gca,'GridLineStyle',':','GridColor','k','GridAlpha',0.5) % Set the grid lines
set(gca, 'FontName','Times New Roman');
box on

%% Plot the triangular mesh with interpolated bathymetry
vertices = [Mobj.lon Mobj.lat]; % Vertex sequence
faces = Mobj.tri; % Vertex indices for each triangle
% col = Mobj.depth; % Vertex color mapping values  % Mobj.depth corresponds to Mobj.depth_Bilinear, Mobj.depth_NNI, Mobj.depth_IDW
col = Mobj.depth_Bilinear; % Vertex color mapping values  % Mobj.depth corresponds to Mobj.depth_Bilinear, Mobj.depth_NNI, Mobj.depth_IDW
% col = Mobj.depth_NNI; % Vertex color mapping values  % Mobj.depth corresponds to Mobj.depth_Bilinear, Mobj.depth_NNI, Mobj.depth_IDW
figure('Position', [200, 200, 800, 400])
set(gca, 'FontName', 'Times New Roman');

patch('Faces', faces, 'Vertices', vertices, 'FaceVertexCData', col, ...
      'FaceColor', 'interp', ... % Interpolated vertex colors on the faces
      'EdgeColor', 'none', 'LineWidth', 1); % Plotting the polygon
colormap(flipud(jet)); % Alternatively, use colormap(flipud(cool))
colorbar;

% hold on;
% triplot(Mobj.tri, Mobj.lon, Mobj.lat, 'Color', 'k', 'LineWidth', 1);  % Plotting the triangular mesh
xtickformat('%0.1f^{\\circ}E');
ytickformat('%0.1f^{\\circ}N');
xlim([min(Mobj.lon) - 0.01, max(Mobj.lon) + 0.01]); 
ylim([min(Mobj.lat) - 0.01, max(Mobj.lat) + 0.01]);
set(gca, 'XTick', [min(Mobj.lon):0.5:max(Mobj.lon)]);   % Modify x-axis tick spacing
set(gca, 'YTick', [min(Mobj.lat):0.5:max(Mobj.lat)]);  % Modify y-axis tick spacing
grid on;
set(gca, 'GridLineStyle', ':', 'GridColor', 'k', 'GridAlpha', 0.5); % Customize grid lines
set(gca, 'FontName', 'Times New Roman');
box on;
ax = gca;
ax.Position = [0.07, 0.1, 0.83, 0.85];
