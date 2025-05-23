% ˮ�����ݲ�ֵ����������
clc;clear all; close all
%% ��ȡˮ���xyz�ļ���Ԥ����
depth = load('NorthIndianOcean.xyz'); % ��ȡ����
tmp  = depth(:,3);
tmp(tmp==-99999 | isnan(tmp)) = 0; % �쳣��ˮ�����0
depth(:,3) = tmp; % 
fprintf('��ȡˮ���xyz�ļ���Ԥ�������\n')

%% ��ȡ��������
fid=fopen('NorthIndianOcean_grd.14','rt'); % ���ļ�
line = fgetl(fid); % ������һ��
cellNum = fscanf(fid,'%d',1);  % ��ȡ���ǵ�Ԫ����
nodeNum = fscanf(fid,'%d\n',1); % ��ȡ����������
nodes = fscanf(fid,'%f',[4,nodeNum]);% [M��N]�������ݵ�M��N�ľ����У����ݰ��д�ţ���
nodes = nodes'; % ת��
nodes(:,1)=[]; % ɾ����һ�У�����У�
triangles = fscanf(fid,'%f',[5,cellNum]);% [M��N]�������ݵ�M��N�ľ����У����ݰ��д�ţ���
triangles = triangles'; % ת��
triangles(:,[1,2])=[]; % ɾ����һ�У�����У��͵ڶ��У��̶�ֵ3��
fclose(fid); % �ر��ļ�
fprintf('��ȡ�����������\n')

%% ���ò�ֵ����
Mobj.lon = nodes(:,1);
Mobj.lat = nodes(:,2);
Mobj.tri = triangles;
x = depth(:,1); y = depth(:,2); v = depth(:,3);
disp('��ʼ˫����ˮ���ֵ...');
tic;  % ������ʱ��
Mobj.depth_Bilinear = Bilinear_depth(x, y, v, Mobj.lon, Mobj.lat);
elapsedTime_Bilinear = toc;  % ��ʱ��������������ʱ�丳ֵ������
Mobj.depth_Bilinear(Mobj.depth_Bilinear>0) = 0; % ½�ص������Ϊ0
Mobj.depth_Bilinear = -Mobj.depth_Bilinear; % ˮ���ɸ���Ϊ��


Mobj.depth = Mobj.depth_Bilinear;
disp(['˫����-ˮ���ֵ����,һ����ֵ',num2str(length(Mobj.lon)),'�����']);

tic;  % ������ʱ��
Mobj.depth_NNI = NNI_depth(x, y, v, Mobj.lon,Mobj.lat);
elapsedTime_NNI = toc;  % ��ʱ��������������ʱ�丳ֵ������
Mobj.depth_NNI(Mobj.depth_NNI>0) = 0; % ½�ص������Ϊ0
Mobj.depth_NNI = -Mobj.depth_NNI; % ˮ���ɸ���Ϊ��
disp(['�����-ˮ���ֵ����,һ����ֵ',num2str(length(Mobj.lon)),'�����']);

tic;  % ������ʱ��
Mobj.depth_IDW = IDW_depth(x, y, v, Mobj.lon,Mobj.lat);
elapsedTime_IDW = toc;  % ��ʱ��������������ʱ�丳ֵ������
Mobj.depth_IDW(Mobj.depth_IDW>0) = 0; % ½�ص������Ϊ0
Mobj.depth_IDW = -Mobj.depth_IDW; % ˮ���ɸ���Ϊ��
disp(['IDW-ˮ���ֵ����,һ����ֵ',num2str(length(Mobj.lon)),'�����']);

tic;  % ������ʱ��
Mobj.depth_IDWR = IDWR_depth(x, y, v, Mobj.lon,Mobj.lat);
elapsedTime_IDWR = toc;  % ��ʱ��������������ʱ�丳ֵ������
Mobj.depth_IDWR(Mobj.depth_IDWR>0) = 0; % ½�ص������Ϊ0
Mobj.depth_IDWR = -Mobj.depth_IDWR; % ˮ���ɸ���Ϊ��
disp(['IDWR-ˮ���ֵ����,һ����ֵ',num2str(length(Mobj.lon)),'�����']);

