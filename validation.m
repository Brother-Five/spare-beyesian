function predict_rate=validation(X,t,alpha)
    [responses_train,label_train,responses_test,label_test]=split_dataset(alpha,X,t);
    w=SBDA(responses_train,label_train);
    t=responses_test*w;
    
    if t>=0.5
        t=1;
    else
        t=0;
    end
    
    count_right=0;
    true_right=0;
    predict_true_right=0;
    for i=1:size(t)
        if label_test(i)
            true_right=true_right+1;
        end
        if t(i)==label_test(i)
            count_right=count_right+1;
            if t(i)==1
                predict_true_right=predict_true_right+1;
            end
        end
    end
    predict_rate=count_right/size(t,1);
    fprintf(1, 'INFO:VALIDATION ACCURACIES is %.3f \n\n',predict_rate);
    fprintf(1, 'INFO:TRUE POSTIVE ACCURACIES is %.3f \n\n',predict_true_right/true_right);
end