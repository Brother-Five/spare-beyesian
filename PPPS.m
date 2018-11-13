%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     Pre-Processing P300 Signal Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     Input:                 'Subject_A_train.mat'   or   'Subject_B_train.mat'
%%%%%     Output:              Result:      a matrix with (85,12,15,60,33)
%%%%%                                  labelR:      a matrix with (85,12,15)        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
clear
%% ԭʼ�ļ�����
tic;
str='Subject_A_Train.mat';

load(str); % load data file
fprintf(1, 'INFO:Have loaded data and pre-processing now... \n\n' );
% convert to double precision
Signal=double(Signal);
Flashing=double(Flashing);
StimulusCode=double(StimulusCode);
StimulusType=double(StimulusType);

%% ����
feature_dim=60;
numTrials = size(Signal, 1);
numChars = 12;
numRepeats = 15;
numSamples = 240;                                                           %���ڴ�С
channel = [1:64];
numChannels = length(channel);
% 6 by 6  matrix
matrix=['ABCDEF','GHIJKL','MNOPQR','STUVWX','YZ1234','56789_'];
full_scale = 240;                                                          %ԭ����Ƶ��
down_sample_scale=4;                                                       %����������

numSamples = 0.6 * full_scale;
numSamplesUsed = numSamples/down_sample_scale;
numFeatures = numSamplesUsed*numChannels;
numUsedChannels = length(channel);

%% �˲�����
order = 10;
fstop1 = 0;    % First Stopband Frequency
fpass1 = 0.5;  % First Passband Frequency
fpass2 = 20;   % Second Passband Frequency
fstop2 = 21;   % Second Stopband Frequency
wstop1 = 1;    % First Stopband Weight
wpass  = 1;    % Passband Weight
wstop2 = 2;    % Second Stopband Weight
dens  = 20;     % Density Factor
b  = firpm(order, [0 fstop1 fpass1 fpass2 fstop2 full_scale/2]/(full_scale/2), [0 0 1 1 0 ...
    0], [wstop1 wpass wstop2], {dens});
Hd = dfilt.dffir(b);





%% �˲���ʼ
Signal_filtered = zeros(size(Signal));
    for i = 1:numTrials
        Signal_trial = squeeze(Signal(i,:,:));
        Signal_filtered(i,:,:) = reshape(filter(Hd, Signal_trial), 1, size(Signal_trial,1), size(Signal_trial,2));
    end
    fprintf(1, 'INFO:filter complete... \n\n' );

%% ���ݺ�Ŀ��
featureTrain = [];
labelTrain = [];

%% Ԥ����ʼ
for epoch=1:numTrials                                  %epoch
    
    repeat = zeros(1, numChars);
    signalTrial = zeros(numChars, numRepeats, numSamples, numChannels);
    fprintf(1, 'INFO:  ... \n\n' );

    %% Ԥ�����һ��
    for n=2:size(Signal,2)  %������
        if Flashing(epoch,n)==1 && Flashing(epoch,n-1)==0  %�ַ�Ϩ���ʱ��
            event = StimulusCode(epoch, n);
            repeat(event) = repeat(event) + 1;
            signalTrial(event, repeat(event), :, :) = Signal_filtered(epoch, n:n+numSamples-1, :); 
           
        end
    end
       
    %% Ԥ����ڶ���
     featureTrial = zeros(numChars, numRepeats, numFeatures);
    for char = 1:numChars
        for repeat_1 = 1:numRepeats
           
            signalFiltered = squeeze(signalTrial(char, repeat_1, :, :));
            
            signalDownsampled = downsample(signalFiltered,down_sample_scale);
            for c = 1:numUsedChannels
                signalNormalized(:,c) = zscore(signalDownsampled(:,c));
            end
            featureTrial(char, repeat_1, :) = signalNormalized(:);
        end
    end


    
   %% Ԥ���������
     featureTrial = reshape(featureTrial, numChars*numRepeats, numSamplesUsed, numChannels);
     %fprintf(1, 'INFO: %d   \n\n',numSamplesUsed);
     featureTrain = cat(1, featureTrain, featureTrial);
     targetIndex = strfind(matrix, TargetChar(epoch));
     targetRow = floor((targetIndex-1)/6) + 1;
     targetCol = targetIndex - (targetRow-1)*6;
     labelTrial = zeros(numChars,1);
     labelTrial([targetCol,targetRow+6]) = 1;
     labelTrain = cat(1,labelTrain,repmat(labelTrial,numRepeats,1));
       
    fprintf(1, 'INFO:ppps OK,%d /%d  \n\n',epoch,numTrials);    
end


    



Dtrain = single(featureTrain);
Ltrain = single(labelTrain);

    %% Ԥ������Ķ� �Լ��ӵ�
%     P300_feature=zeros(numTrials*numChars*numRepeats/6,numSamplesUsed,64);
%     No_P300_feature=zeros(numTrials*numChars*numRepeats*5/6,numSamplesUsed,64);
%     count1=0;
%     count2=0;
%     idx=zeros(numSamplesUsed,64);
%     Dnew=zeros(numTrials*numChars*numRepeats,feature_dim,numChannels);
%     
%     for i=1:numTrials*numChars*numRepeats
%         if Ltrain(i)==1
%             count1=count1+1;
%             P300_feature(count1,:,:)=Dtrain(i,:,:);
%         else
%             count2=count2+1;
%             No_P300_feature(count2,:,:)=Dtrain(i,:,:);
%         end
%         fprintf(1, 'INFO:split the feature... OK,%.3f %%  \n\n',i*100/(numTrials*numChars*numRepeats));  
%     end
% 
%     for i=1:64
%        D=Dtrain(:,:,i);
%        xp=P300_feature(:,:,i);
%        xn=No_P300_feature(:,:,i);
%        idx_buff = fcs(xp,xn);
%        idx(:,i)=idx_buff;
%        Dnew_buff = reduction(D,idx_buff,feature_dim);
%        for j=1:numTrials*numChars*numRepeats
%             Dnew(j,:,i)=Dnew_buff(j,:);
%        end
%     end
    
%     Dtrain=Dnew;
%     
    
    
% %% ����p300��ǩ labelTrain
% for i=1:size(labelTrain,1)
%     
%     
%     if labelTrain(i)==1
%         count1=count1+1;
%         for j=1:numChannels
%             chorespT(count1,:,j)=featureTrain(i,:,j);
%         end
%     end
%     
%     if labelTrain(i)==0
%         count2=count2+1;
%         for j=1:numChannels
%             chorespNT(count2,:,j)=featureTrain(i,:,j);
%         end
%     end
% end





% %�ڰ˸�Ԥ�����Լ��ӵ�Ԥ����ƽ����15�ظ���ʵ��
%     avgresp=mean(responses,3);                          %��responses��һ��window�����������һ��ƽ��,��15�β���ƽ��
%     avgresp=squeeze(avgresp);                           %�ض���avgrespΪ��12   X   window   X   64���ľ�����һ�� X 240�������� X 64ͷ��64��������
   
%% FCS�㷨Ԥ����

%       DP=extract(chorespT);
%       DN=extract(chorespNT);  
%      [~,idx] = fcs(DP,DN);    
%      D=reduction(featureTrain,idx,feature_dim);
     
     %Dtrain=extract(featureTrain);
  

%% ��ӡ��

     
     fprintf(1, 'INFO:PPPS finish... \n\n' ); 

%      save 20180514_1 Dtrain Ltrain idx feature_dim;
     save TrainData Dtrain Ltrain
     toc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%����β��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%