function [varargout] = SBDA(y,X,group)      
             
   % PHI = cat(2, ones(size(X,1),1), X);
    PHI = X;
    [N, P] = size(PHI);
    
    %��Ȩ��
    group   = [0;group(:)];                       % ת��
    groupid = unique(group);
    NG      = length(groupid);
    
    %������ʼ��
    alphas = 2*ones(P, 1);
    beta = 10;
    w = ones(P,1);
    d_w = Inf;
    evidence = -Inf;
    d_evidence = Inf;
    maxit = 50;
    stopeps = 1e-6;
    maxvalue = 1e9;
    
    d = myeig(PHI);
    
    i=1;%����ϵ��
    while (d_evidence > stopeps) && (d_w > stopeps)  && (i < maxit)
        
        wold = w;
        evidenceold = evidence; 

        %% ȥ����ֵ���alpha
        index0 = find(alphas > maxvalue);
        index1 = setdiff(1:P, index0);
        
        if (length(index1) <= 0)
            disp('Optimization terminated due that all alphas are large.');
            break;
        end
        alphas1 = alphas(index1);
        PHI1 = PHI(:,index1);
        
        %% ������sigma
        [N1,P1] = size(PHI1);
        if (P1>N1)
            Sigma1 = woodburyinv(diag(alphas1), PHI1', PHI1, (1/beta)*eye(N));
        else
            Sigma1 = (diag(alphas1) + beta*PHI1'*PHI1)^(-1);
        end
         
       %% ������Ȩ��w�ľ�ֵ
        diagSigma1 = diag(Sigma1);
        w1 = beta*Sigma1*PHI1'*y;
        w(index1) = w1;
        if(~isempty(index0)) w(index0) = 0; end
        
        %% �����gamma
        gamma1 = 1 - alphas1.*diagSigma1;
        gamma = zeros(size(alphas));
        gamma(index1) = gamma1;
        
        
        %% ���������alpha
        for g = 1:NG 
            
            index_ig = find(group == groupid(g));
            w_ig = w(index_ig);
            
            if norm(w_ig) == 0, continue; end
            
            gamma_ig = gamma(index_ig);
            alpha_ig = sum(gamma_ig)/(w_ig'*w_ig);
            alphas(index_ig) = alpha_ig;
            
        end
        
       %% ������beta
        rmse = sum((y-PHI*w).^2);
        beta  = (N-sum(gamma))/rmse;
        
       %% �����evidence
        evidence = (1/2)*sum(log(alphas)) + (N/2)*log(beta) - ...
        (beta/2)*rmse - (1/2)*w'*diag(alphas)*w - ...
        (1/2)*sum(log((beta*d+alphas))) - (N/2)*log(2*pi);
    
       %% �жϵ���������
        d_w = norm(w-wold);
        d_evidence = abs(evidence-evidenceold);
        
        
        disp(['INFO:Iteration ' num2str(i)  ': evidence = ' num2str(evidence) ...
        ', wchange = ' num2str(d_w) ', rmse = ' num2str(rmse) ', beta = ' num2str(beta)]);
    
        i = i + 1;
    end
    
    for j=1:size(w,1)
       if w(j)~=0
           fprintf('channel is %d',j);
       end
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