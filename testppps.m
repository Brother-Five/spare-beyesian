    clear
    tic
    
    str='Subject_A_Test.mat';
    %str2='20180514_1.mat';
    %% 加载文件转换
    load(str); % load data file
    fprintf(1, 'INFO:Have loaded test data and pre-processing now... \n\n' );

    % convert to double precision
    Signal=double(Signal);
    Flashing=double(Flashing);
    StimulusCode=double(StimulusCode);

    %% 参数
    full_scale=240;
    numTrials = size(Signal, 1);
    numChars = 12;
    numRepeats = 15;
    channel = [1:64];
    numChannels = length(channel);
    % 6 by 6  matrix
    matrix=['ABCDEF','GHIJKL','MNOPQR','STUVWX','YZ1234','56789_'];
    featureTest = [];
    labelTest = []; 
    
    %% 结果
    target='WQXPLZCOMRKO97YFZDEZ1DPI9NNVGRQDJCUVRMEUOOOJD2UFYPOO6J7LDGYEGOA5VHNEHBTXOO1TDOILUEE5BFAEEXAW_K4R3MRU';
    targetTrue = zeros(numTrials, 1);
    for i=1:numTrials
        targetTrue(i)=target(i);
    end
    
    %% 使用的特征大小
    %segmentSelected = [0 0.6*full_scale];
    numSamples = 0.6*full_scale;
    down_sample_scale=4;                                                                  %降采样倍数
    numUsedSamples =numSamples/down_sample_scale;
    numFeatures = numUsedSamples*numChannels;
    numUsedChannels = length(channel);

    %% 矩阵  
    featureTrain = [];
    labelTest = [];
    
    %% 滤波器
    
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

    Signal_filtered = zeros(size(Signal));
    for i = 1:numTrials
        Signal_trial = squeeze(Signal(i,:,:));
        Signal_filtered(i,:,:) = reshape(filter(Hd, Signal_trial), 1, size(Signal_trial,1), size(Signal_trial,2));
    end
    fprintf(1, 'INFO:filter complete... \n\n' );
    
    
    %% 
    for epoch=1:numTrials                                  %epoch
        repeat = zeros(1, numChars);
        signalTrial = zeros(numChars, numRepeats, numSamples, numChannels);  
        featureTrial = zeros(numChars, numRepeats, numUsedSamples,numChannels);
        fprintf(1, 'INFO: ... \n\n' );
     
        for n=2:size(Signal,2)  %求列数
           
            
          if Flashing(epoch, n-1)==0 && Flashing(epoch, n)==1
            event = StimulusCode(epoch, n);
            repeat(event) = repeat(event) + 1;
            signalTrial(event, repeat(event), :, :) = Signal_filtered(epoch, n:n+numSamples-1, :);
            
          end
             
        end
 
        
    for char = 1:numChars
        for repeat_1 = 1:numRepeats      
            signalFiltered = squeeze(signalTrial(char, repeat_1, :, :));
            signalDownsampled = downsample(signalFiltered,down_sample_scale);
            for c = 1:numUsedChannels
                featureTrial(char, repeat_1, :,c) = zscore(signalDownsampled(:,c));
            end
%             featureTrial(char, repeat, :) = signalNormalized(:);
        end
    end
    
      featureTrial = reshape(featureTrial, numChars*numRepeats, numUsedSamples, numChannels);
      featureTrain = cat(1, featureTrain, featureTrial);
      targetIndex = strfind(matrix, target(epoch));
      targetRow = floor((targetIndex-1)/6) + 1;
      targetCol = targetIndex - (targetRow-1)*6;
      labelTrial = zeros(numChars,1);
      labelTrial([targetCol,targetRow+6]) = 1;
      ReplabelTrial = repmat(labelTrial,numRepeats,1);
      labelTest = cat(1,labelTest,ReplabelTrial);
      %labelTest = cat(1,labelTest,repmat(labelTrial,numRepeats,1));
    
        fprintf(1, 'INFO： TEST pp to data OK,%d /%d  \n\n',epoch,numTrials);  
        
    end
    
    %% fcs提取特征
%         load('20180514_1.mat', 'feature_dim');
%         Dnew=zeros(numTrials*numChars*numRepeats,feature_dim,numChannels);
%         for i=1:64
%            D          =  featureTrain(:,:,i);
%            idx_buff   =  idx(:,i);
%            Dnew_buff  =  reduction(D,idx_buff,feature_dim);
%            for j=1:numTrials*numChars*numRepeats
%                 Dnew(j,:,i)=Dnew_buff(j,:);
%            end
%         end
    
    
        Dtest = single(featureTrain);
        Ltest = single(labelTest);

        %Dtest=extract(D);                               
%     Dtest = reduction(D,idx,feature_dim);
    
        save TestData Dtest Ltest targetTrue
    
    toc;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