%% ����ϵͳ����scatteredInterpolant������ɲ�ֵ
tic;  % ������ʱ��
F = scatteredInterpolant(x,y,v); % ���ɲ�ֵ����F
F.Method = 'nearest'; % ���ò�ֵ����
Mobj.depth_nearest = F(Mobj.lon,Mobj.lat); % ����F��ֵ
elapsedTime_nearest = toc;  % ��ʱ��������������ʱ�丳ֵ������
Mobj.depth_nearest(Mobj.depth_nearest>0) = 0; % ½�ص������Ϊ0
Mobj.depth_nearest = -Mobj.depth_nearest; % ˮ���ɸ���Ϊ��

tic;  % ������ʱ��
F = scatteredInterpolant(x,y,v); % ���ɲ�ֵ����F
F.Method = 'linear';
Mobj.depth_linear = F(Mobj.lon,Mobj.lat);
elapsedTime_linear = toc;  % ��ʱ��������������ʱ�丳ֵ������
Mobj.depth_linear(Mobj.depth_linear>0) = 0; % ½�ص������Ϊ0
Mobj.depth_linear = -Mobj.depth_linear; % ˮ���ɸ���Ϊ��

tic;  % ������ʱ��
F = scatteredInterpolant(x,y,v); % ���ɲ�ֵ����F
F.Method = 'natural';
Mobj.depth_natural = F(Mobj.lon,Mobj.lat);
elapsedTime_natural = toc;  % ��ʱ��������������ʱ�丳ֵ������
Mobj.depth_natural(Mobj.depth_natural>0) = 0; % ½�ص������Ϊ0
Mobj.depth_natural = -Mobj.depth_natural; % ˮ���ɸ���Ϊ��

disp('scatteredInterpolantִ�н���');
%% �����ʱ�Ա�
elapsedTimes = [elapsedTime_NNI,elapsedTime_IDW,elapsedTime_IDWR,elapsedTime_Bilinear,elapsedTime_nearest,elapsedTime_linear,elapsedTime_natural];
figure('Position',[200,200,500,300])

x = 1:length(elapsedTimes);
stem(x,elapsedTimes,'linewidth',2,'markersize',10,'MarkerEdgeColor','red','MarkerfaceColor','green');

% ����y��Ϊ�����̶�
set(gca, 'yscale', 'log');
% ����y��̶ȱ�ǩ�ĸ�ʽ
set(gca,'XTick',x);
set(gca,'XTickLabel',{'NNI','IDW','IDWR','Bilinear','\it nearest','\it linear','\it natural'}); % ע�⣬matlabת�岻����\������'
xlim([0,length(elapsedTimes)+1]);
ylim([10^(-1),10^3]);
xlabel('Methods');
ylabel('Elapsed time(s)')
set(gca, 'FontName','Times New Roman');
grid on
ax=gca;
ax.Position=[0.15    0.15    0.8    0.8];

%% ��ϵͳ��ֵ������natural��linear��nearest)��ֵ����ľ��������RMSE����Ծ��������RRMSE
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

% �������(ʹ���˹�����textureFill,λ��matlab��toolbox�ļ���)
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

% �������(ʹ���˹�����textureFill,λ��matlab��toolbox�ļ���)
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

index = randsample(length(Mobj.depth_Bilinear),100); % �����ȡ100����
hold on
stem(Mobj.depth_natural(index),'-s','linewidth',2,'markersize',12,'MarkerEdgeColor','blue','MarkerfaceColor','y');
stem(Mobj.depth_Bilinear(index),'-.or','linewidth',1,'markersize',6,'MarkerEdgeColor','red','MarkerfaceColor','g');

