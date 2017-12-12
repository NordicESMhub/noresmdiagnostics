%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           MICOM DIAGNOSTICS (Matlab package)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Contributed by Mats Bentsen 
% Contact: Detelina Ivanova, detelina.ivanova@nersc.no
% 24/03/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plots and saves plot of the Meridional Overturning Circulation (MOC)
% for choice of region: 1 - Atlantic; 2 - Indo-Pacific; 3- Global
% for choice of vertical coordinates: 0 -isopycnal layers; 1 - depth levels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all;

% Grunch & Hexagon (Change if local set-up)
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/mats
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4f
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/matlab_netcdf_5_0
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/eosben07
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/eoslib05
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/evenmat

% Set name of the experiment
exp ='N1850_f19_tn11_01_default';

% Set time period (if included in the file name)
year1=1; year2=200;

% Set the path to the model output
diagpath=['/fimm/work/detivan/mnt/viljework/archive/' exp '/ocn/hist/'];

% Set the path to the processed results from this script. You need to create the directory in advance
workpath=['/fimm/work/detivan/noresm/micom_diag/diag_new/' exp '/'];

% Set the path to the plots directory. You need to create the directory in advance
picpath=['/fimm/work/detivan/noresm/micom_diag/web_plots_new/' exp '/'];

% Set the depth coodinates: 0 - isopycnal layers; 1 - depth levels
depth_coord = 1;

% Set the region: 1 - Atlantic; 2- Indo-Pacific; 3 - Global Ocean;
region = 1;


% Reading the time averaged model output
% fname - filename of the model output. Change if necessary.
fname = [workpath '/' exp '.micom.hy.'  num2str(year1) '_' num2str(year2) 'y.nc' ];

       ncid=netcdf.open(fname,'NC_NOWRITE');

       varid=netcdf.inqVarID(ncid,'lat');
       lat=netcdf.getVar(ncid,varid);
       varid=netcdf.inqVarID(ncid,'depth');
       depth=netcdf.getVar(ncid,varid);
       varid=netcdf.inqVarID(ncid,'region');
       region_name=netcdf.getVar(ncid,varid);

       varid=netcdf.inqVarID(ncid,'mmflxd');
       tmp=netcdf.getVar(ncid,varid);
       fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
       mmflxd=zeros(size(tmp));
       mmflxd_num=zeros(size(tmp));
       ind=find(tmp~=fill_value);
       mmflxd(ind)=tmp(ind);

       varid=netcdf.inqVarID(ncid,'mmflxl');
       tmp=netcdf.getVar(ncid,varid);
       fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
       mmflxl=zeros(size(tmp));
       mmflxl_num=zeros(size(tmp));
       ind=find(tmp~=fill_value);
       mmflxl(ind)=tmp(ind);

       netcdf.close(ncid)

if     region==1
  vDr = [-4:2:34];
  title_name='Atlantic';
  fname_prefix='atlantic';
elseif region==2
  vDr = [-36:4:36];
  title_name='Pacific-Indian';
  fname_prefix='pacific_indian';
elseif region==3
  vDr = [-36:4:36];
  title_name='Global';
  fname_prefix='global';
end
colormap('jet')

if depth_coord
  f=squeeze(mmflxd(:,:,region))*1e-9;
  [nx ny]=size(f);
  y=-depth;
  ylabel_text='Depth (m)';
  vctag='d';
else
  f=squeeze(mmflxl(:,:,region))*1e-9;
  [nx ny]=size(f);
  y=-(1:ny)';
  ylabel_text='Layer index';
  vctag='l';
end

mask=zeros(size(f));
f(f==0)=NaN;
ind=find(~isnan(f));
mask(ind)=1;
mask1=sum(mask,2);
i1=find(mask1>0,1,'first');
i2=find(mask1>0,1,'last');

mask(:,end)=1;
mask(end,:)=1;
ind=find(mask==0);
lat2=lat*ones(1,ny);
y2=ones(nx,1)*y';
maskx(1,:)=lat2(ind);masky(1,:)=y2(ind);
maskx(2,:)=lat2(ind+1);masky(2,:)=y2(ind+1);
maskx(3,:)=lat2(ind+nx+1);masky(3,:)=y2(ind+nx+1);
maskx(4,:)=lat2(ind+nx);masky(4,:)=y2(ind+nx);

%Plot
f=extrap(f);
f=max(min(vDr),f);
[c h]=contourf(lat,y,f',vDr);
h=patch(maskx,masky,'k');
set(h,'edgecolor','k')
set(gca,'xlim',[lat(i1) lat(i2)])
ecolorbar(vDr,'b','(Sv)',1/20);

xlabel('Latitude','FontSize',10)
ylabel(ylabel_text,'FontSize',10)

set(gca,'LineWidth',2,'FontSize',10) 
title([title_name ' MOC ' str_name_disp(exp) ' ' num2str(year1) '-'  ...
       num2str(year2) 'yr'], 'FontSize',12,'FontWeight','Bold') 

   % Save plot
%   print (gcf,'-dpng', '-r300', [picpath fname_prefix '_moc_' vctag '_' ...
%       num2str(year1) '_' num2str(year2) '.png'])

