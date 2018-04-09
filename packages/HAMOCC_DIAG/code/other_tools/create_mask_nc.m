clear all
close all

% Regions:
% 1 - Pacific Ocean; 2 - Atlantic Ocean; 3 - Black Sea; 4 - Southern Ocean;
% 5 - Red Sea; 6- Arctic Ocean; 7 - Indian Ocean; 8 - Huson Bay; 9 - Mediterranean Sea
% 10 - Baltic Sea

% Read WOA lons and lats
infile = '/projects/NS2345K/noresm_diagnostics_dev/packages/MICOM_DIAG/obs_data/WOA13/1deg/woa13_decav_s00_01.nc';
lon  = ncread(infile,'lon');
lat  = ncread(infile,'lat');

nlon = length(lon); nlat = length(lat);

% Read mask file
mask_woa13_file='/projects/NS2345K/noresm_diagnostics_dev/packages/MICOM_DIAG/grid_files/region_mask_woa13_1x1.dat';
fid=fopen(mask_woa13_file,'r');
mask_woa13=fread(fid,[nlon,nlat],'float32');
fclose(fid);

outdir = '/projects/NS2345K/noresm_diagnostics_dev/packages/MICOM_DIAG/grid_files';

regions  = [1 2 4 7 0];
reg_name = {'pac','atl','so','ind','glb'};
nreg = length(regions);

for ireg = 1:nreg
 mask = zeros(nlon,nlat);
 creg = regions(ireg)
 if regions(ireg) == 0
   mask(mask_woa13>0) = 1;
 else
   mask(mask_woa13==creg) = 1;
 end
 outfile = strcat(outdir,'/region_mask_1x1_',reg_name{ireg},'.nc');
 ncid=netcdf.create(outfile,'NC_CLOBBER');
 lon_dimid=netcdf.defDim(ncid,'lon',nlon);
 lat_dimid=netcdf.defDim(ncid,'lat',nlat);

 lon_varid=netcdf.defVar(ncid,'lon','float',lon_dimid);
 netcdf.putAtt(ncid,lon_varid,'standard_name','longitude');
 netcdf.putAtt(ncid,lon_varid,'long_name','longitude');
 netcdf.putAtt(ncid,lon_varid,'units','degrees_east');
 netcdf.putAtt(ncid,lon_varid,'axis','X');

 lat_varid=netcdf.defVar(ncid,'lat','float',lat_dimid);
 netcdf.putAtt(ncid,lat_varid,'standard_name','latitude');
 netcdf.putAtt(ncid,lat_varid,'long_name','latitude');
 netcdf.putAtt(ncid,lat_varid,'units','degrees_north');
 netcdf.putAtt(ncid,lat_varid,'axis','Y');

 mask_varid=netcdf.defVar(ncid,'mask','double',[lon_dimid lat_dimid]);
 netcdf.putAtt(ncid,mask_varid,'long_name',strcat(reg_name{ireg},'_mask'));
 netcdf.putAtt(ncid,mask_varid,'units','unitless');

 netcdf.endDef(ncid);

 netcdf.putVar(ncid,lon_varid,lon);
 netcdf.putVar(ncid,lat_varid,lat);
 netcdf.putVar(ncid,mask_varid,mask);
 netcdf.close(ncid);
end



