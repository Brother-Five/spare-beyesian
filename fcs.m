function idx = fcs(xp,xn)
    miup = mean(xp,1);
    miun = mean(xn,1);
    sp = var(xp,0,1);
    sn = var(xn,0,1);
    fcsM = (miup - miun).^2./(sp + sn);
    fcsV = fcsM(:);
    [Fcs_sorted, idx] = sort(fcsV,'descend');
    
    
    f2 = figure;
    hold on; grid on;
    plot(Fcs_sorted*2304,'r-','LineWidth',1);
    %axis([1 size(xp,2) 0 100]);
    xlabel('Feature sorted by FCS');
    ylabel('Fisher Criterion Score');
    title('Fcs Value');
end