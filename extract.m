function D = extract(R)
%Êä³öDD£¨T*lr£¬win*ch£©
%EXTRACT Summary of this function goes here
%   Detailed explanation goes here
    [count,win,ch] = size(R);
    D = zeros(count,win,ch);
    
%     cont = 1;
%     for i = 1:T
%         for j = 1:lr
%                 D(cont,:,:) = R(i,j,:,:);
%                 cont = cont + 1;
%         end
%     end
    
    D=windsorize(R);
    
%     DD = zeros(count,win*ch);
%     for ii = 1:count
%         for jj = 1:ch
%                 DD(ii,(jj-1)*win+1:jj*win) = D(ii,:,jj);
%                 
%         end
%     end
    
%     DDmean = mean(DD,1);
%     DDstd = std(DD);
%     
%     for iii = 1:count
%         for jjj = 1:ch*win
%                 DD(iii,jjj) = (DD(iii,jjj)-DDmean(jjj))/DDstd(jjj);     
%         end
%     end

end

