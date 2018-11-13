function [score_label,TP]=AneswerRankking(predict_label1,predict_label2,predict_label3,predict_label4,predict_label5,label_test1)
     cnt1=0;
     cnt2=0;
     score_label=zeros(size(predict_label1));
    for nn=1:size(predict_label1)
        %score_label(nn)=predict_label1(nn)+predict_label2(nn)+predict_label3(nn)+predict_label4(nn)+predict_label5(nn); 
        if predict_label1(nn)+predict_label2(nn)+predict_label3(nn)+predict_label4(nn)+predict_label5(nn)>=2.5
            score_label(nn)=1;
            cnt1=cnt1+1;
            if label_test1(nn)==1
                cnt2=cnt2+1;
            end
        end
    end
    TP=(cnt2/cnt1)*100;
end