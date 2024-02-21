function [ RRI_ALL ] = get_RRI(data,fs,tw)


ini=1;
flag=1;
ecg_w=data(end-(tw*fs):end );
data_l=length(data);
while(flag)
    [~,qrs_i_raw,~]=pan_tom(double(ecg_w),fs,0);
    RRI=[];
    for ii=1:length(qrs_i_raw)-1
        RRI=[RRI (qrs_i_raw(ii+1)-qrs_i_raw(ii))/fs ];
    end
    RRI_ALL{ini}=RRI;
    ini=ini+1;
    end_seg=data_l-( (tw*fs)+(ini*fs*5) );
    ini_seg=data_l-          (ini*fs*5);
    if ( end_seg<=1 )
        flag=0;
    else
        ecg_w=data(end-ini_seg:end-end_seg );
    end
end
end
