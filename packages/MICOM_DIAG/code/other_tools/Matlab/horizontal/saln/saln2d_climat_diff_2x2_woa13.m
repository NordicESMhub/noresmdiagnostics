%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MICOM DIAGNOSTICS (Matlab package)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detelina Ivanova, detelina.ivanova@nersc.no
% 03/03/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Regrids model & WOA13 obs horizontal Salinity fields on chosen depths (vertical levels)
% to 2x2deg LatLon grid and Plots:
% 1) Mean Model Climatology - Figure (1)
% 2) Differences with the Observations (woa13) - Figure (2)
% 3) Differences with the Control Case (cntrl) - Figure (3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all;

% Grunch & Hexagon
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/mats
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4f
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/matlab_netcdf_5_0

%Remapping files with interpolation weights (map_file & map_file_woa13)
% Grunch & Hexagon
map_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/map_files/map_tnx2v1_to_dBM2x2_aave_20140127.nc';
map_file_woa13='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/map_files/map_woa13x1_to_dBM2x2_aave_20150305.nc';

% WOA13 Observations file (s_woa13_file)
% Grunch & Hexagon
s_woa13_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/obs_data/WOA13/1deg/woa13_decav_s00_01.nc';

% Destination grid (2x2 LatLon) file
grid_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/grid_files/dBM2x2/remap_grid_dBM2x2_20140127.nc'

%%%%%%%%%%%%%%%%%%% USER DEFINED PATHS and FILE NAMES %%%%%%%%%%%%%%

% Sensitivity Case name
exp='NOIIA_T62TN2_test2_intel';
name_disp='NOIIA\_T62TN2\_test2\_intel'
% Control Case name (when available)
%cntrl='N1850_f19_tn11_01_default';

% Period of the Sensitivity Case
year1=1;
year2=200;
% Period of the Control Case
yearc1=1;
yearc2=200;

% Path of the input model field for the Sensitivity Case
workpath=['/fimm/work/detivan/mnt/norstore/NS9998K/' exp '/ocn/hist/'];

% Path of the input model field for the Control Case
%cntrlpath=['/fimm/work/detivan/noresm/micom_diag/diag_new/' cntrl '/'];

% Path for the output plots
picpath=['/fimm/work/detivan/noresm/micom_diag/web_plots_new/'];
 
% Sensitivity Case filename 
%fname = [workpath '/' exp '.micom.hy.'  num2str(year1) '_' num2str(year2) 'y.nc' ];
fname=[workpath exp '.micom.hm.0027-08.nc']

% Control Case filename
%cntrlname=[cntrlpath '/' cntrl '.micom.hy.' num2str(yearc1) '_' num2str(yearc2) 'y.nc'];


% Depths to plot
lvls= [0, 100, 250, 500, 1000, 1500, 2000, 2500];  % [m]

for il=1:length(lvls)
    lvl=lvls(il)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% READING THE INPUT FILES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read woa13 Observaions Climatology data gridded on 1x1 LatLon grid
ncid=netcdf.open(s_woa13_file,'NC_NOWRITE');
         nx_a_woa13=ncgetdim(s_woa13_file,'lon');
         ny_a_woa13=ncgetdim(s_woa13_file,'lat');
         nz_a_woa13=ncgetdim(s_woa13_file,'depth');
         lon_a_woa13=ncgetvar(s_woa13_file,'lon');
         lat_a_woa13=ncgetvar(s_woa13_file,'lat');
         depth_a_woa13=ncgetvar(s_woa13_file,'depth');

         iz=find(depth_a_woa13==lvl)

         varid=netcdf.inqVarID(ncid,'s_an');
         tmp=ncread(s_woa13_file,'s_an');
         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
         temp=nan*ones(size(tmp));
         ind=find(tmp~=fill_value);
         temp(ind)=tmp(ind);

         sss_woa13_a=temp(:,:,iz);
         t_src_woa13 = reshape(sss_woa13_a,[],1);
         mask_src_woa13=ones(size(t_src_woa13));
         mask_src_woa13(find(isnan(t_src_woa13)))=0;
         [nx_a_woa13 ny_a_woa13]=size(sss_woa13_a);

netcdf.close(ncid)


% Read time averaged Control Case model data

%ncid=netcdf.open(cntrlname,'NC_NOWRITE');
         
%         nx_a=ncgetdim(cntrlname,'x');
%         ny_a=ncgetdim(cntrlname,'y');
%         nz_a=ncgetdim(cntrlname,'depth');
%         depth_a=ncgetvar(cntrlname,'depth');

%         ilvl=find(depth_a==lvl)

%         varid=netcdf.inqVarID(ncid,'salnlvl');
%         tmp=ncread(cntrlname,'salnlvl');
%         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
%         salnlvlc=nan*ones(size(tmp));
%         ind=find(tmp~=fill_value);
%         salnlvlc(ind)=tmp(ind);

%         sss_modelc_a=salnlvlc(:,1:end-1,ilvl);

%         [nx_a ny_a]=size(sss_modelc_a);

%netcdf.close(ncid)

% Load time averaged Sensitivity Case model data
ncid=netcdf.open(fname,'NC_NOWRITE');
         nx_a=ncgetdim(fname,'x');
         ny_a=ncgetdim(fname,'y');
         nz_a=ncgetdim(fname,'depth');
         depth_a=ncgetvar(fname,'depth');

         ilvl=find(depth_a==lvl)

         varid=netcdf.inqVarID(ncid,'salnlvl');
         tmp=ncread(fname,'salnlvl');
         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
         salnlvl=nan*ones(size(tmp));
         ind=find(tmp~=fill_value);
         salnlvl(ind)=tmp(ind);

         sss_model_a=salnlvl(:,1:end-1,ilvl);

         t_src = reshape(sss_model_a,[],1);
         mask_src=ones(size(t_src));
         mask_src(find(isnan(t_src)))=0;
         [nx_a ny_a]=size(sss_model_a);

netcdf.close(ncid)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INTERPOLATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reinterpolate the woa13 field (source grid: (nx_a_woa13,ny_a_woa13) to the 2x2 LatLon grid (destination grid: (nx_b, ny_b)) 
% Read regrid indexes and weights
  n_a=ncgetdim(map_file_woa13,'n_a');
  n_b=ncgetdim(map_file_woa13,'n_b');
  S=sparse(ncgetvar(map_file_woa13,'row'),ncgetvar(map_file_woa13,'col'), ...
           ncgetvar(map_file_woa13,'S'),n_b,n_a);
  dims=ncread(map_file_woa13,'dst_grid_dims');
  nx_b=dims(1); ny_b=dims(2);
 
  % Get destination area of interpolated data
  destarea=reshape(S*mask_src_woa13,nx_b,ny_b);

  % Regrid woa13 data on to 2x2 grid
  sss_woa13_b=reshape(S*t_src_woa13,nx_b,ny_b)./destarea;

% Reinterpolate the model field (source grid: (nx_a,ny_a) to the 2x2 LatLon grid (destination grid: (nx_b, ny_b)) 
% Read regrid indexes and weights
  n_a=ncgetdim(map_file,'n_a');
  n_b=ncgetdim(map_file,'n_b');
  S=sparse(ncgetvar(map_file,'row'),ncgetvar(map_file,'col'), ...
           ncgetvar(map_file,'S'),n_b,n_a);

  % Get destination area of interpolated data
  destarea=reshape(S*mask_src,nx_b,ny_b);

  % Regrid model data on to 2x2 grid
  sss_model_b=reshape(S*t_src,nx_b,ny_b)./destarea;
%  sss_modelc_b=reshape(S*reshape(sss_modelc_a,[],1),nx_b,ny_b)./destarea;

%area_b=reshape(ncgetvar(map_file,'area_b'),nx_b,ny_b);

% Shifting the grid to center at 0W [180W 180E]; Original 2x2 grid is [0 360]
%lon_b=[(lon_b((nx_b/2+1):end)-360);lon_b(1:nx_b/2)];
sss_woa13_b=[sss_woa13_b((nx_b/2+1):end,:);sss_woa13_b(1:nx_b/2,:)];
sss_model_b=[sss_model_b((nx_b/2+1):end,:);sss_model_b(1:nx_b/2,:)];
%sss_modelc_b=[sss_modelc_b((nx_b/2+1):end,:);sss_modelc_b(1:nx_b/2,:)];

%lon=lon_b*ones(1,ny_b);
%lat=ones(nx_b,1)*lat_b';

lat=reshape(ncread(grid_file,'grid_center_lat'),nx_b,ny_b);
lon=reshape(ncread(grid_file,'grid_center_lon'),nx_b,ny_b);
lon=[(lon((nx_b/2+1):end,:)-360);lon(1:nx_b/2,:)];
area_b=reshape(ncread(grid_file,'grid_area'),nx_b,ny_b);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure_height_scale=0.65;
cbar_width_scale=1;
fontsize=12;
contour_factor=10;

%Plot Sensitivity Case Mean Model Climatology (Figure (1))
fld=sss_model_b;
fld(fld==0)=nan;

ind=find(~(isnan(fld)|(lon>28&lon<42&lat>41&lat<47)| ...
                      (lon>46&lon<56&lat>37&lat<51)));
disp(sprintf('delta = %8.4f', ...
             sum(fld(ind).*area_b(ind))/sum(area_b(ind))))
disp(sprintf('rmse = %8.4f', ...
             sqrt(sum((fld(ind).^2).*area_b(ind))/sum(area_b(ind)))))

% Contour Intervals 
cv=[30 31 33:0.5:39];

figure(1);clf;hold on;set(gcf, 'render','painters') 
m_proj('Equidistant Cylindrical','lon',[-180 180],'lat',[-90 90]);
set(gcf,'paperunits','inches','papersize',[8 6*figure_height_scale], ...
        'paperposition',[0 0 8 6*figure_height_scale],'renderer','painters')
set(gca,'outerposition',[0 0 1 1],'position',[0.1 0.2 0.8 0.75])
colormap(cbsafemap(511,'rdylbu'))
[c,h]=m_contourf(lon,lat,-fld,[-cv(1) inf],'linecolor','none');
set(findobj(h,'type','patch'),'facecolor','flat','cdata',-inf);
[c,hc]=m_contourf(lon,lat,fld,cv,'linecolor','none');
hnan=findobj(hc,'type','patch','cdata',nan);
m_contour(lon,lat,fld,cv,'linecolor','k')
hold on

xlabel('Longitude','fontsize',fontsize)
ylabel('Latitude','fontsize',fontsize)

m_coast('patch',[.7 .7 .7]);
m_grid
set(gca,'DataAspectRatioMode','auto')
hb=cbarfmb([-inf inf],cv,'vertical','nonlinear');
ylabel(hb,'g/kg','fontsize',fontsize);
pos=get(hb,'position');
pos(3)=pos(3)*cbar_width_scale;
set(hb,'position',pos,'fontsize',fontsize)
cdatamidlev([hc;hb],cv,'nonlinear');
caxis([cv(1) cv(end)])
caxis(hb,[cv(1) cv(end)])
set(hnan,'facecolor',[1 1 1])

title(['Salinity Climatology ' name_disp '  at Depth ', num2str(depth_a(ilvl)),'m' ],'FontSize',12,'Fontweight','bold') 

% Save plot (uncomment when needed)
%eval(['print -depsc ' picpath '/' exp '/t_clim_' num2str(depth_a(ilvl)),'m.eps'])


% Plot the differences of the Sensitivity Case with woa13 observations (Figure(2))
fld=sss_model_b-sss_woa13_b;
fld(fld==0)=nan;

ind=find(~(isnan(fld)|(lon>28&lon<42&lat>41&lat<47)| ...
                      (lon>46&lon<56&lat>37&lat<51)));
disp(sprintf('delta = %8.4f', ...
             sum(fld(ind).*area_b(ind))/sum(area_b(ind))))
disp(sprintf('rmse = %8.4f', ...
             sqrt(sum((fld(ind).^2).*area_b(ind))/sum(area_b(ind)))))

% Contour intervals (Change if desired)
contour_factor=1;
cv=[-4 -2 -1.2 -0.6 -.2 .2 0.6 1.2 2 4]*contour_factor;
cvpos=[ .2 0.6 1.2 2 4]*contour_factor;
cvneg=[-4 -2 -1.2 -0.6 -.2]*contour_factor;

figure(2);clf;hold on;set(gcf, 'render','painters')
m_proj('Equidistant Cylindrical','lon',[-180 180],'lat',[-90 90]);
set(gcf,'paperunits','inches','papersize',[8 6*figure_height_scale], ...
        'paperposition',[0 0 8 6*figure_height_scale],'renderer','painters')
set(gca,'outerposition',[0 0 1 1],'position',[0.1 0.2 0.8 0.75])
colormap(cbsafemap(511,'rdbu'))
[c,h]=m_contourf(lon,lat,-fld,[-cv(1) inf],'linecolor','none');
set(findobj(h,'type','patch'),'facecolor','flat','cdata',-inf);
[c,hc]=m_contourf(lon,lat,fld,cv,'linecolor','none');
hnan=findobj(hc,'type','patch','cdata',nan);
m_contour(lon,lat,fld,cv,'linecolor','k')
hold on

xlabel('Longitude','fontsize',fontsize)
ylabel('Latitude','fontsize',fontsize)
m_coast('patch',[.7 .7 .7]);
m_grid
set(gca,'DataAspectRatioMode','auto')
hb=cbarfmb([-inf inf],cv,'vertical','nonlinear');
ylabel(hb,'g/kg','fontsize',fontsize);
pos=get(hb,'position');
pos(3)=pos(3)*cbar_width_scale;
set(hb,'position',pos,'fontsize',fontsize)
cdatamidlev([hc;hb],cv,'nonlinear');
caxis([cv(1) cv(end)])
caxis(hb,[cv(1) cv(end)])

set(hnan,'facecolor',[1 1 1])

title(['Salinity Climatology ' name_disp ' - woa13 at Depth ', num2str(depth_a(ilvl)),'m' ],'FontSize',12,'Fontweight','bold')

% Save plots
%eval(['print -depsc ' picpath '/' exp '/t_clim_diff_' num2str(depth_a(ilvl)),'m.eps'])


%Plot Differences of the Sensitivity Case with the Control Case (Figure(3))
% when available

%fld=sss_model_b-sss_modelc_b;
%fld(fld==0)=nan;

%ind=find(~(isnan(fld)|(lon>28&lon<42&lat>41&lat<47)| ...
%                      (lon>46&lon<56&lat>37&lat<51)));
%disp(sprintf('delta = %8.4f', ...
%             sum(fld(ind).*area_b(ind))/sum(area_b(ind))))
%disp(sprintf('rmse = %8.4f', ...
%             sqrt(sum((fld(ind).^2).*area_b(ind))/sum(area_b(ind)))))

% Contour intervals (change if desired)
%contour_factor=1/10;
%cv=[-4 -2 -1.2 -0.6 -.2 .2 0.6 1.2 2 4]*contour_factor;
%cvpos=[ .2 0.6 1.2 2 4]*contour_factor;
%cvneg=[-4 -2 -1.2 -0.6 -.2]*contour_factor;

%figure(3);clf;hold on;set(gcf, 'render','painters') 
%m_proj('Equidistant Cylindrical','lon',[-180 180],'lat',[-90 90]);
%set(gcf,'paperunits','inches','papersize',[8 6*figure_height_scale], ...
%        'paperposition',[0 0 8 6*figure_height_scale],'renderer','painters')
%set(gca,'outerposition',[0 0 1 1],'position',[0.1 0.2 0.8 0.75])
%colormap(cbsafemap(511,'rdbu'))
%[c,h]=m_contourf(lon,lat,-fld,[-cv(1) inf],'linecolor','none');
%set(findobj(h,'type','patch'),'facecolor','flat','cdata',-inf);
%[c,hc]=m_contourf(lon,lat,fld,cv,'linecolor','none');
%hnan=findobj(hc,'type','patch','cdata',nan);
%m_contour(lon,lat,fld,cv,'linecolor','k')
%hold on

%xlabel('Longitude','fontsize',fontsize)
%ylabel('Latitude','fontsize',fontsize)
%m_coast('patch',[.7 .7 .7]);
%m_grid
%set(gca,'DataAspectRatioMode','auto')
%hb=cbarfmb([-inf inf],cv,'vertical','nonlinear');
%ylabel(hb,'g/kg','fontsize',fontsize);
%pos=get(hb,'position');
%pos(3)=pos(3)*cbar_width_scale;
%set(hb,'position',pos,'fontsize',fontsize)
%cdatamidlev([hc;hb],cv,'nonlinear');
%caxis([cv(1) cv(end)])
%caxis(hb,[cv(1) cv(end)])

%set(hnan,'facecolor',[1 1 1])

%title(['Salinity Climatology ' name_disp ' - Control at Depth ', num2str(depth_a(ilvl)),'m' ],'FontSize',12,'Fontweight','bold') 

% Save plots
%eval(['print -depsc ' picpath '/' exp '/t_clim_diff_' num2str(depth_a(ilvl)),'m.eps'])

end
