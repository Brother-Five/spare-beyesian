%cd:
%Y:\Graduation Project\test_2
% clc
% clear all
% 
% StimulusType=[];


% load 'model_1.mat' 
% load the svm model

%% parameters
windows     = 200;      % window after stimulus, the sampling rate is 240Hz,resample to 32Hz
feature_dim = 200;        %ÌØÕ÷Î¬Êý
     

%% *************************  pre-processing  *************************%%
[D,L,idx]=PPPS('Subject_A_Train.mat',windows,feature_dim);
%load('20180424.mat');

[Dtest,code_test]=testppps('Subject_A_Test.mat',windows,feature_dim,idx);


% alpha=0.6;
% predict_rate_1=validation(D,L,alpha);
% predict_rate_2=validation(D2,L,alpha);
% predict_rate_3=validation(D3,L,alpha);
% predict_rate_4=validation(D4,L,alpha);
% predict_rate_5=validation(D5,L,alpha);
%% recogniting
predict_rate=test_2(D,L,idx,Dtest,code_test);
