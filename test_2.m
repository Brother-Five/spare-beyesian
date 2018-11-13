% function predict_rate=test_2(D,L,idx,Dtest,code_test)
function test_2(feature_dim)
tic
load('TrainData.mat');
load('TestData.mat');
matrix=['ABCDEF','GHIJKL','MNOPQR','STUVWX','YZ1234','56789_'];

%[responses_train,label_train,responses_test,label_test]=split_dataset(alpha,D,L);
featureTrain = double(Dtrain);
labelTrain   = double(Ltrain);
clear Dtrain ;
clear Ltrain;

%feature_dim  = 1900; 
numChars     = 12;
numRepeats   = 15;
numSamples   = size(featureTrain,2);
numChannels  = size(featureTrain,3);
numTrain = size(featureTrain,1)/(numChars*numRepeats);
groupChannel = reshape(repmat(1:numChannels,numSamples,1),1,numChannels*numSamples);



fprintf(1, 'INFO:Trainning... \n\n' );
X = featureTrain;
X = reshape(X,size(X,1),size(X,2)*size(X,3));
X = svmscale(X,[0 1],'range','s');
y = labelTrain;
y(y==0) = -1;
clear featureTrain;
clear labelTrain;

%% 20180531test
X_2d=X(:,:);
idxp300 = find(y==1);
idxnp300 = find(y==-1);
idx_fcs = fcs(X(idxp300,:),X(idxnp300,:));
X = reduction(X_2d,idx_fcs,feature_dim);





%% ѵ����
%train_model = SBDA(y, X, groupChannel);   
train_model = SBDA_easy(y, X);  
fprintf(1, 'INFO:Train over... \n\n' );

%% test���ݵ�Ԥ����
load('20180514_2.mat');
featureTest  = double(Dtest);
labelTest    = double(Ltest);
numTest = size(featureTest,1)/(numChars*numRepeats);

%% ����ģ�ͷ���
fprintf(1, 'INFO:Classifying... \n\n' );
X = featureTest;
X = reshape(X,size(X,1),size(X,2)*size(X,3));
X = svmscale(X,[0 1],'range','r');
y = labelTest;
y(y==0) = -1;
clear featureTest;
clear labelTest;
%%20180531test
X_2d=X(:,:);
X = reduction(X_2d,idx_fcs,feature_dim);

idxp = find(y==1);
idxn = find(y==-1);

yprob = X*train_model.b + train_model.b0;
ypred = sign(yprob);

%% ��������
TP = length(find(ypred(idxp)==1));
FP = length(find(ypred(idxn)==1));
TN = length(find(ypred(idxn)==-1));
FN = length(find(ypred(idxp)==-1));
confusion = [TP,TN,FP,FN];

fprintf(1, 'INFO:Confusion Matrix is  ... \n\n' );
for i=1:4
    fprintf(1, 'INFO:%d /' ,confusion(i));
end
fprintf(1, '\n\n' );


targetPredicted = zeros(numRepeats,numTest);
for trial = 1:numTest
    yprob1 = yprob(:,1);
    ytrial = yprob1((trial-1)*numChars*numRepeats+(1:numChars*numRepeats));
    ytrial = reshape(ytrial,numChars,numRepeats);
    for repeat = 1:numRepeats
        yavg = mean(ytrial(:,1:repeat),2);
        [dummy,pRow] = max(yavg(7:12));
        [dummy,pCol] = max(yavg(1:6));
        targetPredicted(repeat,trial) = matrix((pRow-1)*6+pCol);
    end
end

for j = 1:numRepeats
    accuracyTest(j) = length(find(squeeze(targetPredicted(j,:)) == targetTrue'))/numTest;
    fprintf(1, 'INFO:VALIDATION ACCURACIES is %.f %% \n\n',accuracyTest(j)*100);
end

disp('showing results');

% f2 = figure;
% hold on; grid on;
% plot(accuracyTest*100,'r-','LineWidth',1);
% axis([1 numRepeats 0 100]);
% xlabel('Repetition(n)');
% ylabel('Accuracy of prediction(%)');
% title(['Feature number is ',num2str(feature_dim)],'Fontsize',16);
toc

% ԭ����
% [count,no]=size(featureTrain);                         %������Ŀcount����������no
% w = ones(1,no);                                        %ÿһ��Ȩ������wi���Ǹ�˹�ֲ�
% labelTrain(labelTrain==0) = -1; 
% t=labelTrain;                                          %T�Ǳ�ǩ ��ÿһ�ж���һ����ǩti
% train_time=30;                                         %ѵ���Ĵ���
% X=featureTrain;                                         
% count_1=0;

          
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %      ��ʼ������                                    %
 %      ������c��m��a��b                              %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  a = 2*ones(1,no);                            %ai��wi�������prior���淽��
%  b =10;                                       %ai��wi�������prior���淽��
  %%% ����ѵ��
  

  
% %% DIY�汾 
%     for i=1:train_time
%         
%         A = diag(a);
%         c=(A+b*X'*X)^-1;
%         m=b*c*X'*t;  %�����Ҹ���һ��X���ĳ�X'
%         %pw_tXab=distribute(m,c);
%         for j=1:size(a,2)
%             a(j)=1/(c(j,j)+m(j)^2);
%         end
%         b=count/(trace(X'*X*c)+(norm(X*m-t,2))^2);
%        
%         fprintf(1, 'INFO:number is %d \n\n',i);
%     end
%     
%     w=m;
%     

end
    

   