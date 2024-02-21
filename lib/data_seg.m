function [SEGMENTATION] = data_seg(DATA,LABELS,dis_tresh,tw,n_file )

N=length(DATA);
%% Sampling frequency
fs=LABELS{n_file,2};
m=fs*60;
%% RR mean
RR_T=get_RRI(DATA,fs,tw);
mean_rri=trimmean(horzcat(RR_T{:}),5);
%% Data Segmentation
SEGMENTATION=[];
SR_ini=1;

for tt=3:width(LABELS)
    try
        AF=split(LABELS{n_file,tt}{:},'-');
        AF_ini=str2double(AF{1})*m;
        PreAF= find_preaf(DATA(SR_ini:AF_ini),AF_ini ,fs,dis_tresh,tw,mean_rri) ;
        AF_end=str2double(AF{2})*m;

        SEGMENTATION=[SEGMENTATION; ones(length(SR_ini:PreAF),1)    *0]; %SR
        SEGMENTATION=[SEGMENTATION; ones(length(PreAF+1:AF_ini),1)  *1]; %PREAF
        SEGMENTATION=[SEGMENTATION; ones(length(AF_ini+1:AF_end),1) *2]; %AF

    catch
        SR_ini=AF_end;
        SR_end=N;
        SEGMENTATION=[SEGMENTATION; ones(length(SR_ini+1:SR_end),1)*0]; %SR
        break
    end
end
end