%{
�����Ԥ����ͳ��ȥ����
ϵ����0.1��0.9���Ե���
%}
function RR = windsorize(R)
    [no,window,ch]=size(R);
    D = zeros(no*window,ch);
    RR=zeros(no,window,ch);
    %ͬ���缫�����ݵ�����
    for i =1:64
        for j=1:size(R,1)
            D((j-1)*window+1:j*window,i)= R(j,:,i);
        end
    end
    %ͳ��ȥ����
    flag1=0.1*no*window;
    flag2=0.9*no*window;
    flag1val=zeros(64);
    flag2val=zeros(64);
    [~, idx] = sort(D,'descend'); 
     %���ǰ10%��ǰ90%����ֵ��С
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
       %����ǰ10%��ǰ90%������
       for jjj=1:no*window
          if idx(jjj,iii)>=flag2
              D(jjj,iii)=flag2val(iii);
          else if idx(jjj,iii)<=flag1;
                  D(jjj,iii)=flag1val(iii);
              end
          end
       end
    end
    
    %���缫���ӵ�����
    for iiii =1:64
        for jjjj=1:size(R,1)
            RR(jjjj,:,iiii)=D((jjjj-1)*window+1:jjjj*window,iiii);
        end
    end
    
    
end
