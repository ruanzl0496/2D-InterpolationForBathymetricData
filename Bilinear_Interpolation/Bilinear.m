% ˫���Բ�ֵ
% ��Ҫ˼�룺�ӵ�(x,y)��Χ4������ĵ�(���Ͻ�P1,���Ͻ�P2,���½�P3,���½�P4)������Щ���ֵ�ֱ���x�����y����������Բ�ֵ��һ������3�β�ֵ��
%           �����һ���㲻���ڣ���õ㸳ֵΪnan
function vq = Bilinear(X,Y,V,xq,yq)
    % ʹ v = f(x,y) ��ʽ������������ (X,Y,V) �е�ɢ���������,�ú����� (xq,yq) ָ���Ĳ�ѯ���������в�ֵ�����ز����ֵ vq
    % ��֪���ݵ㣺X,Y,V--������
    % ����ֵ�����㣺xq,yq--���������
    % ���ز�ֵ�����vq--���������

    xLen = numel(xq); % Ԫ�ظ���
    vq = zeros(size(xq));

    for i = 1:xLen  % ��ÿһ�㣨xqi,yqi����ѭ����ֵ
        %% step 1: �ҵ���(xqi,yqi)�����4����(���Ͻ�P1,���Ͻ�P2,���½�P3,���½�P4)
        selector_LT = (X<=xq(i) & Y>=yq(i)); % ���Ϸ���ѡ������
        selector_RT = (X>=xq(i) & Y>=yq(i)); % ���Ϸ���ѡ������
        selector_LB = (X<=xq(i) & Y<=yq(i)); % ���·���ѡ������
        selector_RB = (X>=xq(i) & Y<=yq(i)); % ���·���ѡ������
        if( (sum(selector_LT)==0 && sum(selector_RT)==0) || ...
            (sum(selector_LT)==0 && sum(selector_LB)==0) || ...  
            (sum(selector_LT)==0 && sum(selector_RB)==0) || ...
            (sum(selector_RT)==0 && sum(selector_LB)==0) || ...
            (sum(selector_RT)==0 && sum(selector_RB)==0) || ...
            (sum(selector_LB)==0 && sum(selector_RB)==0)) % �����ĳ2����λû�е�
            vq(i) = nan;
            continue
        end
        
        P1 = [nan nan nan];
        if(sum(selector_LT)>0)
            X1 = X(selector_LT); Y1 = Y(selector_LT); V1 = V(selector_LT);  % �������Ϸ��ĵ�
            dist = ((xq(i)-X1).^2 + (yq(i)-Y1).^2);  % ����(xqi,yqi)������֪��ľ���
            k=1; dist_min = dist(k);
            for j=2:length(dist)
                if(dist(j)<dist_min) dist_min = dist(j); k = j; end
            end
            P1 = [X1(k),Y1(k),V1(k)]; % �����1����
        end
        %[~,I] = sort(dist,'ascend'); % �������о��롣 ��ע���㷨�Ժ�Ľ�������ȫ�������ҵ�4����С�ļ���
        % P1 = [X1(I(1)),Y1(I(1)),V1(I(1))]; % �����1����
        
        P2 = [nan nan nan];
        if(sum(selector_RT)>0)
            X1 = X(selector_RT); Y1 = Y(selector_RT); V1 = V(selector_RT);  % �������Ϸ��ĵ�
            dist = ((xq(i)-X1).^2 + (yq(i)-Y1).^2);  % ����(xqi,yqi)������֪��ľ���
            k=1; dist_min = dist(k);
            for j=2:length(dist)
                if(dist(j)<dist_min) dist_min = dist(j); k = j; end
            end
            P2 = [X1(k),Y1(k),V1(k)]; % �����1����
        end
        
        P3 = [nan nan nan];
        if(sum(selector_LB)>0)
            X1 = X(selector_LB); Y1 = Y(selector_LB); V1 = V(selector_LB);  % �������·��ĵ�
            dist = ((xq(i)-X1).^2 + (yq(i)-Y1).^2);  % ����(xqi,yqi)������֪��ľ���
            k=1; dist_min = dist(k);
            for j=2:length(dist)
                if(dist(j)<dist_min) dist_min = dist(j); k = j; end
            end
            P3 = [X1(k),Y1(k),V1(k)]; % �����1����
        end
        
        P4 = [nan nan nan];
        if(sum(selector_RB)>0)
            X1 = X(selector_RB); Y1 = Y(selector_RB); V1 = V(selector_RB);  % �������·��ĵ�
            dist = ((xq(i)-X1).^2 + (yq(i)-Y1).^2);  % ����(xqi,yqi)������֪��ľ���
            k=1; dist_min = dist(k);
            for j=2:length(dist)
                if(dist(j)<dist_min) dist_min = dist(j); k = j; end
            end
            P4 = [X1(k),Y1(k),V1(k)]; % �����1����
        end
        
        
        
        % ��һ����λ�����ڵ㣬�������λ�ĵ������Ϸ������·��ĵ�ش���
