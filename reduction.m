function Dnew = reduction(D,idx,feature_dim)
n = size(D,1);
Dnew = zeros(n,feature_dim);

    for k = 1:n
        temp = D(k,:);
        % fprintf(1, 'INFO:ppps OK,%d  \n\n',size(idx,1));  
        Dnew(k,:) = temp(idx(1:feature_dim));
%         Dnew(k,:) = D(k,idx(1:feature_dim));
    end
    
end