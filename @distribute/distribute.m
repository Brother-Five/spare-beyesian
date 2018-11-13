function d = distribute(mean,var) 
d.mean=mean; 
d.var=var; 
d.p=(1/d.var*(2*pi)^(1/2))*exp((-(z-mean)^2)/(2*var^2));
d=class(d,'distribute');

end