%         if(isnan(P1)) 
%             P1 = P3;
%         elseif(isnan(P2)) 
%             P2 = P4; 
%         end
%         
%         if(isnan(P3)) 
%             P3 = P1;
%         elseif(isnan(P4)) 
%             P4 = P2; 
%         end
        q = [P1(3) P2(3) P3(3) P4(3)];
        if(any(isnan(q)))
            q = q(~isnan(q));
            vq(i)=mean(q);
            continue
        end
               

        %% step 3����x�����ֵ����P1��P2,��x=xqi�����Բ�ֵ���õ���Q1(xqi,yi_1,vi_1);��P3��P4,��x=xi�����Բ�ֵ���õ���Q2(xqi,yi_2,vi_2);
        % P1(x1,y1,v1),P2(x2,y2,v2)����ֵ��P(x,y,v)��v��Ҫ��ֵ�Ĳ���
        % ���Բ�ֵ���㹫ʽ P = P1 + t*(P2 - P1)���� t = (x - x1)/(x2 - x1) �� y = y1 + t*(y2 - y1), z = z1 + t*(v2 - v1)   
        x1 = P1(1); y1 = P1(2); v1 = P1(3);
        x2 = P2(1); y2 = P2(2); v2 = P2(3);
        x3 = P3(1); y3 = P3(2); v3 = P3(3);
        x4 = P4(1); y4 = P4(2); v4 = P4(3);
%         if(abs((y2-y1)/(x2 - x1))<=2)
            t = (xq(i) - x1)/(x2 - x1);
%         else
%             t = 0.5; % ����Ϊ�м��
%         end
        yi_1 = y1 + t*(y2 - y1);
        vi_1 = v1 + t*(v2 - v1);
        % Q1 = [xq(i),yi_1,vi_1];
%         if(abs((y4-y3)/(x4 - x3))<=2)
            t = (xq(i) - x3)/(x4 - x3);
%         else
%             t = 0.5; % ����Ϊ�м��
%         end

        yi_2 = y3 + t*(y4 - y3);
        vi_2 = v3 + t*(v4 - v3);
        % Q2 = [xq(i),yi_2,vi_2];

        %% step 4: ��y�����ֵ����Q1��Q2,��y=yi�����Բ�ֵ���õ���Q(xqi,yqi,vqi);
        % zi����Ҫ��ֵ����Ĳ���
        % ���Բ�ֵ���㹫ʽ Q = Q1 + t*(Q2 - Q1)���� t = (yi - yi_1)/(yi_2 - yi_1) �� vqi = vi_1 + t*(vi_2 - vi_1)   
%         if(abs(yi_2 - yi_1)>Epsilon)
            t = (yq(i) - yi_1)/(yi_2 - yi_1);
%         else
%             t=0.5;
%         end
        vq(i) = vi_1 + t*(vi_2 - vi_1);
        
        %Q = [xq(i),yq(i),vq(i)];
        %disp(['i=',num2str(i),'  vq(i)=',num2str(vq(i))])
%         if(abs(vq(i))>2)
%             %disp(['i=',num2str(i),'  vq(i)=',num2str(vq(i))])
%             vq(i) = (vi_2 + vi_1)/2;
%         end
        

    end

end
