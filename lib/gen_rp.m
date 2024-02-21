function [label_1, label_2, label_3] = gen_rp(data,SEGMENTATION,file,tw,fs,img_dim,delay,dE,rp)


label_1=0;
label_2=0;
label_3=0;
ini_seg=1;
interval=ini_seg:(tw*fs);

flag=1;
N=length(data);
RP_backup=int8(zeros(img_dim));
ini=1;

%% Show RP?
if rp
figure(1)
set(groot,'defaultFigureVisible','on')    
else
set(groot,'defaultFigureVisible','off')    
end
%% Generate sliding window
while(flag)
    ecg_w=data(interval);  
    
    try
        [~,qrs_i_raw,~]=pan_tom(double(ecg_w),fs,0);
        RRI=[];
        for ii=1:length(qrs_i_raw)-1
            RRI=[RRI (qrs_i_raw(ii+1)-qrs_i_raw(ii))/fs ];
        end
        imagesc( rp_plot(RRI,delay,dE));
        F = getframe;
        RP=imresize(F.cdata, img_dim);
        RP=rgb2gray(RP);
        RP_backup=RP;   
    catch
        RP=RP_backup;
    end
    RP=uint8(RP);

    info = h5info(file, '/x');
    curSize = info.Dataspace.Size;
    h5write(file,'/x', RP,[ 1 1 curSize(end)+1] , [ img_dim 1]);
    
    if any(SEGMENTATION(interval)==1)
        h5write(file,'/y', [1 ; 0 ; 0],[1 curSize(end)+1] , [3 1]);
    elseif any(SEGMENTATION(interval)==2)
        h5write(file,'/y', [0 ; 1 ; 0],[1 curSize(end)+1] , [3 1]);
    else
        h5write(file,'/y', [0 ; 0 ; 1],[1 curSize(end)+1] , [3 1]);
    end
    ini=ini+1;
    ini_seg=  (ini*fs*15)          ;
    end_seg=  (ini*fs*15) + (tw*fs);
    if ( end_seg>N )
        flag=0;
    else
        interval=(ini_seg:end_seg );
    end        
end
end