% ���ڽ���ֵ
% ��Ҫ˼�룺�ӵ�(x,y)��Χ��һ������ĵ㣬�õ��ֵ����Ϊ(x��y)���ֵ��
function vq = NNI(x,y,v,xq,yq)
    % ʹ v = f(x,y) ��ʽ������������ (x,y,v) �е�ɢ���������,�ú����� (xq,yq) ָ���Ĳ�ѯ���������в�ֵ�����ز����ֵ vq
    % ��֪���ݵ㣺x,y,v--������
    % ����ֵ�����㣺xq,yq--���������
    % ���ز�ֵ�����vq--���������

    xqLen = numel(xq); % xqԪ�ظ���
    xLen = numel(x); % xԪ�ظ���
    vq = zeros(size(xq));
    
    for i = 1:xqLen  % ��ÿһ�㣨xqi,yqi����ѭ����ֵ
        %% step 1: �ҵ���(xqi,yqi)�����һ����
        % dist = sqrt((xq(i)-x).^2 + (yq(i)-y).^2);  %
        % ����(xqi,yqi)������֪��ľ���,ʵ�ʲ��ؿ�����
        dist = (xq(i)-x).^2 + (yq(i)-y).^2;  % ����(xqi,yqi)������֪��ľ���
        dist_min = dist(1);
        k = 1; % dist����СԪ�ص�����
        for j = 2:xLen
            if(dist(j)<dist_min)
                dist_min = dist(j);
                k = j;
            end
        end
        vq(i) = v(k);
    end

end
