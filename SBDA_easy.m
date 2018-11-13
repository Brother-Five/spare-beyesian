function [varargout]=SBDA_easy(y,X)
    
    PHI = cat(2, ones(size(X,1),1), X);
    [N, P] = size(PHI);
    
     %参数初始化
    alphas = 2*ones(P, 1);
    beta = 10;
    w = ones(P,1);
    d_w = Inf;
    evidence = -Inf;
    d_evidence = Inf;
    maxit = 50;
    stopeps = 1e-6;
    maxvalue = 1e9;
    
    d = myeig(PHI);%特征值
    
    i=1;%迭代系数
    while (d_evidence > stopeps) && (d_w > stopeps)  && (i < maxit)
        
        wold = w;
        evidenceold = evidence; 

        %% 去除数值大的alpha
        index0 = find(alphas > maxvalue);
        index1 = setdiff(1:P, index0);
        
        if (length(index1) <= 0)
            disp('Optimization terminated due that all alphas are large.');
            break;
        end
        alphas1 = alphas(index1);
        PHI1 = PHI(:,index1);
        
        %% 迭代出sigma
        [N1,P1] = size(PHI1);
        if (P1>N1)
            Sigma1 = woodburyinv(diag(alphas1), PHI1', PHI1, (1/beta)*eye(N));
        else
            Sigma1 = (diag(alphas1) + beta*PHI1'*PHI1)^(-1);
        end
        
        %% 迭代出权重w的均值
        diagSigma1 = diag(Sigma1);
        w1 = beta*Sigma1*PHI1'*y;
        w(index1) = w1;
        if(~isempty(index0)) w(index0) = 0; end
        
        %% 计算出alpha
        for g = 1:P1 
            
            %index_ig = find(group == groupid(g));
            %w_ig = w(index_ig);
            
            %if norm(w_ig) == 0, continue; end
            
            alphas(g)=1/(diagSigma1(g)+w1(g)^2);
            
%             gamma_ig = gamma(index_ig);
%             alpha_ig = sum(gamma_ig)/(w_ig'*w_ig);
%             alphas(index_ig) = alpha_ig;
        end
        
        rmse = sum((y-PHI1*w).^2);
        beta =N1/(trace(PHI1'*PHI1*Sigma1)+rmse);
        
         %% 计算出evidence
        evidence = (1/2)*sum(log(alphas)) + (N/2)*log(beta) - ...
        (beta/2)*rmse - (1/2)*w'*diag(alphas)*w - ...
        (1/2)*sum(log((beta*d+alphas))) - (N/2)*log(2*pi);
        
    %% 判断迭代的条件
        d_w = norm(w-wold);
        d_evidence = abs(evidence-evidenceold);
        
        
%         disp(['INFO:Iteration ' num2str(i)  ': evidence = ' num2str(evidence) ...
%         ', wchange = ' num2str(d_w) ', rmse = ' num2str(rmse) ', beta = ' num2str(beta)]);
    
        i = i + 1;
    end
    
    
        if(i < maxit)
        fprintf('Optimization of alpha and beta successfull.\n');
    else
        fprintf('Optimization terminated due to max iteration.\n');
    end
    
    b = w(2:P);
    b0 = w(1);

    if nargout   == 1
        model.b  = b;
        model.b0 = b0;
        varargout{1} = model;
    elseif nargout   == 2
        varargout{1} = b;
        varargout{2} = b0;
    end
end