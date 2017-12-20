%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%v
%	MICOM DIAGNOSTICS (Matlab package)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detelina Ivanova, detelina.ivanova@nersc.no
% 25/02/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates Indo-Pacific Zonal Mean Vertical Sections of T&S&PD
% Compares the model Sensitivity Case to Control Case 
% Regrids the model fields to 2x2deg LatLon grid
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
map_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/map_files/map_tnx2v1_to_dBM2x2_aave_20140127.nc';

% Source grid (2deg tripole: tnx2v1)
grid_file_src='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/grid_files/tnx2v1/20130206/grid.nc'

% Destination grid (2x2 LatLon) file
grid_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/grid_files/dBM2x2/remap_grid_dBM2x2_20140127.nc'

% Region Mask on 2x2deg latlon grid
mask_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/mask_files/region_mask_2x2.dat';
% Regions:
% 1 - Pacific Ocean; 2 - Indo-Pacific Ocean; 3 - Black Sea; 4 - Southern Ocean; 
% 5 - Red Sea; 6- Arctic Ocean; 7 - Indian Ocean; 8 - Huson Bay; 9 - Mediterranean Sea
% 10 - Baltic Sea

%%%%%%%%%%%%%%%%%%%%%%%%%% USER DEFINED PATHS and FILENAMES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
% Sensitivity case name 
exp='NOIIA_T62TN2_test2_intel';

% Control case name (Should be on the same grid as the Sensitivity case)
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
workpath=['/fimm/work/detivan/mnt/norstore/NS9998K/' exp '/ocn/hist/'];

% Path of the input model annual average file for the Control case
cntrlpath=['/fimm/work/detivan/noresm/micom_diag/diag_new/' cntrl '/'];

% Sensitivity Case filename 
%fname = [workpath '/' exp '.micom.' ftype '.'  num2str(year1) '_' num2str(year2) 'y.nc' ];
fname=[workpath exp '.micom.hm.0027-08.nc']

% Control Case filename 
cntrlname=[cntrlpath '/' cntrl '.micom.hy.' num2str(yearc1) '_' num2str(yearc2) 'y.nc'];

% Path for the output plots
picpath=['/fimm/work/detivan/noresm/micom_diag/web_plots_new/' exp '/'];

%%%%%%%%%%%%%%%%%%%%%% Reading the input files %%%%%%%%%%%%%%%%%%%%%%%%

% Load time averaged Control run model data

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

% Reading and applying the model land mask
lmask=double(ncread(grid_file_src,'pmask'));
lmask_3d=reshape(reshape(lmask,[],1)*ones(1,nz),nx,ny,nz);
templvl(lmask_3d==0)=nan;
salnlvl(lmask_3d==0)=nan;
templvlc(lmask_3d==0)=nan;
salnlvlc(lmask_3d==0)=nan;

% Reading the destination grid information
dim=ncread(grid_file,'grid_dims');
nx_b=dim(1); ny_b=dim(2);
lat=reshape(ncread(grid_file,'grid_center_lat'),nx_b,ny_b);
lon=reshape(ncread(grid_file,'grid_center_lon'),nx_b,ny_b);

lon2d=lon;
lat2d=lat;

% Read 2x2 region mask
fid=fopen(mask_file,'r');
mask_woa13=fread(fid,[nx_b,ny_b],'float32');
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%% Interpolation (Do not change!) %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reinterpolate the model fields (source grid: (nx_a,ny_a,depth_a)) 
%   to the destination grid: (nx_b, ny_b, depth_a) 
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




% Interpolate model data to the destination grid
t_dst=zeros(nx_b,ny_b,nz_a);
s_dst=zeros(nx_b,ny_b,nz_a);
tc_dst=zeros(nx_b,ny_b,nz_a);
sc_dst=zeros(nx_b,ny_b,nz_a);
weight_dst=zeros(nx_b,ny_b,nz_a);
for k=1:nz_a
  t_src=reshape(templvl(:,1:end-1,k),[],1);
  s_src=reshape(salnlvl(:,1:end-1,k),[],1);
  lmask_src=reshape(lmask_3d(:,1:end-1,k),[],1);
  tc_src=reshape(templvlc(:,1:end-1,k),[],1);
  sc_src=reshape(salnlvlc(:,1:end-1,k),[],1);
  mask_src=ones(size(t_src));
  mask_src(find(isnan(t_src)))=0;
  mask_src(find(lmask_src==0))=0;
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


% Create 3D masks for Pacific (mask==1), Indian Ocean (mask==7) and Indo-Pacific sector of SO (mask==4)
am=mask_woa13; am(find(am~=1 & am~=7))=0;                                % Pacific & Indian ocean
sm=mask_woa13; sm(find(sm~=4 | lon2d>=289.5 | lon2d<=19.5))=0;   % Indo-Pacific Sector of SO
mm=ones(size(mask_woa13)); mm(am==0 & sm==0)=0;                        % Merged mask

%Model 3D mask
mask_3d_dst=reshape(reshape(mm,[],1)*ones(1,nz_a),nx_b,ny_b,nz_a);

% Create model zonal means
t_dst(t_dst==0)=nan; s_dst(s_dst==0)=nan;
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
% Plot Indo-Pacific Mean Zonal Temperature ModelSensitivity-Control case Difference - Figure(1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t_zm_dst(t_zm_dst==0)=NaN;

%Difference with control
fld=t_zm_dst-tc_zm_dst;

fld=fld'; 
ifirst=find(~isnan(nanmean(fld)),1,'first');
ilast=find(~isnan(nanmean(fld)),1,'last');
figure_height_scale=1;
cbar_width_scale=2/3;
fontsize=12;

x=squeeze(lat2d(1,:));
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
title([' Indo-Pacific Zonal Mean Temperature Differences with Control, ' str_name_disp(exp) ',  ' num2str(year1) '-'  ...
       num2str(year2) 'yr'], 'FontSize',12,'FontWeight','Bold') 

%eval(['print -dpng ' picpath 'temp_zonalmean_indopac_' exp '_' num2str(year1) '-' num2str(year2) '_cntrl_diff.png'])

clear fld ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot Indo-Pacific Mean Zonal SALINITY Model Sensitivity-Control Difference (Figure(2))
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
title([' Indo-Pacific Zonal Mean Salinity Differences with Control, ' str_name_disp(exp) ', '  num2str(year1) '-'  ...
       num2str(year2) 'yr'], 'FontSize',12,'FontWeight','Bold') 

%Save plots
%eval(['print -dpng ' picpath 'saln_zonalmean_indopac_' exp '_' num2str(year1) '-' num2str(year2) '_cntrl_diff.png'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot Indo-Pacific Mean Zonal POTENTIAL DENSITY Model Sensitivity-Control Difference (Figure(3))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculating the Potential Density
sig0m=rho(0,t_zm_dst,s_zm_dst)-1000.;
sigc0m=rho(0,tc_zm_dst,sc_zm_dst)-1000.;

%Difference with Control
fld=sig0m-sigc0m;
fld=fld';

% Plot 
figure(3);
clf;hold on

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
title([' Indo-Pacific Zonal Mean Density Differences with Control, ' str_name_disp(exp) ', '  num2str(year1) '-'  ...
       num2str(year2) 'yr'], 'FontSize',12,'FontWeight','Bold') 
 
 % Save plot
 %eval(['print -dpng ' picpath 'den_zonalmean_indopac_' exp '_' num2str(year1) '-' num2str(year2) '_cntrl_diff.png'])
