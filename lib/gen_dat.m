function [] = gen_dat( tw, dim, fs, delay,dE, dis_tresh,inputf, outputf,SAMPLES,rp)

for l= 1:height(SAMPLES)
    disp(SAMPLES{l,1}{1})
    [~,n_file]=fileparts(SAMPLES{l,1});
    %% Create HDF5 file  
    file=strcat( outputf,'/',num2str(n_file) ,'.hdf5');
    h5create(file,'/x', [ dim dim Inf ],'Datatype','uint8','ChunkSize', [ dim dim 1]);
    h5create(file,'/y', [3 Inf ],'Datatype','double','ChunkSize', [3 1]);

    %% Read data
    DATA= load(inputf+SAMPLES{l,1});
    DATA=DATA(:,1);

    %% Data segmentation
    SEGMENTATION=data_seg(DATA,SAMPLES,dis_tresh,tw,l );

    %% RP Generation
    gen_rp(DATA,SEGMENTATION,file,tw,fs,[dim dim],delay,dE,rp);

end

end
