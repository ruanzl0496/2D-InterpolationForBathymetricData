function newImg = Bilinear_img(img,scale)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% ���ܣ�˫���Բ�ֵ�����ž����ͼ��
% ���룺img--ԭʼͼ��ͼ���ļ��������
%       scale--�������ӣ������ŵı���,��Ϊ��������[scaleX,scaleY]
% �����newImg--���ź��ͼ����� 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%% Step1 �����ݽ���Ԥ����
if ~exist('img','var') || isempty(img)
    error('����ͼ�� Iδ�����Ϊ�գ�');
end
if ~exist('scale','var') || isempty(scale) || numel(scale) >2
     error('λ��ʸ�� scaleδ�����Ϊ�ջ� scale�е�Ԫ�س���2��');
end
if isstr(img)
    [img,M] = imread(img);
end
if any(scale) <= 0
     error('���ű��� scale��ֵӦ�ô���0��');
end

%% Step2 ͨ��ԭʼͼ����������ӵõ���ͼ��Ĵ�С����������ͼ��
[height,width,channel] = size(img);
if length(scale)==1
    scaleX = scale;
    scaleY = scale;
else
    scaleX = scale(1);
    scaleY = scale(2);
end
newHeight = round(height*scaleY); % �������ź��ͼ��߶ȣ����ȡ��
newWidth = round(width*scaleX); % �������ź��ͼ���ȣ����ȡ��
newImg = zeros(newHeight,newWidth,channel); % ������ͼ��
% ���¼�������ϵ����ע�⣬���������ϵ��ָ�������������ı�ֵ�������������ϵĵ�һ�����������һ������֮��ľ����ȱ����ظ�����1��
scaleX = (newWidth-1)/(width-1);
scaleY = (newHeight-1)/(height-1);

%% Step3 ��չԲͼ���Ե���ײ����Ҳ������һ�У��Ա�߽����ص����
imgEx = zeros(height+1,width+1,channel); 
imgEx(1:height,1:width,:) = img; % ����ԭͼ����չͼ
imgEx(height+1,1:width,:) = img(height,:,:); % ԭͼ�����һ�и��Ƶ���չͼ���һ��
imgEx(1:height,width+1,:) = img(:,width,:);% ԭͼ�����һ�и��Ƶ���չͼ���һ��
imgEx(height+1,width+1,:) = img(height,width,:);% ԭͼ�����½����ظ��Ƶ���չͼ���½�

%% ============================================================
% Step4 ����ͼ��ĵ�i��j�и����أ�j��i��ӳ�䵽ԭʼͼ��(u1��v1)���� ����ԭʼ
% ͼ���(u1,v1)λ����������Χ4�����ص���в�ֵ�õ��õ������ֵ
% ��4����ֱ�Ϊ�����Ͻ�(u,  v),   ���Ͻ�(u+1,  v)
%               ���½�(u,v+1),   ���½�(u+1,v+1)
% % ====================================================================
for j = 1:newWidth         % ��ͼ����а�����Ԫ��ɨ��
    u1 = (j-1)/scaleX+1;
    u = floor(u1);
    dx = u1 - u;  % ��ͬһ�����أ�v1,v,dx�ǹ̶���,��˲��طŵ��ڲ�ѭ�����ظ�����
    for i = 1:newHeight
        % (i,j)��ʾ����ͼ�е����꣬(u1,v1)��ʾ��ԭͼ�е�����
        % ע�⣺(u1,v1)��һ��������
        v1 = (i-1)/scaleY+1; 
        v = floor(v1); 
        dy = v1 - v;
        
        % ��x�������Բ�ֵ
        t1 = dx; t2 = dx;
        Z1 = imgEx(v,u,:) + t1*(imgEx(v,u+1,:) - imgEx(v,u,:));
        Z2 = imgEx(v+1,u,:) + t2*(imgEx(v+1,u+1,:) - imgEx(v+1,u,:));
        % ��y�������Բ�ֵ
        t = dy;
        newImg(i,j,:) = Z1 + t*(Z2-Z1);      
    end
end
newImg = uint8(newImg);
end  