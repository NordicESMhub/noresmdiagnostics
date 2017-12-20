%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	MICOM DIAGNOSTICS (Matlab package)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detelina Ivanova, detelina.ivanova@nersc.no
% 25/02/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates and Plots Atlantic Zonal Mean Vertical Sections of T&S&PD
% from model T&S annual climatologies and compares to observed T&S climatologies (WOA09)
% Regrids the model fields to WOA09 1x1deg LatLon grid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all;

% Grunch & Hexagon
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/mats
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4f
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/matlab_netcdf_5_0
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/eosben07
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/eoslib05

%Remapping file with interpolation weights (map_file)
% Grunch & Hexagon
map_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/map_files/map_tnx1v1_to_woa09_aave_20120501.nc';

% WOA09 Observed T&S Climatologies
% Grunch & Hexagon
t_woa09_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/obs_data/WOA09/t00an1.nc';
s_woa09_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/obs_data/WOA09/s00an1.nc';

% Mask for Atlantic Ocean on 1x1deg latlon grid
mask_woa09_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/mask_files/woa09/atlantic_mask.dat';

%%%%%%%%%%%%%%%%%%% USER DEFINED PATHS and FILE NAMES %%%%%%%%%%%%%%
   
% Sensitivity case name 
exp='N1850_f19_tn11_E17';

% Control case name
cntrl='N1850_f19_tn11_01_default';

% Type of the input file :hy,hm,hd
% Sensitivity case
ftype='hy';
% Control case
fctype='hy';

% Period of averaging, usually part of the input file name
% Sensitivity case
year1=171;
year2=200;
% Control case
yearc1=171;
yearc2=200;

% Path of the input model annual average file for the Sensitivity case
workpath=['/fimm/work/detivan/noresm/micom_diag/diag_new/' exp '/'];

% Path of the input model annual average file for the Control case
cntrlpath=['/fimm/work/detivan/noresm/micom_diag/diag_new/' cntrl '/'];

% Path for the output plots
picpath=['/fimm/work/detivan/noresm/micom_diag/web_plots_new/' exp '/'];

%%%%%%%%%%%%%%%%%%%%%% Reading the input files %%%%%%%%%%%%%%%%%%%%%%%%

% Read WOA09 atlantic mask
fid=fopen(mask_woa09_file,'r');
nx=fscanf(fid,'%d',1);
ny=fscanf(fid,'%d',1);
mask_woa09=reshape(fscanf(fid,'%1d'),ny,nx)';
fclose(fid);

