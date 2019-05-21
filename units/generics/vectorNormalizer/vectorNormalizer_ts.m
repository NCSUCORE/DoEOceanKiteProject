close all;clear;clc

A = [ 4 3 1 1 ];

sim('vectorNormalizer_th')

sqrt(sum(simout.Data.^2))

