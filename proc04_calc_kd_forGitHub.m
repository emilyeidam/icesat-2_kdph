%% Proc 04 - 
%   Dr. Emily Eidam, emily.eidam@oregonstate.edu
%   November 2023
%   Code available https://github.com/emilyeidam/icesat-2_kdph under license
%   GNU GPLv3

%   This code creates a "level 4" file which contains the calculated K_{dph} values.

% Processing steps include:
% - Calculate Kd from histogram data.


%% Load data
clear all; close all; clc
folder='SET_DIRECTORY'; % USER INPUT

cd(folder)
load atl03_level3_file01.mat

%% Part 1.1 - Calculate Kd for single-beam data

for r=1:length(phbin.beam)
    for k=1:length(phbin.beam(r).sub)
        % x value for model
        zdepth=max(phbin.beam(r).sub(k).ctrs_subsurf,[],"omitnan")-phbin.beam(r).sub(k).ctrs_subsurf;

        % y value for model
        y=log(phbin.beam(r).sub(k).hisctsclean_subsurf);
        y(find(isinf(y)==1))=NaN;

        % Skip the regression if there are fewer than 5 datapoints
        numgood=length(find(y>0));
        if numgood>3

            % model
            mdl=polyfitn(zdepth,y,1);
            kd=-mdl.Coefficients(1);
            yfit=polyvaln(mdl,zdepth);
            e0=exp(yfit(1));

            if kd<0
                kd=NaN;
            end
            phbin.beam(r).sub(k).zdepth=zdepth;
            % phbin.beam(r).sub(k).zdepth=mdl;
            phbin.beam(r).sub(k).kd=kd;
            phbin.beam(r).sub(k).yfit=yfit;
            phbin.beam(r).sub(k).e0=e0;
        else
        end

        % sprintf(num2str(kd))
        clear zdepth y numgood mdl kd yfit e0

    end
end

    sprintf('SUCCESS!')

%% Part 1.2 - Calculate Kd for beam-pair data

for r=1:length(phbin.beampair)
    for k=1:length(phbin.beampair(r).sub)

        % x value for model
        zdepth=max(phbin.beampair(r).sub(k).ctrs_subsurf,[],"omitnan")-phbin.beampair(r).sub(k).ctrs_subsurf;

        % y value for model
        y=log(phbin.beampair(r).sub(k).hisctsclean_subsurf);
        y(find(isinf(y)==1))=NaN;

        % Skip the regression if there are fewer than 5 datapoints
        numgood=length(find(y>0));
        if numgood>3

            % model
            mdl=polyfitn(zdepth,y,1);
            kd=-mdl.Coefficients(1);
            yfit=polyvaln(mdl,zdepth);
            e0=exp(yfit(1));

            if kd<0
                kd=NaN;
            end
            phbin.beampair(r).sub(k).zdepth=zdepth;
            phbin.beampair(r).sub(k).kd=kd;
            phbin.beampair(r).sub(k).yfit=yfit;
            phbin.beampair(r).sub(k).e0=e0;
        else
        end

        clear zdepth y numgood mdl kd yfit e0

    end
end

    sprintf('SUCCESS!')



%% Save
cd(folder)
save('atl03_level4_','atm','phbin','removeAPIR','remove_solarbackground','binx','binz','spz');
