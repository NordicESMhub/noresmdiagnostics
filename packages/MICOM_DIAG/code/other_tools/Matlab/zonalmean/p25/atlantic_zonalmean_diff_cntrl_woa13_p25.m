%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%v
%	MICOM DIAGNOSTICS (Matlab package)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detelina Ivanova, detelina.ivanova@nersc.no
% 10/03/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates Atlantic Zonal Mean Vertical Sections of T&S&PD
% Compares the model Sensitivity Case to WOA13 observations climatology
% Regrids the model fields to WOA13 0.25deg LatLon grid
% Plots the diferences and saves the plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
map_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/map_files/map_tnx0.25v1_to_woa13p25_aave_20150303.nc';

% WOA13 T&S Observational Climatologies files (t/s_woa13_file) 
% Grunch & Hexagon
t_woa13_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/obs_data/WOA13/0.25deg/woa13_decav_t00_04.nc';
s_woa13_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/obs_data/WOA13/0.25deg/woa13_decav_s00_04.nc';

% Mask for Atlantic Ocean on 1x1deg latlon grid
mask_woa13_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/mask_files/region_mask_woa13_p25.dat';
% Regions:
% 1 - Pacific Ocean; 2 - Atlantic Ocean; 3 - Black Sea; 4 - Southern Ocean; 
% 5 - Red Sea; 6- Arctic Ocean; 7 - Indian Ocean; 8 - Huson Bay; 9 - Mediterranean Sea
% 10 - Baltic Sea

%%%%%%%%%%%%%%%%%%%%%%%%%% USER DEFINED PATHS and FILENAMES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
% Sensitivity case name 
exp='ATM_f09_MICOM_tnx025';
name_disp='ATM\_f09\_MICOM\_tnx025';

% Type of the input file :hy,hm,hd
% Sensitivity case
ftype='hy';

% Period of averaging, usually part of the input file name
% Sensitivity case
year1=171;
year2=200;

% Path of the input model annual average file for the Sensitivity case
workpath=['/fimm/work/detivan/noresm/micom_diag/diag_new/' exp '/'];
% Input file name
fname = [workpath '/' exp '.micom.' ftype '.'  num2str(year1) '_' num2str(year2) 'y.nc' ];
%test-file
fname = '/fimm/work/detivan/mnt/norstore/NS9998K/ATM_f09_MICOM_tnx025/ocn/hist/ATM_f09_MICOM_tnx025.micom.hm.0095-01.nc'

% Path of the input model annual average file for the Control case
cntrlpath=['/fimm/work/detivan/noresm/micom_diag/diag_new/' cntrl '/'];
cntrlname=[cntrlpath '/' cntrl '.micom.hy.' num2str(yearc1) '_' num2str(yearc2) 'y.nc'];

% Path for the output plots
picpath=['/fimm/work/detivan/noresm/micom_diag/web_plots_new/' exp '/'];

%%%%%%%%%%%%%%%%%%%%%% Reading the input files %%%%%%%%%%%%%%%%%%%%%%%%

