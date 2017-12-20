%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MICOM DIAGNOSTICS (Matlab package)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detelina Ivanova, detelina.ivanova@nersc.no
% 03/03/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Regrids model horizontal Temperature fields on chosen depths (vertical levels)
% to 1x1deg LatLon (woa13) grid and Plots:
% 1) Mean Model Climatology - Figure (1)
% 2) Differences with the Observations (woa13) - Figure (2)
% 3) Differences with the Control Case (cntrl) - Figure (3)
% Note: the Control Case should be on the same grid as the Sensitivity Case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all;

% Grunch & Hexagon
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/mats
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4f
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/matlab_netcdf_5_0

%Remapping file with interpolation weights (map_file)
% Grunch & Hexagon
map_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/map_files/map_tnx1v1_to_woa13x1_aave_20150303.nc';

% WOA13 Observations file (t_woa13_file)
% Grunch & Hexagon
t_woa13_file='/work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/obs_data/WOA13/1deg/woa13_decav_t00_01.nc';

%%%%%%%%%%%%%%%%%%% USER DEFINED PATHS and FILE NAMES %%%%%%%%%%%%%%

% Sensitivity Case name
exp='N1850_f19_tn11_E17';
name_disp='N1850\_f19\_tn11\_E17';
% Control Case name
cntrl='N1850_f19_tn11_01_default';

% Period of the Sensitivity Case
year1=1;
year2=200;
% Period of the Control Case
yearc1=1;
yearc2=200;

% Path of the input model field for the Sensitivity Case
workpath=['/fimm/work/detivan/noresm/micom_diag/diag_new/' exp '/'];

% Path of the input model field for the Control Case
cntrlpath=['/fimm/work/detivan/noresm/micom_diag/diag_new/' cntrl '/'];

% Path for the output plots
picpath=['/fimm/work/detivan/noresm/micom_diag/web_plots_new/'];
 
% Sensitivity Case filename 
fname = [workpath '/' exp '.micom.hy.'  num2str(year1) '_' num2str(year2) 'y.nc' ];

% Control Case filename
cntrlname=[cntrlpath '/' cntrl '.micom.hy.' num2str(yearc1) '_' num2str(yearc2) 'y.nc'];


% Depths to plot
lvls= [0, 100, 250, 500, 1000, 1500, 2000, 2500];  % [m]

%%%%%%%%%%%%%%%%%%%%%% Reading the input files %%%%%%%%%%%%%%%%%%%%%%%%
for il=1:length(lvls)
    lvl=lvls(il)

% Read woa13 Observaions Climatology data
ncid=netcdf.open(t_woa13_file,'NC_NOWRITE');
         nx_b=ncgetdim(t_woa13_file,'lon');
         ny_b=ncgetdim(t_woa13_file,'lat');
         nz_b=ncgetdim(t_woa13_file,'depth');
         lon_b=ncgetvar(t_woa13_file,'lon');
         lat_b=ncgetvar(t_woa13_file,'lat');
         depth_a=ncgetvar(t_woa13_file,'depth');

         iz=find(depth_a==lvl)

         varid=netcdf.inqVarID(ncid,'t_an');
         tmp=ncread(t_woa13_file,'t_an');
         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
         temp=nan*ones(size(tmp));
         ind=find(tmp~=fill_value);
         temp(ind)=tmp(ind);

         sst_woa13_b=temp(:,:,iz);

netcdf.close(ncid)


% Read time averaged Control Case model data

ncid=netcdf.open(cntrlname,'NC_NOWRITE');
         
         nx_a=ncgetdim(cntrlname,'x');
         ny_a=ncgetdim(cntrlname,'y');
         nz_a=ncgetdim(cntrlname,'depth');
         depth_a=ncgetvar(cntrlname,'depth');

         ilvl=find(depth_a==lvl)

         varid=netcdf.inqVarID(ncid,'templvl');
         tmp=ncread(cntrlname,'templvl');
         fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
         templvlc=nan*ones(size(tmp));
         ind=find(tmp~=fill_value);
         templvlc(ind)=tmp(ind);

         sst_modelc_a=templvlc(:,1:end-1,ilvl);

         [nx_a ny_a]=size(sst_modelc_a);

netcdf.close(ncid)

% Load time averaged Sensitivity Case model data
ncid=netcdf.open(fname,'NC_NOWRITE');

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


%%%%%%%%%%%%%%%%%%%%%%%%%%% Interpolation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the model field (source grid: (nx_a,ny_a))
% to the woa13 field (destination grid: (nx_b, ny_b)) 

% Read regrid indexes and weights
  n_a=ncgetdim(map_file,'n_a');
  n_b=ncgetdim(map_file,'n_b');
  S=sparse(ncgetvar(map_file,'row'),ncgetvar(map_file,'col'), ...
           ncgetvar(map_file,'S'),n_b,n_a);

  % Get destination area of interpolated data
  destarea=reshape(S*mask_src,nx_b,ny_b);

  % Regrid model data on to woa13 grid
  sst_model_b=reshape(S*t_src,nx_b,ny_b)./destarea;
  sst_modelc_b=reshape(S*reshape(sst_modelc_a,[],1),nx_b,ny_b)./destarea;

[nx_b ny_b]=size(sst_woa13_b);
area_b=reshape(ncgetvar(map_file,'area_b'),nx_b,ny_b);

lon=lon_b*ones(1,ny_b);
lat=ones(nx_b,1)*lat_b';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure_height_scale=0.65;
cbar_width_scale=1;
fontsize=12;

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


% Plot the differences of the Sensitivity Case with woa13 observations (Figure(2))
fld=sst_model_b-sst_woa13_b;
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

title(['Temperature Climatology ' name_disp ' - woa13 at Depth ', num2str(depth_a(ilvl)),'m' ],'FontSize',12,'Fontweight','bold')

% Save plots (uncomment when needed)
%eval(['print -depsc ' picpath '/' exp '/t_clim_diff_woa13_' num2str(depth_a(ilvl)),'m.eps'])


%Plot Differences of the Sensitivity Case with the Control Case (Figure(3))

fld=sst_model_b-sst_modelc_b;
fld(fld==0)=nan;

ind=find(~(isnan(fld)|(lon>28&lon<42&lat>41&lat<47)| ...
                      (lon>46&lon<56&lat>37&lat<51)));
disp(sprintf('delta = %8.4f', ...
             sum(fld(ind).*area_b(ind))/sum(area_b(ind))))
disp(sprintf('rmse = %8.4f', ...
             sqrt(sum((fld(ind).^2).*area_b(ind))/sum(area_b(ind)))))

% Contour intervals 
contour_factor=10;
cv=[-.5 -.35 -.25 -.15 -.05 .05 .15 .25 .35 .5]*contour_factor;
cvpos=[.05 .15 .25 .35 .5]*contour_factor;
cvneg=[-.5 -.35 -.25 -.15 -.05]*contour_factor;

figure(3);clf;hold on;set(gcf, 'render','painters') 
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

title(['Temperature Climatology ' name_disp ' - Control at Depth ', num2str(depth_a(ilvl)),'m' ],'FontSize',12,'Fontweight','bold') 

% Save plots
%eval(['print -depsc ' picpath '/' exp '/t_clim_diff_woa13_' num2str(depth_a(ilvl)),'m.eps'])

end
