function vq = Bilinear(X,Y,V,xq,yq)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Scattered Data Surface Interpolation using Bilinear Algorithm
% Inputs:
%   X, Y, V -- Vectors of scattered data points
%   xq, yq -- Vectors or matrices of coordinates for unknown points
% Outputs:
%   vq -- Vector or matrix of values for unknown points
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

    xLen = numel(xq); % Number of elements
    vq = zeros(size(xq));

    for i = 1:xLen  % Interpolate for each point (xqi,yqi)
        %% Step 1: Find the 4 nearest points to (xqi,yqi) (Top-left P1, Top-right P2, Bottom-left P3, Bottom-right P4)
        selector_LT = (X<=xq(i) & Y>=yq(i)); % Condition for top-left point
        selector_RT = (X>=xq(i) & Y>=yq(i)); % Condition for top-right point
        selector_LB = (X<=xq(i) & Y<=yq(i)); % Condition for bottom-left point
        selector_RB = (X>=xq(i) & Y<=yq(i)); % Condition for bottom-right point
        if( (sum(selector_LT)==0 && sum(selector_RT)==0) || ...
            (sum(selector_LT)==0 && sum(selector_LB)==0) || ...  
            (sum(selector_LT)==0 && sum(selector_RB)==0) || ...
            (sum(selector_RT)==0 && sum(selector_LB)==0) || ...
            (sum(selector_RT)==0 && sum(selector_RB)==0) || ...
            (sum(selector_LB)==0 && sum(selector_RB)==0)) % If any two directions have no points
            vq(i) = nan;
            continue
        end
        
        P1 = [nan nan nan];
        if(sum(selector_LT)>0)
            X1 = X(selector_LT); Y1 = Y(selector_LT); V1 = V(selector_LT);  % All top-left points
            dist = ((xq(i)-X1).^2 + (yq(i)-Y1).^2);  % Calculate the distance from (xqi,yqi) to each known point
            k=1; dist_min = dist(k);
            for j=2:length(dist)
                if(dist(j)<dist_min) dist_min = dist(j); k = j; end
            end
            P1 = [X1(k),Y1(k),V1(k)]; % The nearest point
        end
        %[~,I] = sort(dist,'ascend'); % Sort distances in ascending order. Note: The algorithm will be improved later to find the 4 smallest distances without sorting all.
        % P1 = [X1(I(1)),Y1(I(1)),V1(I(1))]; % The nearest point
        
        P2 = [nan nan nan];
        if(sum(selector_RT)>0)
            X1 = X(selector_RT); Y1 = Y(selector_RT); V1 = V(selector_RT);  % All top-right points
            dist = ((xq(i)-X1).^2 + (yq(i)-Y1).^2);  % Calculate the distance from (xqi,yqi) to each known point
            k=1; dist_min = dist(k);
            for j=2:length(dist)
                if(dist(j)<dist_min) dist_min = dist(j); k = j; end
            end
            P2 = [X1(k),Y1(k),V1(k)]; % The nearest point
        end
        
        P3 = [nan nan nan];
        if(sum(selector_LB)>0)
            X1 = X(selector_LB); Y1 = Y(selector_LB); V1 = V(selector_LB);  % All bottom-left points
            dist = ((xq(i)-X1).^2 + (yq(i)-Y1).^2);  % Calculate the distance from (xqi,yqi) to each known point
            k=1; dist_min = dist(k);
            for j=2:length(dist)
                if(dist(j)<dist_min) dist_min = dist(j); k = j; end
            end
            P3 = [X1(k),Y1(k),V1(k)]; % The nearest point
        end
        
        P4 = [nan nan nan];
        if(sum(selector_RB)>0)
            X1 = X(selector_RB); Y1 = Y(selector_RB); V1 = V(selector_RB);  % All bottom-right points
            dist = ((xq(i)-X1).^2 + (yq(i)-Y1).^2);  % Calculate the distance from (xqi,yqi) to each known point
            k=1; dist_min = dist(k);
            for j=2:length(dist)
                if(dist(j)<dist_min) dist_min = dist(j); k = j; end
            end
            P4 = [X1(k),Y1(k),V1(k)]; % The nearest point
        end
                   

        % If a direction has no points, use the points directly above or below to replace it
        q = [P1(3) P2(3) P3(3) P4(3)];
        if(any(isnan(q)))
            q = q(~isnan(q));
            vq(i)=mean(q);
            continue
        end
               
        %% Step 3: Interpolate in the x-direction. Interpolate between P1 and P2 at x=xqi to obtain point Q1(xqi,yi_1,vi_1); interpolate between P3 and P4 at x=xi to obtain point Q2(xqi,yi_2,vi_2);
        % Given points P1(x1,y1,v1) and P2(x2,y2,v2), the interpolation point P(x,y,v) is calculated as follows:
        % Linear interpolation formula: P = P1 + t*(P2 - P1), where t = (x - x1)/(x2 - x1), y = y1 + t*(y2 - y1), and v = v1 + t*(v2 - v1)   
        x1 = P1(1); y1 = P1(2); v1 = P1(3);
        x2 = P2(1); y2 = P2(2); v2 = P2(3);
        x3 = P3(1); y3 = P3(2); v3 = P3(3);
        x4 = P4(1); y4 = P4(2); v4 = P4(3);
%         if(abs((y2-y1)/(x2 - x1))<=2)
            t = (xq(i) - x1)/(x2 - x1);
%         else
%             t = 0.5; % Approximate as the midpoint
%         end
        yi_1 = y1 + t*(y2 - y1);
        vi_1 = v1 + t*(v2 - v1);
        % Q1 = [xq(i),yi_1,vi_1];
%         if(abs((y4-y3)/(x4 - x3))<=2)
            t = (xq(i) - x3)/(x4 - x3);
%         else
%             t = 0.5; % Approximate as the midpoint
%         end

        yi_2 = y3 + t*(y4 - y3);
        vi_2 = v3 + t*(v4 - v3);
        % Q2 = [xq(i),yi_2,vi_2];

        %% Step 4: Interpolate in the y-direction. Interpolate between Q1 and Q2 at y=yi to obtain point Q(xqi,yqi,vqi);
        % The value vqi is calculated using linear interpolation:
        % Linear interpolation formula: Q = Q1 + t*(Q2 - Q1), where t = (yi - yi_1)/(yi_2 - yi_1), and vqi = vi_1 + t*(vi_2 - vi_1)   
%         if(abs(yi_2 - yi_1)>Epsilon)
            t = (yq(i) - yi_1)/(yi_2 - yi_1);
%         else
%             t=0.5;
%         end
        vq(i) = vi_1 + t*(vi_2 - vi_1);
    end

end