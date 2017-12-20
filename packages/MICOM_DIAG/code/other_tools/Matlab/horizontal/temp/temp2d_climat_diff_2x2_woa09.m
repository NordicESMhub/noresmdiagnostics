%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MICOM DIAGNOSTICS (Matlab package)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detelina Ivanova, detelina.ivanova@nersc.no
% 03/03/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Regrids model horizontal Temperature fields on chosen depths (vertical levels)
% to 1x1deg LatLon (WOA09) grid and Plots:
% 1) Mean Model Climatology - Figure (1)
% 2) Differences with the Observations (WOA09) - Figure (2)
% 3) Differences with the Control Case (cntrl) - Figure (3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all;

% Grunch & Hexagon
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/mats
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4f
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/matlab_netcdf_5_0

%Remapping file with interpolation weights (map_file)
% Grunch & Hexagon
map_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/map_files/map_tnx2v1_to_dBM2x2_aave_20140127.nc';
map_file_woa09='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/map_files/map_woa09_to_dBM2x2_aave_20130731.nc';

% WOA09 Observations file (t_woa09_file)
% Grunch & Hexagon
t_woa09_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/obs_data/WOA09/t00an1.nc';

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

% Read WOA09 Observaions Climatology data gridded on 1x1 LatLon grid
ncid=netcdf.open(t_woa09_file,'NC_NOWRITE');
         nx_a_woa09=ncgetdim(t_woa09_file,'lon');
         ny_a_woa09=ncgetdim(t_woa09_file,'lat');
         nz_a_woa09=ncgetdim(t_woa09_file,'depth');
         lon_a_woa09=ncgetvar(t_woa09_file,'lon');
         lat_a_woa09=ncgetvar(t_woa09_file,'lat');
         depth_a_woa09=ncgetvar(t_woa09_file,'depth');

         iz=find(depth_a_woa09==lvl)

         varid=netcdf.inqVarID(ncid,'t');
         tmp=ncread(t_woa09_file,'t');
         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
         temp=nan*ones(size(tmp));
         ind=find(tmp~=fill_value);
         temp(ind)=tmp(ind);

         sst_woa09_a=temp(:,:,iz);
         t_src_woa09 = reshape(sst_woa09_a,[],1);
         mask_src_woa09=ones(size(t_src_woa09));
         mask_src_woa09(find(isnan(t_src_woa09)))=0;
         [nx_a_woa09 ny_a_woa09]=size(sst_woa09_a);

netcdf.close(ncid)


% Read time averaged Control Case model data

%ncid=netcdf.open(cntrlname,'NC_NOWRITE');
         
%         nx_a=ncgetdim(cntrlname,'x');
%         ny_a=ncgetdim(cntrlname,'y');
%         nz_a=ncgetdim(cntrlname,'depth');
%         depth_a=ncgetvar(cntrlname,'depth');

%         ilvl=find(depth_a==lvl)

%         varid=netcdf.inqVarID(ncid,'templvl');
%         tmp=ncread(cntrlname,'templvl');
%         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
%         templvlc=nan*ones(size(tmp));
%         ind=find(tmp~=fill_value);
%         templvlc(ind)=tmp(ind);

%         sst_modelc_a=templvlc(:,1:end-1,ilvl);

%         [nx_a ny_a]=size(sst_modelc_a);

%netcdf.close(ncid)

% Load time averaged Sensitivity Case model data
ncid=netcdf.open(fname,'NC_NOWRITE');
         nx_a=ncgetdim(fname,'x');
         ny_a=ncgetdim(fname,'y');
         nz_a=ncgetdim(fname,'depth');
         depth_a=ncgetvar(fname,'depth');

         ilvl=find(depth_a==lvl)

         varid=netcdf.inqVarID(ncid,'templvl');
         tmp=ncread(fname,'templvl');
         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
         templvl=nan*ones(size(tmp));
         ind=find(tmp~=fill_value);
         templvl(ind)=tmp(ind);

         sst_model_a=templvl(:,1:end-1,ilvl);

         t_src = reshape(sst_model_a,[],1);
         mask_src=ones(size(t_src));
         mask_src(find(isnan(t_src)))=0;
         [nx_a ny_a]=size(sst_model_a);

netcdf.close(ncid)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INTERPOLATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reinterpolate the WOA09 field (source grid: (nx_a_woa09,ny_a_woa09) to the 2x2 LatLon grid (destination grid: (nx_b, ny_b)) 
% Read regrid indexes and weights
  n_a=ncgetdim(map_file_woa09,'n_a');
  n_b=ncgetdim(map_file_woa09,'n_b');
  S=sparse(ncgetvar(map_file_woa09,'row'),ncgetvar(map_file_woa09,'col'), ...
           ncgetvar(map_file_woa09,'S'),n_b,n_a);
  dims=ncread(map_file_woa09,'dst_grid_dims');
  nx_b=dims(1); ny_b=dims(2);
 
  % Get destination area of interpolated data
  destarea=reshape(S*mask_src_woa09,nx_b,ny_b);

  % Regrid WOA09 data on to 2x2 grid
  sst_woa09_b=reshape(S*t_src_woa09,nx_b,ny_b)./destarea;

% Reinterpolate the model field (source grid: (nx_a,ny_a) to the 2x2 LatLon grid (destination grid: (nx_b, ny_b)) 
% Read regrid indexes and weights
  n_a=ncgetdim(map_file,'n_a');
  n_b=ncgetdim(map_file,'n_b');
  S=sparse(ncgetvar(map_file,'row'),ncgetvar(map_file,'col'), ...
           ncgetvar(map_file,'S'),n_b,n_a);

  % Get destination area of interpolated data
  destarea=reshape(S*mask_src,nx_b,ny_b);

  % Regrid model data on to 2x2 grid
  sst_model_b=reshape(S*t_src,nx_b,ny_b)./destarea;
%  sst_modelc_b=reshape(S*reshape(sst_modelc_a,[],1),nx_b,ny_b)./destarea;

%area_b=reshape(ncgetvar(map_file,'area_b'),nx_b,ny_b);

% Shifting the grid to center at 0W [180W 180E]; Original WOA09 grid is [0 360]
%lon_b=[(lon_b((nx_b/2+1):end)-360);lon_b(1:nx_b/2)];
sst_woa09_b=[sst_woa09_b((nx_b/2+1):end,:);sst_woa09_b(1:nx_b/2,:)];
sst_model_b=[sst_model_b((nx_b/2+1):end,:);sst_model_b(1:nx_b/2,:)];
%sst_modelc_b=[sst_modelc_b((nx_b/2+1):end,:);sst_modelc_b(1:nx_b/2,:)];

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
fld=sst_model_b;
fld(fld==0)=nan;

ind=find(~(isnan(fld)|(lon>28&lon<42&lat>41&lat<47)| ...
                      (lon>46&lon<56&lat>37&lat<51)));
disp(sprintf('delta = %8.4f', ...
             sum(fld(ind).*area_b(ind))/sum(area_b(ind))))
disp(sprintf('rmse = %8.4f', ...
             sqrt(sum((fld(ind).^2).*area_b(ind))/sum(area_b(ind)))))

% Contour Intervals 
cv=[0:2:28];

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
ylabel(hb,'^{\circ}C','fontsize',fontsize);
pos=get(hb,'position');
pos(3)=pos(3)*cbar_width_scale;
set(hb,'position',pos,'fontsize',fontsize)
cdatamidlev([hc;hb],cv,'nonlinear');
caxis([cv(1) cv(end)])
caxis(hb,[cv(1) cv(end)])
set(hnan,'facecolor',[1 1 1])

title(['Temperature Climatology ' name_disp '  at Depth ', num2str(depth_a(ilvl)),'m' ],'FontSize',12,'Fontweight','bold') 

% Save plot (uncomment when needed)
%eval(['print -depsc ' picpath '/' exp '/t_clim_' num2str(depth_a(ilvl)),'m.eps'])


% Plot the differences of the Sensitivity Case with WOA09 observations (Figure(2))
fld=sst_model_b-sst_woa09_b;
fld(fld==0)=nan;

ind=find(~(isnan(fld)|(lon>28&lon<42&lat>41&lat<47)| ...
                      (lon>46&lon<56&lat>37&lat<51)));
disp(sprintf('delta = %8.4f', ...
             sum(fld(ind).*area_b(ind))/sum(area_b(ind))))
disp(sprintf('rmse = %8.4f', ...
             sqrt(sum((fld(ind).^2).*area_b(ind))/sum(area_b(ind)))))

% Contour intervals (Change if desired)
contour_factor=10;
cv=[-.5 -.35 -.25 -.15 -.05 .05 .15 .25 .35 .5]*contour_factor;
cvpos=[.05 .15 .25 .35 .5]*contour_factor;
cvneg=[-.5 -.35 -.25 -.15 -.05]*contour_factor;

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
ylabel(hb,'^{\circ}C','fontsize',fontsize);
pos=get(hb,'position');
pos(3)=pos(3)*cbar_width_scale;
set(hb,'position',pos,'fontsize',fontsize)
cdatamidlev([hc;hb],cv,'nonlinear');
caxis([cv(1) cv(end)])
caxis(hb,[cv(1) cv(end)])

set(hnan,'facecolor',[1 1 1])

title(['Temperature Climatology ' name_disp ' - WOA09 at Depth ', num2str(depth_a(ilvl)),'m' ],'FontSize',12,'Fontweight','bold')

% Save plots
%eval(['print -depsc ' picpath '/' exp '/t_clim_diff_' num2str(depth_a(ilvl)),'m.eps'])


%Plot Differences of the Sensitivity Case with the Control Case (Figure(3))
% when available

%fld=sst_model_b-sst_modelc_b;
%fld(fld==0)=nan;

%ind=find(~(isnan(fld)|(lon>28&lon<42&lat>41&lat<47)| ...
%                      (lon>46&lon<56&lat>37&lat<51)));
%disp(sprintf('delta = %8.4f', ...
%             sum(fld(ind).*area_b(ind))/sum(area_b(ind))))
%disp(sprintf('rmse = %8.4f', ...
%             sqrt(sum((fld(ind).^2).*area_b(ind))/sum(area_b(ind)))))

% Contour intervals 
%contour_factor=10;
%cv=[-.5 -.35 -.25 -.15 -.05 .05 .15 .25 .35 .5]*contour_factor;
%cvpos=[.05 .15 .25 .35 .5]*contour_factor;
%cvneg=[-.5 -.35 -.25 -.15 -.05]*contour_factor;

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
%ylabel(hb,'^{\circ}C','fontsize',fontsize);
%pos=get(hb,'position');
%pos(3)=pos(3)*cbar_width_scale;
%set(hb,'position',pos,'fontsize',fontsize)
%cdatamidlev([hc;hb],cv,'nonlinear');
%caxis([cv(1) cv(end)])
%caxis(hb,[cv(1) cv(end)])

%set(hnan,'facecolor',[1 1 1])

%title(['Temperature Climatology ' name_disp ' - Control at Depth ', num2str(depth_a(ilvl)),'m' ],'FontSize',12,'Fontweight','bold') 

% Save plots
%eval(['print -depsc ' picpath '/' exp '/t_clim_diff_' num2str(depth_a(ilvl)),'m.eps'])

end
