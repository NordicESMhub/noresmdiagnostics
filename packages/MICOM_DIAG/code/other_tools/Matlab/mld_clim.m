clear all
close all

fillv = -32768;

infile   = strcat('/projects/NS2345K/noresm_diagnostics_dev/MICOM_DIAG/obs_data/MLD/mld_DR003_c1m_reg2.0.nc');
outfile  = strcat('/projects/NS2345K/noresm_diagnostics_dev/MICOM_DIAG/obs_data/MLD/mld_clim_WOCE.nc');

lon  = ncread(infile,'lon');
lat  = ncread(infile,'lat');
time = ncread(infile,'time');
mld  = ncread(infile,'mld');

nlon = length(lon); nlat = length(lat); nt = length(time);
mld(mld<0)=fillv;
mld(mld>1e+08)=fillv;

lon_new = lon;
lon_new(1:nlon/2)=lon(nlon/2+1:nlon)-360;
lon_new(nlon/2+1:nlon)=lon(1:nlon/2);
mld_new = mld;
mld_new(1:nlon/2,:,:)=mld(nlon/2+1:nlon,:,:);
mld_new(nlon/2+1:nlon,:,:)=mld(1:nlon/2,:,:);

ncid=netcdf.create(outfile,'NC_CLOBBER');
x_dimid=netcdf.defDim(ncid,'lon',nlon);
y_dimid=netcdf.defDim(ncid,'lat',nlat);
t_dimid=netcdf.defDim(ncid,'time',nt);

lat_varid=netcdf.defVar(ncid,'lat','NC_FLOAT',y_dimid);
netcdf.putAtt(ncid,lat_varid,'units','degrees_N');
netcdf.putAtt(ncid,lat_varid,'long_name','Latitude');

lon_varid=netcdf.defVar(ncid,'lon','NC_FLOAT',x_dimid);
netcdf.putAtt(ncid,lon_varid,'units','degrees_W');
netcdf.putAtt(ncid,lon_varid,'long_name','Longitude');

time_varid=netcdf.defVar(ncid,'time','NC_INT',t_dimid);
netcdf.putAtt(ncid,time_varid,'units','days since 0001-01-01 12:00:00');
netcdf.putAtt(ncid,time_varid,'calendar','gregorian');

mld_varid=netcdf.defVar(ncid,'mld','NC_FLOAT',[x_dimid y_dimid t_dimid]);
netcdf.putAtt(ncid,mld_varid,'units','meters');
netcdf.putAtt(ncid,mld_varid,'long_name','mixed layer depth');
netcdf.putAtt(ncid,mld_varid,'missing_value',fillv);
%netcdf.putAtt(ncid,mld_varid,'FillValue',fillv);
netcdf.endDef(ncid);

netcdf.putVar(ncid,lat_varid,lat);
netcdf.putVar(ncid,lon_varid,lon_new);
netcdf.putVar(ncid,time_varid,time);
netcdf.putVar(ncid,mld_varid,mld_new);

netcdf.close(ncid);