% ����y��Ϊ�����̶�
set(gca, 'yscale', 'log');
xlabel('{\it n}')
ylabel('Bathymetry(m)')
legend('Bilinear','Natural')
set(gca, 'FontName','Times New Roman');
grid on
ax=gca;
ax.Position=[0.1    0.15    0.85    0.8];
%% ���ˮ������
out = 'NorthIndianOcean_dep.dat';
fid = fopen(out,'w');
fprintf(fid,'Node Number = %d\n',length(Mobj.depth)); % д������������
fprintf(fid,'%.6f  %.6f  %.6f\n',[Mobj.lon,Mobj.lat,Mobj.depth]'); % д������ˮ��
fclose(fid);
disp(['ˮ�������ѱ������ļ�',out])

%% ������������
% Mobj.lon = nodes(:,1);
% Mobj.lat = nodes(:,2);
% Mobj.tri = triangles;

vertices = [Mobj.lon Mobj.lat]; % ��������
faces = Mobj.tri; %  ÿ�������εĶ�����
% ʹ��patch��������������䣬
col = zeros(size(Mobj.lon)); % �������ɫӳ��ֵ
%col = h; % �������ɫӳ��ֵ
figure('Position',[200,200,800,400])

patch('Faces',faces,'Vertices',vertices,...%'FaceVertexCData',col,...
      'FaceColor',[204 236 255]/255,...% �����Ƕ�����ɫ�Ĳ�ֵ
      'EdgeColor','k','linewidth',1); % ���ƶ����
% colormap('jet')
% colorbar

%hold on;
%triplot(Mobj.tri,Mobj.lon,Mobj.lat,'color','k','linewidth',1);  % ������������
xtickformat('%d^{\\circ}E')
ytickformat('%d^{\\circ}N')
xlim([min(Mobj.lon)-0.3,max(Mobj.lon)+0.3]); ylim([min(Mobj.lat)-0.3,max(Mobj.lat)+0.3]);
set(gca,'xTick',[min(Mobj.lon):10:max(Mobj.lon)]);   % �޸�x��������
set(gca,'yTick',[min(Mobj.lat):5:max(Mobj.lat)]);  % �޸�y��������
grid on
box on
set(gca,'GridLineStyle',':','GridColor','k','GridAlpha',0.5) % ����������
set(gca, 'FontName','Times New Roman');

%% ���Ʋ�ֵ��ˮ�����������
vertices = [Mobj.lon Mobj.lat]; % ��������
faces = Mobj.tri; %  ÿ�������εĶ�����
% col = Mobj.depth; % �������ɫӳ��ֵ  % Mobj.depth��Mobj.depth_Bilinear, Mobj.depth_NNI, Mobj.depth_IDW
col = Mobj.depth_Bilinear; % �������ɫӳ��ֵ  % Mobj.depth��Mobj.depth_Bilinear, Mobj.depth_NNI, Mobj.depth_IDW
% col = Mobj.depth_NNI; % �������ɫӳ��ֵ  % Mobj.depth��Mobj.depth_Bilinear, Mobj.depth_NNI, Mobj.depth_IDW
figure('Position',[200,200,800,400])
patch('Faces',faces,'Vertices',vertices,'FaceVertexCData',col,...
      'FaceColor','interp',...% �����Ƕ�����ɫ�Ĳ�ֵ
      'EdgeColor','none','linewidth',1); % ���ƶ����
colormap(flipud(jet)) % colormap(flipud(cool))
colorbar

%hold on;
%triplot(Mobj.tri,Mobj.lon,Mobj.lat,'color','k','linewidth',1);  % ������������
xtickformat('%d^{\\circ}E');  ytickformat('%d^{\\circ}N')
xlim([min(Mobj.lon)-0.3,max(Mobj.lon)+0.3]); ylim([min(Mobj.lat)-0.3,max(Mobj.lat)+0.3])
set(gca,'xTick',[min(Mobj.lon):10:max(Mobj.lon)]);   % �޸�x��������
set(gca,'yTick',[min(Mobj.lat):5:max(Mobj.lat)]);  % �޸�y��������
grid on
set(gca,'GridLineStyle',':','GridColor','k','GridAlpha',0.5) % ����������
set(gca, 'FontName','Times New Roman');
box on
ax=gca;
ax.Position=[0.07    0.1    0.83    0.84];