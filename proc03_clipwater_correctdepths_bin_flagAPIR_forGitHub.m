%% Proc 03 - 
%   Dr. Emily Eidam, emily.eidam@oregonstate.edu
%   November 2023
%   Code available https://github.com/emilyeidam/icesat-2_kdph under license
%   GNU GPLv3

%   This code creates a "level 3" file which contains all of the information 
%   necessary to calculate Kd. This code is optimized to allow for sensitivty 
%   tests/tuning of different parameters like bin size and beam pairing.

%   PART 1 INCLDUES USER-SELECTED PROCESSING PARAMETERS

% Processing steps include:

%   - Define x, z bin sizes
%   - Clip the point clouds according to the water boundaries defined in the 
%       level 2 product
%   - Build temporary histograms
%   - Use temporary histograms to define surface peak
%   - Adjust depths to depth below surface peak
%   - Correct depths using refraction correction (from Parrish)
%   - Remove surface peak (choose cutoff value - or later, use other scheme)

%   - Create a new structure with just the essential variables (to reduce
%       file size)
%   - Create a new version of each of the 6 point clouds that omits the
%       AR/IR flagged photons (from the quality_ph variable)
%   - Create a paired version of the point clouds - both with and without
%       the AR/IR removal

%% Notes
% Presently this is established for a single file. You can wrap this inside
% a loop in a new script if you want to loop through multiple level 2
% files.

%% Part 0 - load file
clear all; close all; clc
folder='SET_FOLDER_DIRECTORY'; % USER INPUT

cd(folder)
load(strcat(folder,'/atl03_level2_file01.mat'));

%% Part 1, 1) Define x, z bin sizes

% x spacing in kilometers for subsetting
binx=0.5; 
% binx=1.0;
% binx=2.0;
% binx=25;

% z spacing for vertical histogram
% binz=0.05;
% binz=0.1;
binz=0.25; 
% binz=1;
% binz=2;

% depth to remove from surface below surface peak; MUST BE A MULTIPLE OF BINZ
% spz=0.5; 
spz=1.0; 
% spz=5.0;

% flag for removing aftperulsing/impulse response (and TEP) or not
removeAPIR=1; % 1 for yes, 0 for no
remove_solarbackground = 0; % 1 for yes, 0 for no; WARNING - not applied to paired beam data

%% Part 1, 2) Clip the point clouds according to the water boundaries defined in the level 2 product

% Xuse & Xsubset - index by 6 beams (value "r")
for r=1:length(atl.beam)
% for r=1:2

    atl.beam(r).xuse=round(atl.beam(r).endpts(:,1));
    atl.beam(r).xsubset=[atl.beam(r).xuse(1):binx:atl.beam(r).xuse(2)];

    % Store bin size/edge/center data
    atl.beam(r).subsetlen_km=binx;
    atl.beam(r).sedges=atl.beam(r).xsubset;
    temp=atl.beam(r).xsubset+binx/2;
    atl.beam(r).sctrs=temp(1:end-1);

    % Subdivide photon data into subset intervals (note that these are not
    % the "clean" variables from an earlier version of code where the AP/IR
    % had already been removed)
    for i=2:length(atl.beam(r).xsubset)
        np=find(atl.beam(r).xdall>atl.beam(r).xsubset(i-1) & atl.beam(r).xdall<=atl.beam(r).xsubset(i));
        xdtemp=atl.beam(r).xdall(np);
        phtemp=atl.beam(r).h(np);
        lattemp=atl.beam(r).lat(np);
        lontemp=atl.beam(r).lon(np);
        qutemp=atl.beam(r).qual(np);

        keepvert=find(phtemp<atl.beam(r).topbot(1,2) & phtemp>atl.beam(r).topbot(2,2));

        atl.beam(r).sub(i-1).qu=qutemp(keepvert);
        atl.beam(r).sub(i-1).hraw=phtemp(keepvert);
        atl.beam(r).sub(i-1).x=xdtemp(keepvert);
        atl.beam(r).sub(i-1).lat=lattemp(keepvert);
        atl.beam(r).sub(i-1).lon=lontemp(keepvert);


        clear np xdtemp phtemp lattemp lontemp keepvert qutemp

    end

end

%% Part 1 - create histograms
    
% Start gathering variables in new, clean structure "phbin"
for r=1:length(atl.beam)
phbin.beam(r).name=atl.beam(r).name;
phbin.beam(r).sedges=atl.beam(r).sedges;
phbin.beam(r).sctrs=atl.beam(r).sctrs;
phbin.beam(r).sub=atl.beam(r).sub;

