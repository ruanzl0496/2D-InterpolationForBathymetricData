% 水深数据插值到三角网格
clc;clear all; close all
%% 读取水深的xyz文件并预处理
depth = load('NorthIndianOcean.xyz'); % 读取数据
tmp  = depth(:,3);
tmp(tmp==-99999 | isnan(tmp)) = 0; % 异常点水深改修0
depth(:,3) = tmp; % 
fprintf('读取水深的xyz文件并预处理完成\n')

%% 读取网格数据
fid=fopen('NorthIndianOcean_grd.14','rt'); % 打开文件
line = fgetl(fid); % 跳过第一行
cellNum = fscanf(fid,'%d',1);  % 读取三角单元数量
nodeNum = fscanf(fid,'%d\n',1); % 读取网格结点数量
nodes = fscanf(fid,'%f',[4,nodeNum]);% [M，N]（读数据到M×N的矩阵中，数据按列存放）。
nodes = nodes'; % 转置
nodes(:,1)=[]; % 删除第一列（序号列）
triangles = fscanf(fid,'%f',[5,cellNum]);% [M，N]（读数据到M×N的矩阵中，数据按列存放）。
triangles = triangles'; % 转置
triangles(:,[1,2])=[]; % 删除第一列（序号列）和第二列（固定值3）
fclose(fid); % 关闭文件
fprintf('读取网格数据完成\n')

%% 调用插值方法
Mobj.lon = nodes(:,1);
Mobj.lat = nodes(:,2);
Mobj.tri = triangles;
x = depth(:,1); y = depth(:,2); v = depth(:,3);
disp('开始双线性水深插值...');
tic;  % 启动计时器
Mobj.depth_Bilinear = Bilinear_depth(x, y, v, Mobj.lon, Mobj.lat);
elapsedTime_Bilinear = toc;  % 计时结束，将经过的时间赋值给变量
Mobj.depth_Bilinear(Mobj.depth_Bilinear>0) = 0; % 陆地点深度置为0
Mobj.depth_Bilinear = -Mobj.depth_Bilinear; % 水深由负改为正


Mobj.depth = Mobj.depth_Bilinear;
disp(['双线性-水深插值结束,一共插值',num2str(length(Mobj.lon)),'个结点']);

tic;  % 启动计时器
Mobj.depth_NNI = NNI_depth(x, y, v, Mobj.lon,Mobj.lat);
elapsedTime_NNI = toc;  % 计时结束，将经过的时间赋值给变量
Mobj.depth_NNI(Mobj.depth_NNI>0) = 0; % 陆地点深度置为0
Mobj.depth_NNI = -Mobj.depth_NNI; % 水深由负改为正
disp(['最近邻-水深插值结束,一共插值',num2str(length(Mobj.lon)),'个结点']);

tic;  % 启动计时器
Mobj.depth_IDW = IDW_depth(x, y, v, Mobj.lon,Mobj.lat);
elapsedTime_IDW = toc;  % 计时结束，将经过的时间赋值给变量
Mobj.depth_IDW(Mobj.depth_IDW>0) = 0; % 陆地点深度置为0
Mobj.depth_IDW = -Mobj.depth_IDW; % 水深由负改为正
disp(['IDW-水深插值结束,一共插值',num2str(length(Mobj.lon)),'个结点']);

tic;  % 启动计时器
Mobj.depth_IDWR = IDWR_depth(x, y, v, Mobj.lon,Mobj.lat);
elapsedTime_IDWR = toc;  % 计时结束，将经过的时间赋值给变量
Mobj.depth_IDWR(Mobj.depth_IDWR>0) = 0; % 陆地点深度置为0
Mobj.depth_IDWR = -Mobj.depth_IDWR; % 水深由负改为正
disp(['IDWR-水深插值结束,一共插值',num2str(length(Mobj.lon)),'个结点']);

