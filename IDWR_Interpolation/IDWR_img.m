function newImg = IDWR_img(img,scale)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% ���ܣ��������ӻع�Ȩ��ֵ�����ž����ͼ��
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
% Step4 ����ͼ��ĵ�i��j�и����ص㣨j,i��ӳ�䵽ԭʼͼ��(u1��v1)���� ����ԭʼ
% ͼ���(u1,v1)λ����������Χ4�����ص���в�ֵ�õ��õ������ֵ
% ��4����ֱ�Ϊ�����Ͻ�(u,  v),   ���Ͻ�(u+1,  v)
%               ���½�(u,v+1),   ���½�(u+1,v+1)
% % ====================================================================
epsilon = 1e-5; % ������0���Ƚϵ����
for j = 1:newWidth         % ��ͼ����а�����Ԫ��ɨ��
    u1 = (j-1)/scaleX+1;
    u = floor(u1);
    dx = u1 - u;  % ��ͬһ�����أ�v1,v,dx�ǹ̶���,��˲��طŵ��ڲ�ѭ�����ظ�����
    a= dx*dx;   c = (1-dx)*(1-dx);
    for i = 1:newHeight
        % (j,i)��ʾ����ͼ�е����꣬(u1,v1)��ʾ��ԭͼ�е�����
        % ע�⣺(u1,v1)��һ��������
        v1 = (i-1)/scaleY+1; 
        v = floor(v1); 
        dy = v1 - v;
        
        % ����Χ�ĸ���ľ���ĵ���
        %d1 = sqrt(u*u+v*v); d2 = sqrt((1-u)*(1-u)+v*v);
        %d3 = sqrt(u*u+(1-v)*(1-v));d4 = sqrt((1-u)*(1-u)+(1-v)*(1-v));
        %a = u*u; b= v*v; c = (1-u)*(1-u); d = (1-v)*(1-v);
        b = dy*dy; d = (1-dy)*(1-dy); 
        
        if b+a<=epsilon  % ����㴦��
            newImg(i,j,:) = imgEx(v,u,:);
        elseif d+a<=epsilon
            newImg(i,j,:) = imgEx(v,u+1,:);
        elseif b+c<=epsilon
            newImg(i,j,:) = imgEx(v+1,u,:);
        elseif d+c<=epsilon
            newImg(i,j,:) = imgEx(v+1,u+1,:);
        else  % һ��㴦��
            w11 = 1/(a+b); % (u1,v1)�����Ͻ�(u,v)�ľ����ƽ���ĵ���
            w12 = 1/(b+c); % (u1,v1)�����Ͻ�(u+1,v)�ľ����ƽ���ĵ���
            w21 = 1/(a+d); % (u1,v1)�����½�(u,v+1)�ľ����ƽ���ĵ���
            w22 = 1/(c+d); % (u1,v1)�����½�(u+1,v+1)�ľ����ƽ���ĵ���
            D = (w11+w12+w21+w22);  % �����ƽ���ĵ���֮��
            y_IDW = (w11*imgEx(v,u,:) + w12*imgEx(v,u+1,:)...
                + w21*imgEx(v+1,u,:) + w22*imgEx(v+1,u+1,:))/D; % ��������Ȩ
           n = 4;
            newImg(i,j,:) = y_IDW + n * ( (imgEx(v,u,:)+imgEx(v,u+1,:)+imgEx(v+1,u,:)+imgEx(v+1,u+1,:))- n*y_IDW ) / ( n^2 - (1/w11+1/w12+1/w21+1/w22)*D );
            %newImg(i,j,:)=mod(newImg(i,j,:),255);
%             delta=( (imgEx(v,u,:)+imgEx(v,u+1,:)+imgEx(v+1,u,:)+imgEx(v+1,u+1,:))- n*y_IDW ) / ( n^2 - (1/w11+1/w12+1/w21+1/w22)*D );
%             if delta>200
%                 disp(['delata=',num2str(delta)])
%                 pause
%             end
        end
        
    end
end
newImg = uint8(newImg);

end  