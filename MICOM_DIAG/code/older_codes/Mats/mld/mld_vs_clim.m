mld_clim_file='/work-common/shared/noresm/micom/MLD/mld_DR003_c1m_reg2.0.nc';
map_file='/fimm/home/nersc/matsbn/matlab/regrid/maps/map_tnx1v4_to_dBM2x2_aave_20171016.nc';
mld_model_path='/fimm/work/matsbn/monthly_mean_mld/';
clim1=[0 750];
clim2=[-150 150];
clim3=[-100 100];
expid='NOIIA_T62_tn14_micomdev3_ref';fignum=1;
expid='NOIIA_T62_tn14_micomdev3_CE05';fignum=2;
expid='NOIIA_T62_tn14_micomdev3_CE1';fignum=3;
expid='NOIIA_T62_tn14_micomdev3_CE1_moment';fignum=4;
expid='NOIIA_T62_tn14_micomdev3_ncpl24_01';fignum=4;
expid='NOIIA_T62_tn14_micomdev3_ncpl24_02';fignum=4;
expid='NOIIA_T62_tn14_micomdev3_ncpl24_03';fignum=5;
expid='NOIIA_T62_tn14_micomdev3_ncpl24_04';fignum=5;
expid='NOIIA_T62_tn14_micomdev3_ncpl12_01';fignum=5;
month='mar';
%expid='NOIIA_T62_tn14_micomdev3_ref';fignum=5;
%expid='NOIIA_T62_tn14_micomdev3_CE05';fignum=6;
%expid='NOIIA_T62_tn14_micomdev3_CE1';fignum=7;
%expid='NOIIA_T62_tn14_micomdev3_CE1_moment';fignum=8;
%expid='NOIIA_T62_tn14_micomdev3_ncpl24_01';fignum=4;
%expid='NOIIA_T62_tn14_micomdev3_ncpl24_02';fignum=4;
%expid='NOIIA_T62_tn14_micomdev3_ncpl24_03';fignum=4;
%expid='NOIIA_T62_tn14_micomdev3_ncpl24_04';fignum=5;
%expid='NOIIA_T62_tn14_micomdev3_ncpl12_01';fignum=5;
%month='sep';

% Read climatological MLD
if     strcmp(month,'mar')
  mld_clim=ncgetvar(mld_clim_file,'mld',[1 1 3],[inf inf 1]);
elseif strcmp(month,'sep')
  mld_clim=ncgetvar(mld_clim_file,'mld',[1 1 9],[inf inf 1]);
else
  error('unknown month string')
end
ind_land=find(mld_clim>1e8);
mld_clim(find(mld_clim>1e8|mld_clim<0))=nan;

% Read regrid indexes and weights.
n_a=ncgetdim(map_file,'n_a');
n_b=ncgetdim(map_file,'n_b');
S=sparse(ncgetvar(map_file,'row'),ncgetvar(map_file,'col'), ...
         ncgetvar(map_file,'S'),n_b,n_a);

% Get dimensions, longitude and latitude of target grid.
dst_grid_dims=ncgetvar(map_file,'dst_grid_dims');
nx_b=dst_grid_dims(1);
ny_b=dst_grid_dims(2);
lonv_b=reshape(ncgetvar(map_file,'xv_b'),4,nx_b,ny_b);
latv_b=reshape(ncgetvar(map_file,'yv_b'),4,nx_b,ny_b);

% Get destination area of interpolated data.
destarea=reshape(S*ones(n_a,1),nx_b,ny_b);

% Read model MLD
mld_a=ncgetvar([mld_model_path expid '_mld003_' month '_33-62_mean.nc'],'mld');

% Regrid SST to target grid with normalizing by destination
% area of
% interpolated data.
mld_b=reshape(S*reshape(mld_a,[],1),nx_b,ny_b)./destarea;

figure(1);set(gcf,'renderer','painters');clf
colormap(cbsafemap(512,'RdYlBu'))
m_proj('Equidistant Cylindrical','lon',[-180 180],'lat',[-90 90]);
ind=find(~isnan(mld_clim));
h=m_patch2(lonv_b(:,ind),latv_b(:,ind),reshape(mld_clim(ind),1,[]));
set(h,'edgecolor','none')
h=m_patch2(lonv_b(:,ind_land),latv_b(:,ind_land),[.7 .7 .7]);
set(h,'edgecolor','none')
caxis(clim1);colorbar
m_grid
if     strcmp(month,'mar')
  title(['March MLD [m]'],'interpreter','none')
elseif strcmp(month,'sep')
  title(['September MLD [m]'],'interpreter','none')
else
  error('unknown month string')
end
eval(['print -dpng -r300 mld_clim_' month '.png'])

figure(2);set(gcf,'renderer','painters');clf
colormap(cbsafemap(512,'RdYlBu'))
m_proj('Equidistant Cylindrical','lon',[-180 180],'lat',[-90 90]);
ind=find(~isnan(mld_b));
h=m_patch2(lonv_b(:,ind),latv_b(:,ind),reshape(mld_b(ind),1,[]));
set(h,'edgecolor','none')
h=m_patch2(lonv_b(:,ind_land),latv_b(:,ind_land),[.7 .7 .7]);
set(h,'edgecolor','none')
caxis(clim1);colorbar
m_grid

figure(fignum);set(gcf,'renderer','painters');clf
colormap(cbsafemap(512,'RdBu'))
m_proj('Equidistant Cylindrical','lon',[-180 180],'lat',[-90 90]);
ind=find(~isnan(mld_b-mld_clim));
h=m_patch2(lonv_b(:,ind),latv_b(:,ind),reshape(mld_b(ind)-mld_clim(ind),1,[]));
set(h,'edgecolor','none')
h=m_patch2(lonv_b(:,ind_land),latv_b(:,ind_land),[.7 .7 .7]);
set(h,'edgecolor','none')
caxis(clim2);colorbar
m_grid
if     strcmp(month,'mar')
  title(['March MLD: ' expid ' - climatology [m]'],'interpreter','none')
elseif strcmp(month,'sep')
  title(['September MLD: ' expid ' - climatology [m]'],'interpreter','none')
else
  error('unknown month string')
end
eval(['print -dpng -r300 mld_' expid '-clim_' month '.png'])

figure(fignum);set(gcf,'renderer','painters');clf
colormap(cbsafemap(512,'RdBu'))
m_proj('Equidistant Cylindrical','lon',[-180 180],'lat',[-90 90]);
ind=find(~isnan(mld_b-mld_clim));
h=m_patch2(lonv_b(:,ind),latv_b(:,ind),reshape(100*(mld_b(ind)-mld_clim(ind))./mld_clim(ind),1,[]));
set(h,'edgecolor','none')
h=m_patch2(lonv_b(:,ind_land),latv_b(:,ind_land),[.7 .7 .7]);
set(h,'edgecolor','none')
caxis(clim3);colorbar
m_grid
if     strcmp(month,'mar')
  title(['March MLD: ' expid ' - climatology [%]'],'interpreter','none')
elseif strcmp(month,'sep')
  title(['September MLD: ' expid ' - climatology [%]'],'interpreter','none')
else
  error('unknown month string')
end
eval(['print -dpng -r300 mld_' expid '-clim_percent_' month '.png'])