end

% Create edges and centers for histogram bins (in vertical dimension) -
% these will apply to the horizontally subsetted data, but go ahead and
% make for each bulk trackline
    for r=1:length(phbin.beam)
        phbin.beam(r).binz=binz;
        phbin.beam(r).edgestart=ceil(atl.beam(r).topbot(1,2));
        phbin.beam(r).edgeend=floor(atl.beam(r).topbot(2,2));
        if phbin.beam(r).edgeend<phbin.beam(r).edgestart
            phbin.beam(r).edges=(([phbin.beam(r).edgeend:phbin.beam(r).binz:phbin.beam(r).edgestart]))';
            phbin.beam(r).centers=[phbin.beam(r).edgeend+phbin.beam(r).binz/2:phbin.beam(r).binz:phbin.beam(r).edgestart-phbin.beam(r).binz/2];
        else
            sprintf('check bin edges; deal with sign problem')
        end
    end
 
%%

    for r=1:length(phbin.beam); % Combine data from beam pairs and report in the first row for each pair
        for k=1:length(phbin.beam(r).sub)
            
            % USE FLAG to decide whether to remove AP/IR photons based on
            % quality flag or not
            if removeAPIR==1
                
                    % Quantify how many were flagged as Nominal, AP, IR, TEP
                    temp=find(phbin.beam(r).sub(k).qu==0);
                    phbin.beam(r).sub(k).qu0=length(temp)./length(phbin.beam(r).sub(k).qu); clear temp
                    temp=find(phbin.beam(r).sub(k).qu==1);
                    phbin.beam(r).sub(k).qu1=length(temp)./length(phbin.beam(r).sub(k).qu); clear temp
                    temp=find(phbin.beam(r).sub(k).qu==2);
                    phbin.beam(r).sub(k).qu2=length(temp)./length(phbin.beam(r).sub(k).qu); clear temp
                    temp=find(phbin.beam(r).sub(k).qu==3);
                    phbin.beam(r).sub(k).qu3=length(temp)./length(phbin.beam(r).sub(k).qu); clear temp
                
                    % Then create a "clean" lat, lon, h, and xdall variables that don't
                    % have anything flagged as qual 1, 2, or 3 (AP, IR, or TEP)
                
                    clear use; use=find(phbin.beam(r).sub(k).qu==0);
                    
                    phbin.beam(r).sub(k).hraw=phbin.beam(r).sub(k).hraw(use);
                    phbin.beam(r).sub(k).x=phbin.beam(r).sub(k).x(use);
                    phbin.beam(r).sub(k).lat=phbin.beam(r).sub(k).lat(use);
                    phbin.beam(r).sub(k).lon=phbin.beam(r).sub(k).lon(use);
                
                    phbin.beam(r).sub(k).pctomitted=100-100*(length(phbin.beam(r).sub(k).lat)./length(phbin.beam(r).sub(k).qu));
                    phbin.apir_removed=removeAPIR;
            else
            end
            

            % FIRST compute histogram using uncorrected photon elevations -
            % because the elevation of the surface peak is needed in order
            % to determine the water depth.
            [nhistraw,~]=histcounts(phbin.beam(r).sub(k).hraw,phbin.beam(r).edges);
            phbin.beam(r).sub(k).histctsraw=nhistraw;
            phbin.beam(r).sub(k).edges=phbin.beam(r).edges;
            phbin.beam(r).sub(k).centers=phbin.beam(r).centers;
            clear nhist
            phbin.beam(r).sub(k).surfz=phbin.beam(r).sub(k).centers(find(phbin.beam(r).sub(k).histctsraw==max(phbin.beam(r).sub(k).histctsraw,[],"omitnan")));
            % Add qualifier - if the length of surfz is more than one (if
            % it is a wide peak), choose the value that is deeper in the
            % water column
            phbin.beam(r).sub(k).surfz=min(phbin.beam(r).sub(k).surfz,[],"omitnan");

            % SECOND - re-compute the h values for *everything below the
            % surface* and then re-compute the histogram. It's not entirely
            % clean to me whether the entire surface bin should be excluded
            % from this operation. The surface elevation may change
            % slightly once the subsurface photon elevations are corrected
            % (so another source of garbage data very close to the surface
            % - corrected and uncorrected photons ending up in the same bin
            % that was originally calculated from just the corrected
            % photons. (8/23)
            water=find(phbin.beam(r).sub(k).hraw<phbin.beam(r).sub(k).surfz); % index of points in water
            air=find(phbin.beam(r).sub(k).hraw>=phbin.beam(r).sub(k).surfz); % index of points in air
            phbin.beam(r).sub(k).phdepth=phbin.beam(r).sub(k).surfz-phbin.beam(r).sub(k).hraw;
            phbin.beam(r).sub(k).hz=phbin.beam(r).sub(k).hraw+0.25416*phbin.beam(r).sub(k).phdepth; % Parrish correction
            phbin.beam(r).sub(k).phdepth(air)=NaN;
            phbin.beam(r).sub(k).hz(air)=NaN;

            % Note that hz and phdepth are effectively the same - but hz is
            % corrected elevation relative to geoid, and phdepth is the
            % depth below the water surface
        
            [nhistclean,~]=histcounts(phbin.beam(r).sub(k).hz,phbin.beam(r).edges);
            phbin.beam(r).sub(k).histctsclean=nhistclean;

            % If solarbackground flag is on, calculate solar background per
            % unit x, z that were specific and subtract it from the
            % histogram bins
            if remove_solarbackground==1
            % for s=1:length(atm);
                temp1=atm(r).phcts./atm(r).xdist_km; % rate per km horizontally
                temp2=temp1*binx; % rate per half kilometer
                temp3=temp2/atm(r).zdist_m; % rate per vertical meter
                temp4=temp3*binz; % rate per quarter vertical meter
                atm(r).rate=temp4;
            phbin.beam(r).sub(k).histctsclean=nhistclean-round(atm(r).rate);
            neg=find(phbin.beam(r).sub(k).histctsclean<0);
            phbin.beam(r).sub(k).histctsclean(neg)=0;
            else;
            end

            % Isolate the data that are below the surface peak
            peakz=[phbin.beam(r).sub(k).surfz-spz];
            isubsurf=find(phbin.beam(r).sub(k).edges<peakz);
            phbin.beam(r).sub(k).isubsurf=isubsurf(2:end);
            phbin.beam(r).sub(k).ctrs_subsurf=phbin.beam(r).sub(k).centers(phbin.beam(r).sub(k).isubsurf);
            phbin.beam(r).sub(k).hisctsclean_subsurf=phbin.beam(r).sub(k).histctsclean(phbin.beam(r).sub(k).isubsurf);
            clear peakz isubsurf

            phbin.beam(r).sub(k).hstctsmax=max(nhistclean,[],"omitnan");
            phbin.beam(r).sub(k).ctsnorm=phbin.beam(r).sub(k).hisctsclean_subsurf./phbin.beam(r).sub(k).hstctsmax;
            
        end
    end


%% Part 2 - Create a paired version of the point clouds 
%    Will include/exclude AP/IR just as non-paired version does (according
%    to the flag)

for i=1:3
% for i=1
    p1=2*i-1;
    p2=2*i;
    phbin.beampair(i).name=strcat('gt',num2str(i));
    phbin.beampair(i).sedges=phbin.beam(p1).sedges;
    phbin.beampair(i).sctrs=phbin.beam(p1).sctrs;
    phbin.beampair(i).binz=phbin.beam(p1).binz;
    phbin.beampair(i).edges=phbin.beam(p1).edges;
    phbin.beampair(i).centers=phbin.beam(p1).centers;
    
    for k=1:length(phbin.beam(p1).sub)

    % Combine raw data from pairs of beam
    phbin.beampair(i).sub(k).qu=[atl.beam(p1).sub(k).qu;atl.beam(p2).sub(k).qu];
    phbin.beampair(i).sub(k).hraw=[atl.beam(p1).sub(k).hraw;atl.beam(p2).sub(k).hraw];
    phbin.beampair(i).sub(k).x=[atl.beam(p1).sub(k).x';atl.beam(p2).sub(k).x'];
    phbin.beampair(i).sub(k).lat=[atl.beam(p1).sub(k).lat;atl.beam(p2).sub(k).lat];
    phbin.beampair(i).sub(k).lon=[atl.beam(p1).sub(k).lon;atl.beam(p2).sub(k).lon];

    % Need to add the decision here about removing AP/IR

            % PRELIM - remove APIR if flag is 1
            if removeAPIR==1                
                    % Quantify how many were flagged as Nominal, AP, IR, TEP
                    temp=find(phbin.beampair(i).sub(k).qu==0); phbin.beampair(i).sub(k).qu0=length(temp)./length(phbin.beampair(i).sub(k).qu); clear temp
                    temp=find(phbin.beampair(i).sub(k).qu==1); phbin.beampair(i).sub(k).qu1=length(temp)./length(phbin.beampair(i).sub(k).qu); clear temp
                    temp=find(phbin.beampair(i).sub(k).qu==2); phbin.beampair(i).sub(k).qu2=length(temp)./length(phbin.beampair(i).sub(k).qu); clear temp
                    temp=find(phbin.beampair(i).sub(k).qu==3); phbin.beampair(i).sub(k).qu3=length(temp)./length(phbin.beampair(i).sub(k).qu); clear temp
                    % Then create a "clean" lat, lon, h, and xdall variables that don't have anything flagged as qual 1, 2, or 3 (AP, IR, or TEP)
                    clear use; use=find(phbin.beampair(i).sub(k).qu==0);
                    
                    phbin.beampair(i).sub(k).hraw=phbin.beampair(i).sub(k).hraw(use);
                    phbin.beampair(i).sub(k).x=phbin.beampair(i).sub(k).x(use);
                    phbin.beampair(i).sub(k).lat=phbin.beampair(i).sub(k).lat(use);
                    phbin.beampair(i).sub(k).lon=phbin.beampair(i).sub(k).lon(use);
                
                    phbin.beampair(i).sub(k).pctomitted=100-100*(length(phbin.beampair(i).sub(k).lat)./length(phbin.beampair(i).sub(k).qu));
                    phbin.beampair(i).apir_removed=removeAPIR;
            else
            end
            
            % FIRST compute histogram using uncorrected photon elevations -
            % because the elevation of the surface peak is needed in order
            % to determine the water depth.
            [nhistraw,~]=histcounts(phbin.beampair(i).sub(k).hraw,phbin.beampair(i).edges);
            phbin.beampair(i).sub(k).histctsraw=nhistraw;
            phbin.beampair(i).sub(k).edges=phbin.beampair(i).edges;
            phbin.beampair(i).sub(k).centers=phbin.beampair(i).centers;
            clear nhist
            phbin.beampair(i).sub(k).surfz=phbin.beampair(i).sub(k).centers(find(phbin.beampair(i).sub(k).histctsraw==max(phbin.beampair(i).sub(k).histctsraw,[],"omitnan")));
            % Add qualifier - if the length of surfz is more than one (if it is a wide peak), choose the value that is deeper in the water column
            phbin.beampair(i).sub(k).surfz=min(phbin.beampair(i).sub(k).surfz,[],"omitnan");

            % SECOND - re-compute the h values for *everything below the
            % surface* and then re-compute the histogram.
            water=find(phbin.beampair(i).sub(k).hraw<phbin.beampair(i).sub(k).surfz); % index of points in water
            air=find(phbin.beampair(i).sub(k).hraw>=phbin.beampair(i).sub(k).surfz); % index of points in air
            phbin.beampair(i).sub(k).phdepth=phbin.beampair(i).sub(k).surfz-phbin.beampair(i).sub(k).hraw;
            phbin.beampair(i).sub(k).hz=phbin.beampair(i).sub(k).hraw+0.25416*phbin.beampair(i).sub(k).phdepth; % Parrish correction
            phbin.beampair(i).sub(k).phdepth(air)=NaN;
            phbin.beampair(i).sub(k).hz(air)=NaN;

            % Note that hz and phdepth are effectively the same - but hz is
            % corrected elevation relative to geoid, and phdepth is the
            % depth below the water surface
        
            [nhistclean,~]=histcounts(phbin.beampair(i).sub(k).hz,phbin.beampair(i).edges);
            phbin.beampair(i).sub(k).histctsclean=nhistclean;

            % Isolate the data that are below the surface peak
            peakz=[phbin.beampair(i).sub(k).surfz-spz];
            isubsurf=find(phbin.beampair(i).sub(k).edges<peakz);
            phbin.beampair(i).sub(k).isubsurf=isubsurf(2:end);
            phbin.beampair(i).sub(k).ctrs_subsurf=phbin.beampair(i).sub(k).centers(phbin.beampair(i).sub(k).isubsurf);
            phbin.beampair(i).sub(k).hisctsclean_subsurf=phbin.beampair(i).sub(k).histctsclean(phbin.beampair(i).sub(k).isubsurf);
            clear peakz isubsurf

            phbin.beampair(i).sub(k).hstctsmax=max(nhistclean,[],"omitnan");
            phbin.beampair(i).sub(k).ctsnorm=phbin.beampair(i).sub(k).hisctsclean_subsurf./phbin.beampair(i).sub(k).hstctsmax;
            

    end

end


 %% Save
 save('atl03_level3_file01','phbin','atm','removeAPIR','remove_solarbackground','binx','binz','spz')