% Load WOA09 data
  lat=ncgetvar(t_woa09_file,'lat');
  lon=ncgetvar(t_woa09_file,'lon');
  depth=ncgetvar(t_woa09_file,'depth');
  t=ncgetvar(t_woa09_file,'t');
  s=ncgetvar(s_woa09_file,'s');
  [nx ny nz]=size(t);
  p=reshape(ones(nx*ny,1)*depth',nx,ny,nz);
  ptmp=theta_from_t(s,t,p,zeros(nx,ny,nz));
nx_b=nx;
ny_b=ny;
nz_b=nz;
lon_woa09=lon;
lat_woa09=lat;
depth_woa09=depth;
t_woa09=t;
s_woa09=s;
ptmp_woa09=ptmp;
clear nx ny nz lon lat depth t s ptmp

% Load time averaged Control run model data

cntrlname=[cntrlpath '/' cntrl '.micom.hy.' num2str(yearc1) '_' num2str(yearc2) 'y.nc'];

ncid=netcdf.open(cntrlname,'NC_NOWRITE');

         varid=netcdf.inqVarID(ncid,'templvl');
         tmp=ncread(cntrlname,'templvl');
         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
         templvlc=nan*ones(size(tmp));
         ind=find(tmp~=fill_value);
         templvlc(ind)=tmp(ind);

         varid=netcdf.inqVarID(ncid,'salnlvl');
         tmp=ncread(cntrlname,'salnlvl');
         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
         salnlvlc=nan*ones(size(tmp));
         ind=find(tmp~=fill_value);
         salnlvlc(ind)=tmp(ind);
         
netcdf.close(ncid)

% Load time averaged model data

fname = [workpath '/' exp '.micom.' ftype '.'  num2str(year1) '_' num2str(year2) 'y.nc' ];

ncid=netcdf.open(fname,'NC_NOWRITE');

         nx=ncgetdim(fname,'x');
         ny=ncgetdim(fname,'y');
         nz=ncgetdim(fname,'depth');
         depth=ncgetvar(fname,'depth');

         varid=netcdf.inqVarID(ncid,'templvl');
         tmp=ncread(fname,'templvl');
         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
         templvl=nan*ones(size(tmp));
         ind=find(tmp~=fill_value);
         templvl(ind)=tmp(ind);

         varid=netcdf.inqVarID(ncid,'salnlvl');
         tmp=ncread(fname,'salnlvl');
         max(max(max(tmp))) 
         min(min(min(tmp)))
         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
         salnlvl=nan*ones(size(tmp));
         ind=find(tmp~=fill_value);
         salnlvl(ind)=tmp(ind);
         
netcdf.close(ncid)

%%%%%%%%%%%%%%%%%%%%%%%%%%% Interpolation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reinterpolate the model field (source grid: (nx_a,ny_a,depth_a) 
% to the WOA09 field (destination grid: (nx_b, ny_b, depth_woa09)) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nx_a=nx;
ny_a=ny;
depth_a=depth;
nz_a=find(depth_woa09(end)==depth_a);
depth_a=depth_a(1:nz_a);

% Read interpolation indexes and weights
n_a=ncgetdim(map_file,'n_a');
n_b=ncgetdim(map_file,'n_b');
S=sparse(ncgetvar(map_file,'row'),ncgetvar(map_file,'col'), ...
         ncgetvar(map_file,'S'),n_b,n_a);


% Create 3D masks for atlantic (mask==2)
mask_3d_woa09=reshape(reshape(mask_woa09,[],1)*ones(1,nz_b),nx_b,ny_b,nz_b);
mask_3d_woa09(find(isnan(t_woa09)|mask_3d_woa09~=2))=0;
mask_3d_woa09(find(mask_3d_woa09==2))=1;
mask_3d_dst=reshape(reshape(mask_woa09,[],1)*ones(1,nz_a),nx_b,ny_b,nz_a);
mask_3d_dst(find(mask_3d_dst~=2))=0;
mask_3d_dst(find(mask_3d_dst==2))=1;

% Interpolate model data to WOA09 grid
t_dst=zeros(nx_b,ny_b,nz_a);
s_dst=zeros(nx_b,ny_b,nz_a);
tc_dst=zeros(nx_b,ny_b,nz_a);
sc_dst=zeros(nx_b,ny_b,nz_a);
weight_dst=zeros(nx_b,ny_b,nz_a);
for k=1:nz_a
  t_src=reshape(templvl(:,1:end-1,k),[],1);
  s_src=reshape(salnlvl(:,1:end-1,k),[],1);
  tc_src=reshape(templvlc(:,1:end-1,k),[],1);
  sc_src=reshape(salnlvlc(:,1:end-1,k),[],1);
  mask_src=ones(size(t_src));
  mask_src(find(isnan(t_src)))=0;
  t_src(find(isnan(t_src)))=0;
  s_src(find(isnan(s_src)))=0;
  tc_src(find(isnan(tc_src)))=0;
  sc_src(find(isnan(sc_src)))=0;
  t_dst(:,:,k)=reshape(S*t_src,nx_b,ny_b);
  s_dst(:,:,k)=reshape(S*s_src,nx_b,ny_b);
  tc_dst(:,:,k)=reshape(S*tc_src,nx_b,ny_b);
  sc_dst(:,:,k)=reshape(S*sc_src,nx_b,ny_b);
  weight_dst(:,:,k)=reshape(S*mask_src,nx_b,ny_b);
end

% Create WOA09 zonal means
ptmp_zm_woa09=squeeze(nansum(ptmp_woa09.*mask_3d_woa09)./sum(mask_3d_woa09));
ptmp_zm_woa09_a=interp1(depth_woa09,ptmp_zm_woa09',depth_a)';
s_zm_woa09=squeeze(nansum(s_woa09.*mask_3d_woa09)./sum(mask_3d_woa09));
s_zm_woa09_a=interp1(depth_woa09,s_zm_woa09',depth_a)';
for j=1:ny_b
  k=find(isnan(ptmp_zm_woa09_a(j,:)),1,'first');
  if ~isempty(k)&&k>1
    ptmp_zm_woa09_a(j,k)=ptmp_zm_woa09_a(j,k-1);
    s_zm_woa09_a(j,k)=s_zm_woa09_a(j,k-1);
  end
end

% Create model zonal means
t_zm_dst=squeeze(nansum(t_dst.*mask_3d_dst)./sum(weight_dst.*mask_3d_dst));
s_zm_dst=squeeze(nansum(s_dst.*mask_3d_dst)./sum(weight_dst.*mask_3d_dst));
tc_zm_dst=squeeze(nansum(tc_dst.*mask_3d_dst)./sum(weight_dst.*mask_3d_dst));
sc_zm_dst=squeeze(nansum(sc_dst.*mask_3d_dst)./sum(weight_dst.*mask_3d_dst));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot_depth_mapped=0;
depth_half=1000;
depth_max=5500;
depth_tick=[0 250 500 750 1000 2000 3000 4000 5000];

depth_mapped=0.5*(min(depth_half,depth)/depth_half ...
                 +(max(depth_half,depth)-depth_half) ...
                  /(depth_max-depth_half));
depth_tick_mapped=0.5*(min(depth_half,depth_tick)/depth_half ...
                      +(max(depth_half,depth_tick)-depth_half) ...
                       /(depth_max-depth_half));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Atlantic Mean Zonal Temperature Model-Obs Difference - Figure(1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Difference with observed
t_zm_dst(t_zm_dst==0)=NaN;
fld=t_zm_dst-ptmp_zm_woa09_a;

fld=fld'; 
ifirst=find(~isnan(nanmean(fld)),1,'first');
ilast=find(~isnan(nanmean(fld)),1,'last');
ilast=155;
figure_height_scale=1;
cbar_width_scale=2/3;
fontsize=12;

x=lat_woa09;
if plot_depth_mapped
  y=depth_mapped;
else
  y=depth_a;
end

% Plot Temperature Mod-Obs (WOA)
contour_factor=1;
cv=[-3:0.5:3]*contour_factor;
%cv=[-.5 -.35 -.25 -.15 -.05 .05 .15 .25 .35 .5];

figure(1);clf;hold on
set(gcf,'paperunits','inches','papersize',[8 6*figure_height_scale], ...
        'paperposition',[0 0 8 6*figure_height_scale],'color',[1 1 1], ...
        'renderer','painters','inverthardcopy','off')
set(gca,'outerposition',[0 0 1 1],'position',[0.1 0.2 0.8 0.75], ...
        'color',[.7 .7 .7])

colormap(cbsafemap(511,'rdbu'))
[c,h]=contourf(x,y,-fld,[-cv(1) inf],'linecolor','none');
set(findobj(h,'type','patch'),'facecolor','flat','cdata',-inf);
[c,hc]=contourf(x,y,fld,cv,'linecolor','none');

contour(x,y,fld,cv,'linecolor','k')

xlabel('Latitude','fontsize',fontsize)
ylabel('Depth [m]','fontsize',fontsize)
hb=cbarfmb([-inf inf],cv,'vertical','nonlinear');
ylabel(hb,'^oC','fontsize',fontsize);
pos=get(hb,'position');
pos(3)=pos(3)*cbar_width_scale;
set(hb,'position',pos,'fontsize',fontsize)
cdatamidlev([hc;hb],cv,'nonlinear');
caxis([cv(1) cv(end)])
caxis(hb,[cv(1) cv(end)])
if plot_depth_mapped
  set(gca,'ytick',depth_tick_mapped,'yticklabel',depth_tick,'ylim',[0 1]) 
end
set(gca,'box','on','layer','top', ...
        'xlim',[x(ifirst) x(ilast)],'ydir','reverse', ...
        'fontsize',fontsize)
title([' Atlantic Zonal Mean Temperature Differences with WOA09, ' str_name_disp(exp) ',  ' num2str(year1) '-'  ...
       num2str(year2) 'yr'], 'FontSize',12,'FontWeight','Bold') 

% Save plot
%eval(['print -dpng ' picpath 'temp_zonalmean_atlantic_' exp '_' num2str(year1) '-' num2str(year2) '_obs_diff.png'])
%eval(['print -dpng ' picpath 'temp_zonalmean_atlantic_diff.png'])

clear fld ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot Atlantic Mean Zonal SALINITY Model-Obs(WOA09) Difference (Figure(2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s_zm_dst(s_zm_dst==0)=NaN;
%Difference with Obs
fld=s_zm_dst-s_zm_woa09_a;

fld=fld'; 
ifirst=find(~isnan(nanmean(fld)),1,'first');
ilast=find(~isnan(nanmean(fld)),1,'last');
ilast=155;
figure_height_scale=1;
cbar_width_scale=2/3;
fontsize=12;

x=lat_woa09;
if plot_depth_mapped
  y=depth_mapped;
else
  y=depth_a;
end

% Plot Salinity Mod-Obs (WOA)
contour_factor=1;
cv=[-0.8:0.1:0.8]*contour_factor;
%cv=[-.8 -.56 -.40 -.24 -.006 .006 .24 .40 .56 .8];

figure(2);
clf;hold on
set(gcf,'paperunits','inches','papersize',[8 6*figure_height_scale], ...
        'paperposition',[0 0 8 6*figure_height_scale],'color',[1 1 1], ...
        'renderer','painters','inverthardcopy','off')
set(gca,'outerposition',[0 0 1 1],'position',[0.1 0.2 0.8 0.75], ...
        'color',[.7 .7 .7])
colormap(cbsafemap(511,'orpu'))

[c,h]=contourf(x,y,-fld,[-cv(1) inf],'linecolor','none');
set(findobj(h,'type','patch'),'facecolor','flat','cdata',-inf);
[c,hc]=contourf(x,y,fld,cv,'linecolor','none');

contour(x,y,fld,cv,'linecolor','k')

hold on

xlabel('Latitude','fontsize',fontsize)
ylabel('Depth [m]','fontsize',fontsize)
hb=cbarfmb([-inf inf],cv,'vertical','nonlinear');
ylabel(hb,'g/kg','fontsize',fontsize);
pos=get(hb,'position');
pos(3)=pos(3)*cbar_width_scale;
set(hb,'position',pos,'fontsize',fontsize)
cdatamidlev([hc;hb],cv,'nonlinear');
caxis([cv(1) cv(end)])
caxis(hb,[cv(1) cv(end)])
if plot_depth_mapped
  set(gca,'ytick',depth_tick_mapped,'yticklabel',depth_tick,'ylim',[0 1]) 
else
end
set(gca,'box','on','layer','top', ...
        'xlim',[x(ifirst) x(ilast)],'ydir','reverse', ...
        'fontsize',fontsize)
title([' Atlantic Zonal Mean Salinity Differences with WOA09, ' str_name_disp(exp) ', '  num2str(year1) '-'  ...
       num2str(year2) 'yr'], 'FontSize',12,'FontWeight','Bold') 

% Save plot   
%eval(['print -dpng ' picpath 'saln_zonalmean_atlantic_' exp '_' num2str(year1) '-' num2str(year2) '_obs_diff.png'])
%eval(['print -dpng ' picpath 'saln_zonalmean_atlantic_diff.png'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot Atlantic Mean Zonal POTENTIAL DENSITY Model-Obs(WOA09) Difference (Figure(3))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculating the Potential Density
% Model
sig0m=rho(0,t_zm_dst,s_zm_dst)-1000.;
% WOA09
sig0d=rho(0,ptmp_zm_woa09_a,s_zm_woa09_a)-1000.;

fld=sig0m-sig0d;
fld=fld';

% Plot Potential Density Mod-Obs (WOA)
figure(3);
clf;hold on

%Contour intervals
contour_factor=1;
%cv=[-.5 -.35 -.25 -.15 -.05 .05 .15 .25 .35 .5]*contour_factor;
cv=[-0.5:0.05:0.5]*contour_factor;

set(gcf,'paperunits','inches','papersize',[8 6*figure_height_scale], ...
        'paperposition',[0 0 8 6*figure_height_scale],'color',[1 1 1], ...
        'renderer','painters','inverthardcopy','off')
set(gca,'outerposition',[0 0 1 1],'position',[0.1 0.2 0.8 0.75], ...
        'color',[.7 .7 .7])
colormap(cbsafemap(511,'BrBG'))

[c,h]=contourf(x,y,-fld,[-cv(1) inf],'linecolor','none');
set(findobj(h,'type','patch'),'facecolor','flat','cdata',-inf);
[c,hc]=contourf(x,y,fld,cv,'linecolor','none');

contour(x,y,fld,cv,'linecolor','k')

hold on

xlabel('Latitude','fontsize',fontsize)
ylabel('Depth [m]','fontsize',fontsize)
hb=cbarfmb([-inf inf],cv,'vertical','nonlinear');
ylabel(hb,'sigma_t','fontsize',fontsize);
pos=get(hb,'position');
pos(3)=pos(3)*cbar_width_scale;
set(hb,'position',pos,'fontsize',fontsize)
cdatamidlev([hc;hb],cv,'nonlinear');
caxis([cv(1) cv(end)])
caxis(hb,[cv(1) cv(end)])
if plot_depth_mapped
  set(gca,'ytick',depth_tick_mapped,'yticklabel',depth_tick,'ylim',[0 1]) 
else
end
set(gca,'box','on','layer','top', ...
        'xlim',[x(ifirst) x(ilast)],'ydir','reverse', ...
        'fontsize',fontsize)
title([' Atlantic Zonal Mean Density Differences with WOA09, ' str_name_disp(exp) ', '  num2str(year1) '-'  ...
       num2str(year2) 'yr'], 'FontSize',12,'FontWeight','Bold') 
   
%Save plot
%eval(['print -dpng ' picpath 'den_zonalmean_atlantic_' exp '_' num2str(year1) '-' num2str(year2) '_obs_diff.png'])