% Load woa13 data
lat=ncgetvar(t_woa13_file,'lat');
lon=ncgetvar(t_woa13_file,'lon');
depth=ncgetvar(t_woa13_file,'depth');
t=double(ncread(t_woa13_file,'t_an'));
s=double(ncread(s_woa13_file,'s_an'));
[nx ny nz]=size(t);
p=reshape(ones(nx*ny,1)*depth',nx,ny,nz);
ptmp=theta_from_t(s,t,p,zeros(nx,ny,nz));
nx_b=nx;
ny_b=ny;
nz_b=nz;
lon_woa13=lon;
lat_woa13=lat;
depth_woa13=depth;
t_woa13=t;
s_woa13=s;
ptmp_woa13=ptmp;

% Read woa13 region mask

fid=fopen(mask_woa13_file,'r');
mask_woa13=fread(fid,[nx,ny],'float32');
fclose(fid);

clear nx ny nz lon lat depth t s ptmp

lon2d=lon_woa13*ones(1,ny_b);
lat2d=ones(nx_b,1)*lat_woa13';

% Load time averaged Control run model data

ncid=netcdf.open(cntrlname,'NC_NOWRITE');

         varid=netcdf.inqVarID(ncid,'templvl');
         tmp=ncread(fname,'templvl');
         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
         templvlc=nan*ones(size(tmp));
         ind=find(tmp~=fill_value);
         templvlc(ind)=tmp(ind);

         varid=netcdf.inqVarID(ncid,'salnlvl');
         tmp=ncread(fname,'salnlvl');
         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
         salnlvlc=nan*ones(size(tmp));
         ind=find(tmp~=fill_value);
         salnlvlc(ind)=tmp(ind);
         
netcdf.close(ncid)

% Load time averaged model data


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

%%%%%%%%%%%%%%%%%%%%%%%%%%% Interpolation (Do not change!) %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reinterpolate the model field (source grid: (nx_a,ny_a,depth_a) 
% to the woa13 field (destination grid: (nx_b, ny_b, depth_woa13)) 
nx_a=nx;
ny_a=ny;
depth_a=depth;
nz_a=find(depth_woa13(end)==depth_a);
depth_a=depth_a(1:nz_a);

% Read interpolation indexes and weights
n_a=ncgetdim(map_file,'n_a');
n_b=ncgetdim(map_file,'n_b');
S=sparse(ncgetvar(map_file,'row'),ncgetvar(map_file,'col'), ...
         ncgetvar(map_file,'S'),n_b,n_a);


% Create 3D masks for Atlantic (mask==2) and Atlantic sector of SO (mask==4)
am=mask_woa13; am(find(am==0|am~=2))=0;                                % Atlantic ocean
sm=mask_woa13; sm(find(sm==0 | sm~=4 | lon2d<-70.5 | lon2d>19.5))=0;   % Atlantic Sector of SO
mm=ones(size(mask_woa13)); mm(am==0 & sm==0)=0;                        % Merged mask

mask_3d_woa13=reshape(reshape(mm,[],1)*ones(1,nz_b),nx_b,ny_b,nz_b);
mask_3d_woa13(find(isnan(t_woa13)))=0;

mask_3d_dst=reshape(reshape(mm,[],1)*ones(1,nz_a),nx_b,ny_b,nz_a);

% Interpolate model data to woa13 grid
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

% Create woa13 zonal means
ptmp_zm_woa13=squeeze(nansum(ptmp_woa13.*mask_3d_woa13)./sum(mask_3d_woa13));
ptmp_zm_woa13_a=interp1(depth_woa13,ptmp_zm_woa13',depth_a)';
s_zm_woa13=squeeze(nansum(s_woa13.*mask_3d_woa13)./sum(mask_3d_woa13));
s_zm_woa13_a=interp1(depth_woa13,s_zm_woa13',depth_a)';
for j=1:ny_b
  k=find(isnan(ptmp_zm_woa13_a(j,:)),1,'first');
  if ~isempty(k)&&k>1
    ptmp_zm_woa13_a(j,k)=ptmp_zm_woa13_a(j,k-1);
    s_zm_woa13_a(j,k)=s_zm_woa13_a(j,k-1);
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
% Plot Atlantic Mean Zonal Temperature Model Sensitivity - Control Case Difference - Figure(1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Difference with control
fld=t_zm_dst-tc_zm_dst;

fld=fld'; 
ifirst=find(~isnan(nanmean(fld)),1,'first');
ilast=find(~isnan(nanmean(fld)),1,'last');
figure_height_scale=1;
cbar_width_scale=2/3;
fontsize=12;

x=lat_woa13;
if plot_depth_mapped
  y=depth_mapped;
else
  y=depth_a;
end

%Contour Intervals (Change if desired) 
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
title([' Atlantic Zonal Mean Temperature Differences with Control, ' str_name_disp(exp) ',  ' num2str(year1) '-'  ...
       num2str(year2) 'yr'], 'FontSize',12,'FontWeight','Bold') 

%eval(['print -dpng ' picpath 'temp_zonalmean_atlantic_' exp '_' num2str(year1) '-' num2str(year2) '_cntrl_diff.png'])

clear fld ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot Atlantic Mean Zonal SALINITY Model Sensitivity -Control Case Difference (Figure(2))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s_zm_dst(s_zm_dst==0)=NaN;
%Difference with Control
fld=s_zm_dst-sc_zm_dst;

fld=fld'; 
ifirst=find(~isnan(nanmean(fld)),1,'first');
ilast=find(~isnan(nanmean(fld)),1,'last');
figure_height_scale=1;
cbar_width_scale=2/3;
fontsize=12;

x=lat_woa13;
if plot_depth_mapped
  y=depth_mapped;
else
  y=depth_a;
end

%Contour Intervals (Change if desired) 
contour_factor=1;
cv=[-0.8:0.1:0.8]*contour_factor;
%cv=[-2:0.2:2];

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
title([' Atlantic Zonal Mean Salinity Differences with Control, ' str_name_disp(exp) ', '  num2str(year1) '-'  ...
       num2str(year2) 'yr'], 'FontSize',12,'FontWeight','Bold') 

%Save plots
%eval(['print -dpng ' picpath 'saln_zonalmean_atlantic_' exp '_' num2str(year1) '-' num2str(year2) '_cntrl_diff.png'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot Atlantic Mean Zonal POTENTIAL DENSITY Model Sensitivity -Control Case Difference (Figure(3))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculating the Potential Density
% Model
sig0m=rho(0,t_zm_dst,s_zm_dst)-1000.;
sigc0m=rho(0,tc_zm_dst,sc_zm_dst)-1000.;
fld=sig0m-sigc0m;
fld=fld';

% Plot 
figure(3);
clf;hold on
contour_factor=2;

%Contour Intervals (Change if desired) 
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
title([' Atlantic Zonal Mean Density Differences with Control, ' str_name_disp(exp) ', '  num2str(year1) '-'  ...
       num2str(year2) 'yr'], 'FontSize',12,'FontWeight','Bold') 
 
 % Save plot
 %eval(['print -dpng ' picpath 'den_zonalmean_atlantic_' exp '_' num2str(year1) '-' num2str(year2) '_cntrl_diff.png'])
