%cd:
%Y:\Graduation Project\test_2
clc
clear all

load('Subject_A_Train.mat');
%% parameters
windows      = 200;      % window after stimulus, the sampling rate is 240Hz,resample to 32Hz
feature_dim =500;        %特征维数

tic;
% TargetChar=[];


fprintf(1, 'INFO:Have loaded data and pre-processing now... \n\n' );
% convert to double precision
Signal=double(Signal);
Flashing=double(Flashing);
StimulusCode=double(StimulusCode);
StimulusType=double(StimulusType);


%responses = zeros(size(Signal,1)*12*15,windows,64);
responses_0= zeros(size(Signal,1)*12*15,windows,64);
responses_1= zeros(size(Signal,1)*12*15,windows/4,64);
responses_3=zeros(size(Signal,1)*12*15,windows,64);
label=zeros(size(Signal,1)*12*15);
chorespT=zeros(size(Signal,1)*12*15/6,windows/4,64);
chorespNT=zeros(size(Signal,1)*12*15*5/6,windows/4,64);
count_1=0;
count_2=0;
count_3=0;

fs = 240;
order = 10;
fstop1 = 0;    % First Stopband Frequency
fpass1 = 0.5;  % First Passband Frequency
fpass2 = 20;   % Second Passband Frequency
fstop2 = 21;   % Second Stopband Frequency
wstop1 = 1;    % First Stopband Weight
wpass  = 1;    % Passband Weight
wstop2 = 2;    % Second Stopband Weight
dens  = 20;     % Density Factor
b  = firpm(order, [0 fstop1 fpass1 fpass2 fstop2 fs/2]/(fs/2), [0 0 1 1 0 ...
    0], [wstop1 wpass wstop2], {dens});
Hd = dfilt.dffir(b);
numTrials = size(Signal, 1);

Signal_filtered = zeros(size(Signal));
    for i = 1:numTrials
        Signal_trial = squeeze(Signal(i,:,:));
        Signal_filtered(i,:,:) = reshape(filter(Hd, Signal_trial), 1, size(Signal_trial,1), size(Signal_trial,2));
    end
    fprintf(1, 'INFO:filter complete... \n\n' );

%{
获取responses
responses(epoch,rowcol,rowcolcnt(rowcol),time即截取窗口大小,channel)
%}
for epoch=1:size(Signal,1)                                   %epoch
    
    %降采样
%     Flashing_1(epoch,:)=downsample(Flashing(epoch,:),4);
%     StimulusCode_1(epoch,:)=downsample(StimulusCode(epoch,:),4);
%     StimulusType_1(epoch,:)=downsample(StimulusType(epoch,:),4);  
    fprintf(1, 'INFO:Downsample ... \n\n' );
    
    
    
    
    
    for channel=1:64
        
        %第一个预处理：参考电位,以T7和T8为参考电位，符号41，42
        if (channel~=41)&(channel~=42)
          Signal(epoch,:,channel)=Signal_filtered(epoch,:,channel)-0.5*Signal_filtered(epoch,:,41)-0.5*Signal_filtered(epoch,:,42);
        end
        
    end

    
%       rowcolcnt=ones(1,12);%创建一个全一列向量，计数各个行列出现的次数并堆放整齐
    for n=2:size(Signal,2)  %求列数
        if Flashing(epoch,n)==0 && Flashing(epoch,n-1)==1 %字符熄灭的时候
            count_1=count_1+1;
            %rowcol=StimulusCode(epoch,n-1);                                  %12行中哪一行
            responses_0(count_1,:,:)=Signal(epoch,n-24:n-25+windows,:);   %截取出该周期的采样点从（n-24+120）开始的window个
            for j=1:64
          
                responses_1(count_1,:,j)=responses_3(count_1,1:4:end,j);
               
            end
            
            %responses_1(count_1,:,:)=downsample(responses(count_1,:,:),4);
            code(count_1)=StimulusCode(epoch,n-1);
            label(count_1)=StimulusType(epoch,n-1);
            
            if label(count_1)==1
                count_2=count_2+1;
                chorespT(count_2,:,:)=responses_1(count_1,:,:);
            else 
                count_3=count_3+1;
                chorespNT(count_3,:,:)=responses_1(count_1,:,:);%获取非P300反应
                
            end
            %rowcolcnt(rowcol)=rowcolcnt(rowcol)+1;                                                                                 %12行的出现次数count
           
        end
    end   
    
    fprintf(1, 'INFO:first step to data OK,%d /85 \n\n',epoch );    
end

% %第八个预处理：自己加的预处理，平均掉15重复的实验
%     avgresp=mean(responses,3);                          %把responses的一个window里面的数据求一个平均,把15次测量平均
%     avgresp=squeeze(avgresp);                           %重定义avgresp为（12   X   window   X   64）的矩阵，哪一行 X 240个采样点 X 64头上64个采样点

    
     
% %第二个大大大大循环--------分开P300和非P300
% for epoch=1:size(Signal,1)                                   %epoch
%      labelTAR=unique(StimulusCode(epoch,:).*StimulusType(epoch,:)); %去重复，去不desired的行列，【0，row，col】,获取每个周期的行列数
%      chorespT(epoch,1:2,:,:)=[responses(epoch,labelTAR(2),:,:);avgresp(epoch,labelTAR(3),:,:)];%获取P300反应
% %      RowcolB(epoch,1)=labelTAR(2);
% %      RowcolB(epoch,2)=labelTAR(3);
% %      labelB(epoch,1,:)=label(epoch,labelTAR(2),:);
% %      labelB(epoch,2,:)=label(epoch,labelTAR(3),:);  
%      Fcnt=0;
%      for o=1:size(avgresp,2)
%          if o~=labelTAR(2)||o~=labelTAR(3)
%              Fcnt=Fcnt+1;
%              chorespNT(epoch,Fcnt,:,:)=avgresp(epoch,o,:,:);%获取非P300反应
% %              RowcolB(epoch,Fcnt)=o;
% %              labelB(epoch,Fcnt,:)=label(epoch,o,:);
%          end
%      end 
%      
%      fprintf(1, 'INFO:Processing data OK,%d /85 \n\n',epoch );
% end


    
      DP=extract(chorespT);
      DN=extract(chorespNT);

      
     [~,idx] = fcs(DP,DN);                               
     DPnew = reduction(DP,idx,feature_dim);
     DNnew = reduction(DN,idx,feature_dim);%哪一行 X 240个采样点 X 64头上64个采样点