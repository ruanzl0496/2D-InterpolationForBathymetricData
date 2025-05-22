function newImg = nearest_img(img,scale)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%-----------------����ڲ�ֵ�����ž����ͼ��---------------------
% ���룺
%       img--ԭʼͼ��ͼ���ļ������������ֵ��0~255����
%       scale--�������ӣ������ŵı���,��Ϊ��������[scaleX,scaleY]
% �����
%       newImg--���ź��ͼ����� 
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
if length(scale)==1  % ˮƽ����ʹ���ȱ�������
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

%% Step3 ����ڲ�ֵ
for j = 1:newWidth         % ��ͼ����а�����Ԫ��ɨ�衣ע�⣬��Ҫ����ѭ��������ǳ��ǳ�������Ϊmatlab������洢!
    v = round((j-1)/scaleX+1);
    for i = 1:newHeight % �����е�����Ԫ��
        u = round((i-1)/scaleY+1); % ��������
        newImg(i,j,:) = img(u,v,:);  % ӳ��ͼ��
    end
end

newImg = uint8(newImg);

end  