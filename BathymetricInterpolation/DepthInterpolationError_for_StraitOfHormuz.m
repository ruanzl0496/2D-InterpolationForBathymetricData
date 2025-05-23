% 水深数据插值到三角网格
clc;clear all; close all
%% 读取水深的xyz文件并预处理
depth = load('StraitOfHormuz.xyz'); % 读取数据

depth = depth(depth(:,3)<0,:);  % 选出海洋点
depth(:,3) = -depth(:,3);% 将负值水深(第3列)改为正值

depth = depth(depth(:,1)>=59 & depth(:,1)<=60 & depth(:,2)>=25 & depth(:,2)<=25.5,:) ;% 选取一定范围内的点个点
fprintf('读取水深的xyz文件并预处理完成\n')

%% 随机抽出1/10数据作为插值点，另外9/10作为样本点
n=length(depth);
n_i = round(0.1*n);
n_s = n-n_i;

% 创建一个随机数流以确保结果可重现
s = RandStream('mlfg6331_64');
% 随机抽取,不重复
index = 1:n; % 总数据的所以号
index_i = datasample(s, index, n_i, 'Replace', false); % 插值数据点的索引号
index_s = setdiff(index,index_i);  % 样本点数据的索引号

% 插值点数据
depth_i = depth(index_i,:); % 包含真实值，以便插值对比
% depth_i(:,end+1)=0; % 末尾增加一列并初始化为0，用于存储插值得到的估计值
% 样本点数据
depth_s = depth(index_s,:);
%% 调用插值方法
x = depth_s(:,1); y = depth_s(:,2); v = depth_s(:,3);
X= depth_i(:,1); Y = depth_i(:,2);
disp('开始IDW水深插值...');
tic;  % 启动计时器
depth_i(:,end+1) = IDW(x, y, v, X, Y, 4); % depth_i末尾增加一列，用于存储插值得到的估计值
elapsedTime_IDW = toc;  % 计时结束，将经过的时间赋值给变量

%%
figure('Position',[200,200,800,300])
plot(depth_i(:,3),'s:r'); hold on
%plot(Mobj.depth_NNI(index),'o--g');
% plot(Mobj.depth_nearest(index),'*-y');
% plot(Mobj.depth_linear(index),'s-k');
plot(depth_i(:,4),'*-b');
xlabel('{\it k}')
ylabel('Bathymetry(m)')
%legend('双线性','最近邻','scatteredInterpolant-natural')
legend('Real','IDW')
set(gca, 'FontName','Times New Roman');
grid on
ax=gca;
ax.Position=[0.1    0.15    0.85    0.8];

%% 与真实值的均方根误差RMSE和相对均方根误差RRMSE
rmse_IDW = sqrt(mean((depth_i(:,3)-depth_i(:,4)).^2))
rrmse_IDW = rmse_IDW/mean(depth_i(:,3))

%% 绘图--水深子集
figure
scatter(depth(:,1),depth(:,2),10,depth(:,3),'fill')
colormap(flipud(jet)) % colormap(flipud(cool))
colorbar
xlim([59-0.1;60+0.1]);
ylim([25-0.05;25.5+0.05]);
xtickformat('%.1f^{\\circ}E');  ytickformat('%0.1f^{\\circ}N')
xtick=59:0.2:60;
set(gca,'xTick',xtick);   % 修改x轴坐标间隔
set(gca,'yTick',25:0.1:25.5);   % 修改y轴坐标间隔
title('Subset of bathymetric data')
set(gca, 'FontName','Times New Roman');
%% 绘图--水深样本
figure
scatter(depth_s(:,1),depth_s(:,2),10,depth_s(:,3),'fill')
colormap(flipud(jet)) % colormap(flipud(cool))
colorbar
xlim([59-0.1;60+0.1]);
ylim([25-0.05;25.5+0.05]);
xtickformat('%.1f^{\\circ}E');  ytickformat('%0.1f^{\\circ}N')
xtick=59:0.2:60;
set(gca,'xTick',xtick);   % 修改x轴坐标间隔
set(gca,'yTick',25:0.1:25.5);   % 修改y轴坐标间隔
title('Sample set')
set(gca, 'FontName','Times New Roman');
%% 绘图--插值点的真实水深
figure
scatter(depth_i(:,1),depth_i(:,2),10,depth_i(:,3),'fill')
colormap(flipud(jet)) % colormap(flipud(cool))
colorbar
xlim([59-0.1;60+0.1]);
ylim([25-0.05;25.5+0.05]);
xtickformat('%.1f^{\\circ}E');  ytickformat('%0.1f^{\\circ}N')
xtick=59:0.2:60;
set(gca,'xTick',xtick);   % 修改x轴坐标间隔
set(gca,'yTick',25:0.1:25.5);   % 修改y轴坐标间隔
title('Actual bathymetric data of test set')
set(gca, 'FontName','Times New Roman');
%% 绘图--插值点的估算水深
figure
scatter(depth_i(:,1),depth_i(:,2),10,depth_i(:,4),'fill')
colormap(flipud(jet)) % colormap(flipud(cool))
colorbar
xlim([59-0.1;60+0.1]);
ylim([25-0.05;25.5+0.05]);
xtickformat('%.1f^{\\circ}E');  ytickformat('%0.1f^{\\circ}N')
xtick=59:0.2:60;
set(gca,'xTick',xtick);   % 修改x轴坐标间隔
set(gca,'yTick',25:0.1:25.5);   % 修改y轴坐标间隔
title('Estimated bathymetric data of test set')
set(gca, 'FontName','Times New Roman');