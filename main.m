%% REAL-TIME MONITORING AND EARLY WARNING OF ATRIAL FIBRILLATION
% 
% This script generates the data for training and testing
% 
% Marino Gavidia,. et al.

addpath("lib/") % Add functions to path 


%% Parameters
rp=0; % Show RP 0=No, 1=Yes;
tw=30; % window's size
dim=224; % image's dimension
fs=128; % Sampling frequency
delay= 2; % Time delay
dE=3; % Tmbedding dimension
dis_tresh=0.7; % Threshold of coefficient of variation 

%% Input folder
inputf="samples/";

%% Output folder
outputf="rp_data/";
mkdir(outputf);

%% Load Samples
Samples =readtable(inputf+ "LABELS.csv","NumHeaderLines",1 );

%% Generate data for training/testing
gen_dat( tw, dim, fs, delay,dE, dis_tresh,inputf, outputf,Samples,rp);






