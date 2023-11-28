%% Read in photon data from raw ATL03 file 
%   Dr. Emily Eidam, emily.eidam@oregonstate.edu
%   November 2023
%   Code available https://github.com/emilyeidam/icesat-2_kdph under license
%   GNU GPLv3

%   This code creates a "level 1" file which is simply a data structure
%   ("atl") which contains relevant variables. You may wish to edit the
%   readATL03_github function so that additional variables are extracted.

clear all; close all; clc
home='SET_WORKING_DIRECTORY' % USER INPUT
addpath(genpath(home));

%% Scan the folder directory

% Set the location of your ATL files. This should be a folder containing
% unzipped folders which start with the number 2. You may want to modify
% this directory code if you have re-organized your h5 folders into a
% structure other than the default produced by the NASA EarthData download
% tool.
filehome='SET_LOCATION'; % USER INPUT


addpath(genpath(filehome));
cd(filehome);

dfolder=dir('2*'); 
for i=1:length(dfolder)
    temp=dir(strcat(dfolder(i).name,'/processed*')); % Depending on how you have downloaded your data, the file names may NOT start with "processed" (beware!)
    dfolder(i).fname=temp;
    clear temp
end

%% for n=1:length(dfolder); % n is num of folders (and h5 files)
for n=1:length(dfolder)

    temp=readATL03_github(dfolder(n).name);

    % For each photon, calculate distance along track from the start of segment
    for r=1:6;
        temp.beam(r).xdall(1)=0;
        for i=2:length(temp.beam(r).h)
            temp.beam(r).xdall(i)=lldistkm([temp.beam(r).lat((1)) temp.beam(r).lon((1))],[temp.beam(r).lat((i)) temp.beam(r).lon((i))]);
        end
    end
    
atl=temp;
cd(strcat(filehome,'/',dfolder(n).name))
    save(strcat('atl03_level1_file0',num2str(n)),'atl','dfolder')

clear temp atl 
cd ../
end


