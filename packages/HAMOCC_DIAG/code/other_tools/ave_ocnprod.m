clear all
close all

fillv = -999;

obsdir = '/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/OcnProd_MODIS/';

time_ave = {'annual'};
nfiles = length(time_ave);

for ifile = 1:nfiles
infile1  = strcat(obsdir,'cbpm.m.clim_',time_ave{ifile},'_2003-2012.nc');
infile2  = strcat(obsdir,'eppley.m.clim_',time_ave{ifile},'_2003-2012.nc');
infile3  = strcat(obsdir,'vgpm.m.clim_',time_ave{ifile},'_2003-2012.nc');
outfile  = strcat(obsdir,'ave.m.clim_',time_ave{ifile},'_2003-2012_2.nc');

lon      = ncread(infile1,'lon');
lat_tmp  = ncread(infile1,'lat');
xvar_in1 = ncread(infile1,'pp');
xvar_in2 = ncread(infile2,'pp');
xvar_in3 = ncread(infile3,'pp');

nlon = length(lon); nlat = length(lat_tmp);

xvar_in  = (xvar_in1+xvar_in2+xvar_in3)/3;

xvar_out = zeros(nlon,nlat);
lat      = zeros(nlat,1);

for ilat = 1:nlat
   klat = nlat + 1 - ilat;
   for ilon = 1:nlon
      xvar_out(ilon,ilat) = xvar_in(klat,ilon);
   end
   lat(ilat) = lat_tmp(klat);
end

xvar_out(isnan(xvar_out))=fillv;

ncid=netcdf.create(outfile,'NC_CLOBBER');
x_dimid=netcdf.defDim(ncid,'lon',nlon);
y_dimid=netcdf.defDim(ncid,'lat',nlat);

lat_varid=netcdf.defVar(ncid,'lat','NC_FLOAT',y_dimid);
netcdf.putAtt(ncid,lat_varid,'units','degrees_north');
netcdf.putAtt(ncid,lat_varid,'long_name','Latitude');

lon_varid=netcdf.defVar(ncid,'lon','NC_FLOAT',x_dimid);
netcdf.putAtt(ncid,lon_varid,'units','degrees_east');
netcdf.putAtt(ncid,lon_varid,'long_name','Longitude');

var_varid=netcdf.defVar(ncid,'pp','NC_FLOAT',[x_dimid y_dimid]);
netcdf.putAtt(ncid,var_varid,'units','mol C m-2 s-1');
netcdf.putAtt(ncid,var_varid,'long_name','primary productivity (average from three datasets)');
netcdf.putAtt(ncid,var_varid,'missing_value',fillv);
netcdf.endDef(ncid);

netcdf.putVar(ncid,lat_varid,single(lat));
netcdf.putVar(ncid,lon_varid,single(lon));
netcdf.putVar(ncid,var_varid,single(xvar_out));

netcdf.close(ncid);
end
