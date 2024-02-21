function [pre_af_ini] = find_preaf(data,AF_ini,fs,dis_tresh,tw,mean_rri)

m=60*fs;
interval=length(data)-5*m:length(data);
pre_af_ini=0;
flag=1;
count=1;
while flag && interval(1)>1
    x=data(interval);
    RRI=get_RRI(x,fs,tw);
    std_RRI=[];
    for ii=1:length(RRI)
    std_RRI=[ std_RRI std(RRI{ii}) ];
    end
    coef_var=std_RRI/mean_rri;
    if median(coef_var)<=dis_tresh
        flag=0;
        pre_af_ini=AF_ini-count*5*m;
%         disp("PREAF= "+ num2str(count*5) + "min")
    else
       interval=length(data)-(count+1)*5*m:length(data)-count*5*m+30*fs; 
       count=count+1;
    end
end