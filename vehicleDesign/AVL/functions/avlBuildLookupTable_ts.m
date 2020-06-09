
clear;close all;clc

load('dsgn1Results.mat')
saveFile = 'design1LookupTables.mat';
tic

avlBuildLookupTable(saveFile,results)

toc