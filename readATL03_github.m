function atl=readATL03_paper_noproc(path);        

%   Dr. Emily Eidam, emily.eidam@oregonstate.edu
%   November 2023
%   With code contributions by Matthew Paris, 2022 (UNC)
%   Code available https://github.com/emilyeidam/icesat-2_kdph under license
%   GNU GPLv3

%   This code extracts variables of interest from ICESat-2 version 003
%   ATL03 .h5 files which are available through the NASA EarthData explorer.

%%
% Path can refer to a single folder, or a group of folders that each
% contain an .h5 file (e.g., files downloaded from OpenAltimetry or icepyx)

% Read ATL03 files from icepyx-downloaded HDF5 files
addpath(path)
savepath
rootdir = path;
d=dir(fullfile(rootdir,'*.h5'));

% Identify beam names from the meta data ATL03 (lines 4-9 in groups) (EFE 220427)
filemeta=h5info(d(1).name);
for j=1:length(filemeta.Groups)
    groupnames{j,:}=filemeta.Groups(j).Name;
end
clear j
for j=1:length(groupnames)
    temp(j,1)=erase(groupnames(j),'/');
end
clear j

% Isolate beams from metaATL03 temp file
temp2=startsWith(temp,'gt'); % True/False flag for starts with "gt"
q=find(temp2==1); % Find true
beams=temp(q,:); % Create beams with n values
[r,c]=size(beams);
clear q; clear temp; clear temp2; clear filemeta

% Loop through all directory files
for i=1:length(d)

    ATL03(i).file_id = H5F.open(d(i).name, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

    % Loop through all 6 beams
    for n=1:r

        ATL03(i).beam(n).name=beams(n,:);


        % ATL03 variables
        try
            LATFIELD_NAME=string(strcat(beams(n,:),'/heights/lat_ph'));
            ATL03(i).beam(n).lat_id=H5D.open(ATL03(i).file_id, LATFIELD_NAME);
            LONFIELD_NAME=string(strcat(beams(n,:),'/heights/lon_ph'));
            ATL03(i).beam(n).lon_id=H5D.open(ATL03(i).file_id, LONFIELD_NAME);
            PHFIELD_NAME=string(strcat(beams(n,:),'/heights/h_ph'));
            ATL03(i).beam(n).h_id=H5D.open(ATL03(i).file_id, PHFIELD_NAME);
            QUALFIELD_NAME=string(strcat(beams(n,:),'/heights/quality_ph'));
            ATL03(i).beam(n).qual_id=H5D.open(ATL03(i).file_id, QUALFIELD_NAME);
            SOLAR_NAME=string(strcat(beams(n,:),'/geolocation/solar_elevation'));
            ATL03(i).beam(n).solar_elev_id=H5D.open(ATL03(i).file_id, SOLAR_NAME);
            NR_SAT_FRAC_NAME=string(strcat(beams(n,:),'/geolocation/near_sat_fract'));
            ATL03(i).beam(n).nsf_id=H5D.open(ATL03(i).file_id, NR_SAT_FRAC_NAME);
            FULL_SAT_FRAC=string(strcat(beams(n,:),'/geolocation/full_sat_fract'));
            ATL03(i).beam(n).fsf_id=H5D.open(ATL03(i).file_id, FULL_SAT_FRAC);

            % Read and store ATL03 variables

            ATL03(i).beam(n).lat    =H5D.read(ATL03(i).beam(n).lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL','H5P_DEFAULT');
            ATL03(i).beam(n).lon    =H5D.read(ATL03(i).beam(n).lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL','H5P_DEFAULT');
            ATL03(i).beam(n).h      =H5D.read(ATL03(i).beam(n).h_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL','H5P_DEFAULT');
            ATL03(i).beam(n).qual   =H5D.read(ATL03(i).beam(n).qual_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL','H5P_DEFAULT');
            ATL03(i).beam(n).solarelev  =H5D.read(ATL03(i).beam(n).solar_elev_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL','H5P_DEFAULT');
            ATL03(i).beam(n).nsatf    =H5D.read(ATL03(i).beam(n).nsf_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL','H5P_DEFAULT');
            ATL03(i).beam(n).fsatf    =H5D.read(ATL03(i).beam(n).fsf_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL','H5P_DEFAULT');

            ATL03_filename=extractAfter(d(i).name,'processed_');
            ATL03(i).date=ATL03_filename(7:14);
            S = num2str(ATL03(i).date); % Strings
            ATL03(i).timestart = datetime(S, 'InputFormat','yyyyMMdd', 'Format','yyyy-MM-dd');

        catch
        end
    end
end

% Clear temporary variables
clear *FIELD_NAME; clear *_filename
clear ATTRIBUTE; clear attr_id;
clear c; clear i; clear n; clear r; clear S;
clear rootdir; clear beams; clear groupnames;
clear k; clear temp8; clear temp9; clear PassCallNumber;
clear ATL; clear d;


atl=ATL03;
end

