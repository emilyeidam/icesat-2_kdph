%% Proc 02 - create boundaries for subsets of point clouds (nominally select water). 
%   Dr. Emily Eidam, emily.eidam@oregonstate.edu
%   November 2023
%   Code available https://github.com/emilyeidam/icesat-2_kdph under license
%   GNU GPLv3

%   This code creates a "level 2" file which is just rectangular subsets of 
%   the photon clouds (no land, no seabed, very little sky). This code also
%   allows you to select a representative section of sky for atmospheric
%   background correction (make sure to only select regions where photons
%   are present) - but you may wish to use the built-in solar background
%   rate variable within the ATL03 data structure instead.

%% Load atl03_level1 file(s)
clear all; close all; clc
home='SET_DIRECTORY'; % USER INPUT
cd(home)

load('atl03_level1_file01.mat'); % NOT adapted for multiple files at present, but the "n" parameter allows this to be adapted for use in a for loop to handle multiple files

%% Plot photon cloud and select water region of interest

d=dir('atl*.mat')
load(d.name,'atl')

n=1
% Do for each of the 3 beam pairs (combine data from each pair)
fig1=figure(1)
set(fig1,'position',[0 100 650 650],'color','w')

subplot(311); hold on
plot(atl(n).beam(1).xdall,atl(n).beam(1).h,'k.','markersize',1)
plot(atl(n).beam(2).xdall,atl(n).beam(2).h,'b.','markersize',1)
xlabel('distance from start of track (km)')
ylabel('ht above WGS84 geoid (m)')

sprintf('zoom in if desired')
pause

% Select endpoints to use for analysis
sprintf('pick start and end points (x values) of transect of interest within the water column')
atl(n).beam(1).endpts=ginput(2);
sprintf('pick top and bottom of region of interest - the first y value should be just above the water surface and the second y value should be at the lowest water depth of interest')
atl(n).beam(1).topbot=ginput(2);
atl(n).beam(2).endpts=atl(n).beam(1).endpts;
atl(n).beam(2).topbot=atl(n).beam(1).topbot;

subplot(312); hold on
plot(atl(n).beam(3).xdall,atl(n).beam(3).h,'k.','markersize',1)
plot(atl(n).beam(4).xdall,atl(n).beam(4).h,'b.','markersize',1)
xlabel('distance from start of track (km)')
ylabel('ht above WGS84 geoid (m)')

sprintf('zoom in if desired')
pause

% Select endpoints to use for analysis

sprintf('pick start and end points (x values) of transect of interest within the water column')
atl(n).beam(3).endpts=ginput(2);
sprintf('pick top and bottom of region of interest - the first y value should be just above the water surface and the second y value should be at the lowest water depth of interest')
atl(n).beam(3).topbot=ginput(2);
atl(n).beam(4).endpts=atl(n).beam(3).endpts;
atl(n).beam(4).topbot=atl(n).beam(3).topbot;

subplot(313); hold on
plot(atl(n).beam(5).xdall,atl(n).beam(5).h,'k.','markersize',1)
plot(atl(n).beam(6).xdall,atl(n).beam(6).h,'b.','markersize',1)
xlabel('distance from start of track (km)')
ylabel('ht above WGS84 geoid (m)')

sprintf('zoom in if desired')
pause

%     Select endpoints to use for analysis
sprintf('pick start and end points (x values) of transect of interest within the water column')
atl(n).beam(5).endpts=ginput(2);
sprintf('pick top and bottom of region of interest - the first y value should be just above the water surface and the second y value should be at the lowest water depth of interest')
atl(n).beam(5).topbot=ginput(2);
atl(n).beam(6).endpts=atl(n).beam(5).endpts;
atl(n).beam(6).topbot=atl(n).beam(5).topbot;


 %% Solar background - select atmosphere and save for binning later to match in-water bins

 n=1
 for i=1:6
 atm(i).endpts=[];
 end

    % Do for each of the 3 beam pairs (combine data from each pair)
    fig2=figure(2)
    set(fig2,'position',[0 100 650 650],'color','w')
    
    subplot(311); hold on
    plot(atl(n).beam(1).xdall,atl(n).beam(1).h,'k.','markersize',1)
    plot(atl(n).beam(2).xdall,atl(n).beam(2).h,'b.','markersize',1)
    xlabel('distance from start of track (km)')
    ylabel('ht above WGS84 geoid (m)')
    
    sprintf('zoom in if desired')
    pause
    
    
    % Select endpoints to use for analysis
        sprintf('pick start and end points of transect of interest; first x value should be at left end of atmospheric section of interest; second x value should be at right end of atmospheric section of interest')
        atm(1).endpts=ginput(2);
        sprintf('pick top and bottom of region of interest (first y-value is at top of atmospheric photons, and second y-value is just above water surface)')
        atm(1).topbot=ginput(2);
        atm(2).endpts=atm(1).endpts;
        atm(2).topbot=atm(1).topbot;
    
    subplot(312); hold on
    plot(atl(n).beam(3).xdall,atl(n).beam(3).h,'k.','markersize',1)
    plot(atl(n).beam(4).xdall,atl(n).beam(4).h,'b.','markersize',1)
    xlabel('distance from start of track (km)')
    ylabel('ht above WGS84 geoid (m)')

    sprintf('zoom in if desired')
    pause

    % Select endpoints to use for analysis
        sprintf('pick start and end points of transect of interest; first x value should be at left end of atmospheric section of interest; second x value should be at right end of atmospheric section of interest')
        atm(3).endpts=ginput(2);
        sprintf('pick top and bottom of region of interest (first y-value is at top of atmospheric photons, and second y-value is just above water surface)')
        atm(3).topbot=ginput(2);
        atm(4).endpts=atm(3).endpts;
        atm(4).topbot=atm(3).topbot;
%     else
%     end

    subplot(313); hold on
    plot(atl(n).beam(5).xdall,atl(n).beam(5).h,'k.','markersize',1)
    plot(atl(n).beam(6).xdall,atl(n).beam(6).h,'b.','markersize',1)
    xlabel('distance from start of track (km)')
    ylabel('ht above WGS84 geoid (m)')

    sprintf('zoom in if desired')
    pause

%     Select endpoints to use for analysis
        sprintf('pick start and end points of transect of interest; first x value should be at left end of atmospheric section of interest; second x value should be at right end of atmospheric section of interest')
        atm(5).endpts=ginput(2);
        sprintf('pick top and bottom of region of interest (first y-value is at top of atmospheric photons, and second y-value is just above water surface)')
        atm(5).topbot=ginput(2);
        atm(6).endpts=atm(5).endpts;
        atm(6).topbot=atm(5).topbot;

for i=1:6
    atm(i).xdist_km=max(atm(i).endpts(:,1))-min(atm(i).endpts(:,1));
    atm(i).zdist_m=max(atm(i).topbot(:,2))-min(atm(i).topbot(:,2));
    usex=find(atl.beam(i).xdall<max(atm(i).endpts(:,1)) & ...
        atl.beam(i).xdall>min(atm(i).endpts(:,1)));
    usez=find(atl.beam(i).h<max(atm(i).topbot(:,2)) & ...
        atl.beam(i).h>min(atm(i).topbot(:,2)));
    c=intersect(usex,usez);
    atm(i).phcts=length(atl.beam(i).h(c));
end



 %% Save
 save('atl03_level2_file01','atl','atm')


