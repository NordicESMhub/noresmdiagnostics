clear all
close all

% Regions:
% 1 - Pacific Ocean; 2 - Atlantic Ocean; 3 - Black Sea; 4 - Southern Ocean;
% 5 - Red Sea; 6- Arctic Ocean; 7 - Indian Ocean; 8 - Huson Bay; 9 - Mediterranean Sea
% 10 - Baltic Sea

% New regions
% 1-Arctic (>66N), 2-North Atlantic (18-66N), 3-North Pacific (18–66N), 4-Tropical Atlantic (18S–18N),
% 5-Tropical Pacific (18S–18N), 6-Tropical Indian (18S–25N), 7-mid latitude Southern Ocean (58S–18S),
% 8-high latitude Southern Ocean (>58S). 

% Read WOA lons and lats
infile = '/projects/NS2345K/noresm_diagnostics_dev/packages/MICOM_DIAG/obs_data/WOA13/1deg/woa13_decav_s00_01.nc';
lon  = ncread(infile,'lon');
lat  = ncread(infile,'lat');

nlon = length(lon); nlat = length(lat);

% Read mask file
mask_woa13_file='/projects/NS2345K/noresm_diagnostics_dev/packages/MICOM_DIAG/grid_files/1x1d/generic/region_mask_woa13_1x1.dat';
fid=fopen(mask_woa13_file,'r');
mask_woa13=fread(fid,[nlon,nlat],'float32');
fclose(fid);

mask_regions = mask_woa13;
mask_regions(mask_regions==3) = 0;
mask_regions(mask_regions==5) = 0;
mask_regions(mask_regions>7) = 0;
mask_regions(mask_regions>0) = 2;

for ilat = 1:nlat
for ilon = 1:nlon
   if mask_woa13(ilon,ilat) > 0
      if lat(ilat) > 66
         mask_regions(ilon,ilat) = 1;
      end
      if lat(ilat) > 18 && lat(ilat) < 66 && mask_woa13(ilon,ilat) == 2
         mask_regions(ilon,ilat) = 2;
      end
      if lat(ilat) > 18 && lat(ilat) < 66 && mask_woa13(ilon,ilat) == 1
         mask_regions(ilon,ilat) = 3;
      end
      if lat(ilat) > -18 && lat(ilat) < 18 && mask_woa13(ilon,ilat) == 2
         mask_regions(ilon,ilat) = 4;
      end
      if lat(ilat) > -18 && lat(ilat) < 18 && mask_woa13(ilon,ilat) == 1
         mask_regions(ilon,ilat) = 5;
      end
      if lat(ilat) > -18 && lat(ilat) < 25 && mask_woa13(ilon,ilat) == 7
         mask_regions(ilon,ilat) = 6;
      end
      if lat(ilat) > -58 && lat(ilat) < -18
         mask_regions(ilon,ilat) = 7;
      end
      if lat(ilat) < -58
         mask_regions(ilon,ilat) = 8;
      end
      if lat(ilat) > 25 && lat(ilat) < 40 && lon(ilon) > 40 && lon(ilon) < 65
         mask_regions(ilon,ilat) = 0;
      end
   end
end
end

figure;
contourf(lon,lat,transpose(mask_regions));
xlabel('Longitude');
ylabel('Latitude');
title('Regions');
set(gcf,'PaperPositionMode','auto');
print('regions','-dpng','-r150');


return

outdir = '/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/grid_files/1x1d/generic';

reg_name = {'ARC','NATL','NPAC','TATL','TPAC','IND','MSO','HSO'};
nreg = 8;

for ireg = 1:nreg
 mask = zeros(nlon,nlat);
 mask(mask_regions==ireg) = 1;
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



