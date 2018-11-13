function [responses_train,label_train,responses_test,label_test]=split_dataset(alpha,D,L)
idx=randperm(size(D,1));
Dmess=D(idx,:);
Lmess=L(idx,:);
responses_train(:,:)=Dmess(1:alpha*(size(Dmess)),:);
label_train(:,:)=Lmess(1:alpha*(size(Dmess)),:);
responses_test(:,:)=Dmess(alpha*(size(Dmess))+1:end,:);
label_test(:,:)=Lmess(alpha*(size(Dmess))+1:end,:);



% DP=D(1:.5*size(D),:);
% DN=D(.5*size(D)+1:end,:);
%       for i=1:size(D,1)
%           
%             if cnt=<5
%                 Dmass(i,:)=DP(i,:);
%             else cnt>5
%                 Dmass(i,:)=DN(i-5,:);
%                 if cnt=10
%                     cnt=0;
%                 end
%             end
%       end



end