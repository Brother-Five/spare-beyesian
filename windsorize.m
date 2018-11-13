%{
第五个预处理：统计去极化
系数：0.1和0.9可以调节
%}
function RR = windsorize(R)
    [no,window,ch]=size(R);
    D = zeros(no*window,ch);
    RR=zeros(no,window,ch);
    %同个电极的数据叠起来
    for i =1:64
        for j=1:size(R,1)
            D((j-1)*window+1:j*window,i)= R(j,:,i);
        end
    end
    %统计去极化
    flag1=0.1*no*window;
    flag2=0.9*no*window;
    flag1val=zeros(64);
    flag2val=zeros(64);
    [~, idx] = sort(D,'descend'); 
     %获得前10%和前90%的阈值大小
    for ii=1:64
       for jj=1:no*window
          if idx(jj,ii)==flag1
              flag1val(ii)=D(jj,ii);
          else if idx(jj,ii)==flag2
              flag2val(ii)=D(jj,ii);
              end
          end
       end
    end
    
    for iii=1:64
       %更换前10%和前90%的数据
       for jjj=1:no*window
          if idx(jjj,iii)>=flag2
              D(jjj,iii)=flag2val(iii);
          else if idx(jjj,iii)<=flag1;
                  D(jjj,iii)=flag1val(iii);
              end
          end
       end
    end
    
    %拆解电极叠加的数据
    for iiii =1:64
        for jjjj=1:size(R,1)
            RR(jjjj,:,iiii)=D((jjjj-1)*window+1:jjjj*window,iiii);
        end
    end
    
    
end
