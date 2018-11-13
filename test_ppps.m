%cd:
%Y:\Graduation Project\test_2
clc
clear all

load('Subject_A_Train.mat');
%% parameters
windows      = 200;      % window after stimulus, the sampling rate is 240Hz,resample to 32Hz
feature_dim =500;        %����ά��

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
��ȡresponses
responses(epoch,rowcol,rowcolcnt(rowcol),time����ȡ���ڴ�С,channel)
%}
for epoch=1:size(Signal,1)                                   %epoch
    
    %������
%     Flashing_1(epoch,:)=downsample(Flashing(epoch,:),4);
%     StimulusCode_1(epoch,:)=downsample(StimulusCode(epoch,:),4);
%     StimulusType_1(epoch,:)=downsample(StimulusType(epoch,:),4);  
    fprintf(1, 'INFO:Downsample ... \n\n' );
    
    
    
    
    
    for channel=1:64
        
        %��һ��Ԥ�����ο���λ,��T7��T8Ϊ�ο���λ������41��42
        if (channel~=41)&(channel~=42)
          Signal(epoch,:,channel)=Signal_filtered(epoch,:,channel)-0.5*Signal_filtered(epoch,:,41)-0.5*Signal_filtered(epoch,:,42);
        end
        
    end

    
%       rowcolcnt=ones(1,12);%����һ��ȫһ�������������������г��ֵĴ������ѷ�����
    for n=2:size(Signal,2)  %������
        if Flashing(epoch,n)==0 && Flashing(epoch,n-1)==1 %�ַ�Ϩ���ʱ��
            count_1=count_1+1;
            %rowcol=StimulusCode(epoch,n-1);                                  %12������һ��
            responses_0(count_1,:,:)=Signal(epoch,n-24:n-25+windows,:);   %��ȡ�������ڵĲ�����ӣ�n-24+120����ʼ��window��
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
                chorespNT(count_3,:,:)=responses_1(count_1,:,:);%��ȡ��P300��Ӧ
                
            end
            %rowcolcnt(rowcol)=rowcolcnt(rowcol)+1;                                                                                 %12�еĳ��ִ���count
           
        end
    end   
    
    fprintf(1, 'INFO:first step to data OK,%d /85 \n\n',epoch );    
end

% %�ڰ˸�Ԥ�����Լ��ӵ�Ԥ����ƽ����15�ظ���ʵ��
%     avgresp=mean(responses,3);                          %��responses��һ��window�����������һ��ƽ��,��15�β���ƽ��
%     avgresp=squeeze(avgresp);                           %�ض���avgrespΪ��12   X   window   X   64���ľ�����һ�� X 240�������� X 64ͷ��64��������

    
     
% %�ڶ��������ѭ��--------�ֿ�P300�ͷ�P300
% for epoch=1:size(Signal,1)                                   %epoch
%      labelTAR=unique(StimulusCode(epoch,:).*StimulusType(epoch,:)); %ȥ�ظ���ȥ��desired�����У���0��row��col��,��ȡÿ�����ڵ�������
%      chorespT(epoch,1:2,:,:)=[responses(epoch,labelTAR(2),:,:);avgresp(epoch,labelTAR(3),:,:)];%��ȡP300��Ӧ
% %      RowcolB(epoch,1)=labelTAR(2);
% %      RowcolB(epoch,2)=labelTAR(3);
% %      labelB(epoch,1,:)=label(epoch,labelTAR(2),:);
% %      labelB(epoch,2,:)=label(epoch,labelTAR(3),:);  
%      Fcnt=0;
%      for o=1:size(avgresp,2)
%          if o~=labelTAR(2)||o~=labelTAR(3)
%              Fcnt=Fcnt+1;
%              chorespNT(epoch,Fcnt,:,:)=avgresp(epoch,o,:,:);%��ȡ��P300��Ӧ
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
     DNnew = reduction(DN,idx,feature_dim);%��һ�� X 240�������� X 64ͷ��64��������