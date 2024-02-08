%% Example of APIR removal using a gaussian fit

% To accompany Eidam et al., "ICESat-2 and ocean particulates: A roadmap
% for calculating Kd from space-based lidar photon profiles"
% SEE ABOVE PAPER FOR MORE INFORMATION

% NOTE THAT THIS APPROACH IS **NOT** RECOMMENDED!

% Emily Eidam, February 2024, emily.eidam@oregonstate.edu


%% Load "idealized" AP/IR example
% These photon counts represented combined photon data from beams gt1r and
% gt1l, ICESAT-2 file processed_ATL03_20201129072343_10100902_005_01.h5
% (available through NASA EarthData)

load apir_nc_example.mat;

%% Make plot of raw NC data 

nc.cts=cts;
nc.z=-(z-max(z));
% ncuse=1061:1180; % for 0.05 m binned data
% nc.ctscompare=nc.cts(ncuse)./100;

%% Compute four-part gaussian fit using Matlab's built-in fit function with the gauss4 option
gy=nc.cts(1:1182);
gx=nc.z(1:1182);

gf=fit(gx',gy','gauss4');
gfy1=gf.a1*exp(-((gx-gf.b1)./gf.c1).^2);
gfy2=gf.a2*exp(-((gx-gf.b2)./gf.c2).^2);
gfy3=gf.a3*exp(-((gx-gf.b3)./gf.c3).^2);
gfy4=gf.a4*exp(-((gx-gf.b4)./gf.c4).^2);

%% Plot the 
fs=11;

close all

fig1=figure(1);
set(fig1,'position',[0 800 550 550],'color','w')

subplot(2,2,[1:2])
plot(xraw,zraw,'k.','markersize',2)
ylim([-78 -38])
xlim([17 42])
xlabel('distance along track (km)')
ylabel('elevation (m)')
set(gca,'fontsize',fs)
text(-0.1,1,'A','fontsize',fs+1,'fontweight','bold','units','normalized')

subplot(2,2,3); hold on
xlog=log(cts./sum(cts));
ylog=z
plot(xlog,ylog,'.-','color',[.75 .75 .75])
plot(xlog(1:1182),ylog(1:1182),'k.-')
% xlim([0 0.001])
ylim([-78 -38])
xlim([-12 -2])
xlabel({'ln(counts normalized','to surface peak), bin_z=0.05 m'})
ylabel('elevation (m)')
set(gca,'fontsize',fs)
text(-0.2,1,'B','fontsize',fs+1,'fontweight','bold','units','normalized')
box on

subplot(2,2,4)
hold on
plot(gfy1./25,gx,'linewidth',1.2);
plot(gfy2./25,gx,'linewidth',1.2);
plot(gfy3./25,gx,'linewidth',1.2);
plot(gfy4./25,gx,'linewidth',1.2);
ylim([0 40])
box on
% xlim([-12 -2])
% xlim([0 0.15])
% xlabel('ln(norm cts*)')
ylabel('depth (m)')
set(gca,'fontsize',fs)
set(gca,'ydir','reverse')
l1=legend('AP1','AP2','Decay','IR') % AP1 = afterpulse 1; AP2 = afterpulse 2; Decay = signal of interest (but still includes surface peak, which is an artifact); IR = impulse response
set(l1,'location','southeast')
xlabel({'counts per 1 km of horizontal','segment, bin_z=0.05 m'})
text(-0.2,1,'C','fontsize',fs+1,'fontweight','bold','units','normalized')

% From here, the "decay" data (the third guassian peak) can be used as the
% signal of interest (less the afterpulses and impulse response). Note that
% in this example, the decay signal still includes the surface peak, which
% should be discarded (see manuscript).

