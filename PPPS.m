%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     Pre-Processing P300 Signal Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%     Input:                 'Subject_A_train.mat'   or   'Subject_B_train.mat'
%%%%%     Output:              Result:      a matrix with (85,12,15,60,33)
%%%%%                                  labelR:      a matrix with (85,12,15)        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
clear
%% 原始文件处理
tic;
str='Subject_A_Train.mat';

load(str); % load data file
fprintf(1, 'INFO:Have loaded data and pre-processing now... \n\n' );
% convert to double precision
Signal=double(Signal);
Flashing=double(Flashing);
StimulusCode=double(StimulusCode);
StimulusType=double(StimulusType);

%% 参数
feature_dim=60;
numTrials = size(Signal, 1);
numChars = 12;
numRepeats = 15;
numSamples = 240;                                                           %窗口大小
channel = [1:64];
numChannels = length(channel);
% 6 by 6  matrix
matrix=['ABCDEF','GHIJKL','MNOPQR','STUVWX','YZ1234','56789_'];
full_scale = 240;                                                          %原来的频率
down_sample_scale=4;                                                       %降采样倍数

numSamples = 0.6 * full_scale;
numSamplesUsed = numSamples/down_sample_scale;
numFeatures = numSamplesUsed*numChannels;
numUsedChannels = length(channel);

%% 滤波参数
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





%% 滤波开始
Signal_filtered = zeros(size(Signal));
    for i = 1:numTrials
        Signal_trial = squeeze(Signal(i,:,:));
        Signal_filtered(i,:,:) = reshape(filter(Hd, Signal_trial), 1, size(Signal_trial,1), size(Signal_trial,2));
    end
    fprintf(1, 'INFO:filter complete... \n\n' );

%% 数据和目标
featureTrain = [];
labelTrain = [];

%% 预处理开始
for epoch=1:numTrials                                  %epoch
    
    repeat = zeros(1, numChars);
    signalTrial = zeros(numChars, numRepeats, numSamples, numChannels);
    fprintf(1, 'INFO:  ... \n\n' );

    %% 预处理第一段
    for n=2:size(Signal,2)  %求列数
        if Flashing(epoch,n)==1 && Flashing(epoch,n-1)==0  %字符熄灭的时候
            event = StimulusCode(epoch, n);
            repeat(event) = repeat(event) + 1;
            signalTrial(event, repeat(event), :, :) = Signal_filtered(epoch, n:n+numSamples-1, :); 
           
        end
    end
       
    %% 预处理第二段
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


    
   %% 预处理第三段
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

    %% 预处理第四段 自己加的
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
    
    
% %% 单个p300标签 labelTrain
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





% %第八个预处理：自己加的预处理，平均掉15重复的实验
%     avgresp=mean(responses,3);                          %把responses的一个window里面的数据求一个平均,把15次测量平均
%     avgresp=squeeze(avgresp);                           %重定义avgresp为（12   X   window   X   64）的矩阵，哪一行 X 240个采样点 X 64头上64个采样点
   
%% FCS算法预处理

%       DP=extract(chorespT);
%       DN=extract(chorespNT);  
%      [~,idx] = fcs(DP,DN);    
%      D=reduction(featureTrain,idx,feature_dim);
     
     %Dtrain=extract(featureTrain);
  

%% 打印区

     
     fprintf(1, 'INFO:PPPS finish... \n\n' ); 

%      save 20180514_1 Dtrain Ltrain idx feature_dim;
     save TrainData Dtrain Ltrain
     toc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%我是尾部
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%