%% 调用系统函数scatteredInterpolant方法完成插值
tic;  % 启动计时器
F = scatteredInterpolant(x,y,v); % 生成插值函数F
F.Method = 'nearest'; % 设置插值方法
Mobj.depth_nearest = F(Mobj.lon,Mobj.lat); % 调用F插值
elapsedTime_nearest = toc;  % 计时结束，将经过的时间赋值给变量
Mobj.depth_nearest(Mobj.depth_nearest>0) = 0; % 陆地点深度置为0
Mobj.depth_nearest = -Mobj.depth_nearest; % 水深由负改为正

tic;  % 启动计时器
F = scatteredInterpolant(x,y,v); % 生成插值函数F
F.Method = 'linear';
Mobj.depth_linear = F(Mobj.lon,Mobj.lat);
elapsedTime_linear = toc;  % 计时结束，将经过的时间赋值给变量
Mobj.depth_linear(Mobj.depth_linear>0) = 0; % 陆地点深度置为0
Mobj.depth_linear = -Mobj.depth_linear; % 水深由负改为正

tic;  % 启动计时器
F = scatteredInterpolant(x,y,v); % 生成插值函数F
F.Method = 'natural';
Mobj.depth_natural = F(Mobj.lon,Mobj.lat);
elapsedTime_natural = toc;  % 计时结束，将经过的时间赋值给变量
Mobj.depth_natural(Mobj.depth_natural>0) = 0; % 陆地点深度置为0
Mobj.depth_natural = -Mobj.depth_natural; % 水深由负改为正

disp('scatteredInterpolant执行结束');
%% 计算耗时对比
elapsedTimes = [elapsedTime_NNI,elapsedTime_IDW,elapsedTime_IDWR,elapsedTime_Bilinear,elapsedTime_nearest,elapsedTime_linear,elapsedTime_natural];
figure('Position',[200,200,500,300])

x = 1:length(elapsedTimes);
stem(x,elapsedTimes,'linewidth',2,'markersize',10,'MarkerEdgeColor','red','MarkerfaceColor','green');

% 设置y轴为对数刻度
set(gca, 'yscale', 'log');
% 设置y轴刻度标签的格式
set(gca,'XTick',x);
set(gca,'XTickLabel',{'NNI','IDW','IDWR','Bilinear','\it nearest','\it linear','\it natural'}); % 注意，matlab转义不是用\，而是'
xlim([0,length(elapsedTimes)+1]);
ylim([10^(-1),10^3]);
xlabel('Methods');
ylabel('Elapsed time(s)')
set(gca, 'FontName','Times New Roman');
grid on
ax=gca;
ax.Position=[0.15    0.15    0.8    0.8];

%% 与系统插值方法（natural、linear、nearest)插值结果的均方根误差RMSE和相对均方根误差RRMSE
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

% 填充纹理(使用了工具箱textureFill,位于matlab的toolbox文件夹)
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
% object_h(1) is the first bar's text
% object_h(2) is the second bar's text
% object_h(3) is the first bar's patch
% object_h(4) is the second bar's patch
%
% Set the two patches within the legend

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

% 填充纹理(使用了工具箱textureFill,位于matlab的toolbox文件夹)
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

%%
figure('Position',[200,200,800,300])

index = randsample(length(Mobj.depth_Bilinear),100); % 随机抽取100个数
hold on
stem(Mobj.depth_natural(index),'-s','linewidth',2,'markersize',12,'MarkerEdgeColor','blue','MarkerfaceColor','y');
stem(Mobj.depth_Bilinear(index),'-.or','linewidth',1,'markersize',6,'MarkerEdgeColor','red','MarkerfaceColor','g');

