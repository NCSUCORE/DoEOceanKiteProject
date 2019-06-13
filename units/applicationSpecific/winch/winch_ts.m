% Script to test the origional model against the modularized model
clear all;clc;

OCTModel_init

modularPlant_init;

sim('winch_th')