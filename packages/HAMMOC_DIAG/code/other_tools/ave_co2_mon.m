clear all
close all

fillv = -999;

obsdir = '/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/Landschuetzer_2015/';

infile  = strcat(obsdir,'spco2_ETH_SOM-FFN_CDIAC_ETH30yr.nc');

lon   = ncread(infile,'lon');
lat   = ncread(infile,'lat');
time  = ncread(infile,'time');
spco2 = ncread(infile,'spco2_smoothed');
fgco2 = ncread(infile,'fgco2_smoothed');
spco2(spco2>1e10) = NaN;
fgco2(fgco2>1e10) = NaN;

nlon = length(lon); nlat = length(lat); nt = length(time);
nmon = 12; nyrs = nt/nmon;
dpm = [31 28 31 30 31 30 31 31 30 31 30 31];

spco2_monClim = zeros(nlon,nlat,12);
fgco2_monClim = zeros(nlon,nlat,12);
spco2_annClim = zeros(nlon,nlat);
fgco2_annClim = zeros(nlon,nlat);

for imon = 1:nmon
   if imon < 10
      cmon = strcat('0',num2str(imon));
   else
      cmon = num2str(imon);
   end
   for iyr = 1:nyrs
       spco2_monClim(:,:,imon) = spco2_monClim(:,:,imon) + spco2(:,:,imon+(iyr-1)*12)/nyrs;
       fgco2_monClim(:,:,imon) = fgco2_monClim(:,:,imon) + fgco2(:,:,imon+(iyr-1)*12)/nyrs;
   end
   spco2_annClim(:,:) = spco2_annClim(:,:) + dpm(imon)*spco2_monClim(:,:,imon)/sum(dpm);
   fgco2_annClim(:,:) = fgco2_annClim(:,:) + dpm(imon)*fgco2_monClim(:,:,imon)/sum(dpm);
end

spco2_monClim(isnan(spco2_monClim))=fillv;
fgco2_monClim(isnan(fgco2_monClim))=fillv;
outfile = strcat(obsdir,'spco2_ETH_MON_1982-2011_2.nc');

ncid=netcdf.create(outfile,'NC_CLOBBER');
x_dimid=netcdf.defDim(ncid,'lon',nlon);
y_dimid=netcdf.defDim(ncid,'lat',nlat);
t_dimid=netcdf.defDim(ncid,'time',12);

lat_varid=netcdf.defVar(ncid,'lat','NC_FLOAT',y_dimid);
netcdf.putAtt(ncid,lat_varid,'units','degrees_north');
netcdf.putAtt(ncid,lat_varid,'long_name','Latitude');

lon_varid=netcdf.defVar(ncid,'lon','NC_FLOAT',x_dimid);
netcdf.putAtt(ncid,lon_varid,'units','degrees_east');
netcdf.putAtt(ncid,lon_varid,'long_name','Longitude');

time_varid=netcdf.defVar(ncid,'time','NC_FLOAT',t_dimid);
netcdf.putAtt(ncid,time_varid,'units','months since 2000-01-15 00:00:00');
netcdf.putAtt(ncid,time_varid,'long_name','time');

var1_varid=netcdf.defVar(ncid,'spco2','NC_FLOAT',[x_dimid y_dimid t_dimid]);
netcdf.putAtt(ncid,var1_varid,'units','ppm');
netcdf.putAtt(ncid,var1_varid,'long_name','sea surface pCO2');
netcdf.putAtt(ncid,var1_varid,'missing_value',fillv);

var2_varid=netcdf.defVar(ncid,'fgco2','NC_FLOAT',[x_dimid y_dimid t_dimid]);
netcdf.putAtt(ncid,var2_varid,'units','mol m-2 yr-1');
netcdf.putAtt(ncid,var2_varid,'long_name','CO2 flux density');
netcdf.putAtt(ncid,var2_varid,'missing_value',fillv);
netcdf.endDef(ncid);

netcdf.putVar(ncid,lat_varid,single(lat));
netcdf.putVar(ncid,lon_varid,single(lon));
netcdf.putVar(ncid,time_varid,single(0:11));
netcdf.putVar(ncid,var1_varid,single(spco2_monClim));
netcdf.putVar(ncid,var2_varid,single(fgco2_monClim));

netcdf.close(ncid);