% 设置y轴为对数刻度
set(gca, 'yscale', 'log');
xlabel('{\it n}')
ylabel('Bathymetry(m)')
legend('Bilinear','Natural')
set(gca, 'FontName','Times New Roman');
grid on
ax=gca;
ax.Position=[0.1    0.15    0.85    0.8];
%% 输出水深数据
out = 'NorthIndianOcean_dep.dat';
fid = fopen(out,'w');
fprintf(fid,'Node Number = %d\n',length(Mobj.depth)); % 写入网络结点数量
fprintf(fid,'%.6f  %.6f  %.6f\n',[Mobj.lon,Mobj.lat,Mobj.depth]'); % 写入各结点水深
fclose(fid);
disp(['水深数据已保存至文件',out])

%% 绘制三角网格
% Mobj.lon = nodes(:,1);
% Mobj.lat = nodes(:,2);
% Mobj.tri = triangles;

vertices = [Mobj.lon Mobj.lat]; % 顶点序列
faces = Mobj.tri; %  每个三角形的顶点编号
% 使用patch绘制三角网格并填充，
col = zeros(size(Mobj.lon)); % 顶点的颜色映射值
%col = h; % 顶点的颜色映射值
figure('Position',[200,200,800,400])

patch('Faces',faces,'Vertices',vertices,...%'FaceVertexCData',col,...
      'FaceColor',[204 236 255]/255,...% 面上是顶点颜色的插值
      'EdgeColor','k','linewidth',1); % 绘制多边形
% colormap('jet')
% colorbar

%hold on;
%triplot(Mobj.tri,Mobj.lon,Mobj.lat,'color','k','linewidth',1);  % 绘制三角网格
xtickformat('%d^{\\circ}E')
ytickformat('%d^{\\circ}N')
xlim([min(Mobj.lon)-0.3,max(Mobj.lon)+0.3]); ylim([min(Mobj.lat)-0.3,max(Mobj.lat)+0.3]);
set(gca,'xTick',[min(Mobj.lon):10:max(Mobj.lon)]);   % 修改x轴坐标间隔
set(gca,'yTick',[min(Mobj.lat):5:max(Mobj.lat)]);  % 修改y轴坐标间隔
grid on
box on
set(gca,'GridLineStyle',':','GridColor','k','GridAlpha',0.5) % 设置网格线
set(gca, 'FontName','Times New Roman');

%% 绘制插值含水深的三角网格
vertices = [Mobj.lon Mobj.lat]; % 顶点序列
faces = Mobj.tri; %  每个三角形的顶点编号
% col = Mobj.depth; % 顶点的颜色映射值  % Mobj.depth即Mobj.depth_Bilinear, Mobj.depth_NNI, Mobj.depth_IDW
col = Mobj.depth_Bilinear; % 顶点的颜色映射值  % Mobj.depth即Mobj.depth_Bilinear, Mobj.depth_NNI, Mobj.depth_IDW
% col = Mobj.depth_NNI; % 顶点的颜色映射值  % Mobj.depth即Mobj.depth_Bilinear, Mobj.depth_NNI, Mobj.depth_IDW
figure('Position',[200,200,800,400])
patch('Faces',faces,'Vertices',vertices,'FaceVertexCData',col,...
      'FaceColor','interp',...% 面上是顶点颜色的插值
      'EdgeColor','none','linewidth',1); % 绘制多边形
colormap(flipud(jet)) % colormap(flipud(cool))
colorbar

%hold on;
%triplot(Mobj.tri,Mobj.lon,Mobj.lat,'color','k','linewidth',1);  % 绘制三角网格
xtickformat('%d^{\\circ}E');  ytickformat('%d^{\\circ}N')
xlim([min(Mobj.lon)-0.3,max(Mobj.lon)+0.3]); ylim([min(Mobj.lat)-0.3,max(Mobj.lat)+0.3])
set(gca,'xTick',[min(Mobj.lon):10:max(Mobj.lon)]);   % 修改x轴坐标间隔
set(gca,'yTick',[min(Mobj.lat):5:max(Mobj.lat)]);  % 修改y轴坐标间隔
grid on
set(gca,'GridLineStyle',':','GridColor','k','GridAlpha',0.5) % 设置网格线
set(gca, 'FontName','Times New Roman');
box on
ax=gca;
ax.Position=[0.07    0.1    0.83    0.84];