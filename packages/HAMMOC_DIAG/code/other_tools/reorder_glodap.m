clear all
close all

fillv = -999;

infile   = strcat('/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/GLODAPv2/GLODAPv2.2016b.TAlk.nc');
outfile  = strcat('/projects/NS2345K/noresm_diagnostics_dev/packages/HAMOCC_DIAG/obs_data/GLODAPv2/GLODAPv2.2016b.TAlk_reordered2.nc');

lon     = ncread(infile,'lon');
lat     = ncread(infile,'lat');
depth   = ncread(infile,'Depth');
xvar_in = ncread(infile,'TAlk');

nlon = length(lon); nlat = length(lat); nz = length(depth);

xvar_in(isnan(xvar_in))=fillv;

lon_new = lon;
lon_new(1:nlon/2)=lon(161:340)-360;
lon_new(nlon/2+1:nlon/2+20)=lon(341:360)-360;
lon_new(nlon/2+21:nlon)=lon(1:160);

xvar_out = xvar_in;
xvar_out(1:nlon/2,:,:)=xvar_in(161:340,:,:);
xvar_out(nlon/2+1:nlon/2+20,:,:)=xvar_in(341:360,:,:);
xvar_out(nlon/2+21:nlon,:,:)=xvar_in(1:160,:,:);

ncid=netcdf.create(outfile,'NC_CLOBBER');
x_dimid=netcdf.defDim(ncid,'lon',nlon);
y_dimid=netcdf.defDim(ncid,'lat',nlat);
z_dimid=netcdf.defDim(ncid,'depth',nz);

lat_varid=netcdf.defVar(ncid,'lat','NC_FLOAT',y_dimid);
netcdf.putAtt(ncid,lat_varid,'units','degrees_north');
netcdf.putAtt(ncid,lat_varid,'long_name','Latitude');

lon_varid=netcdf.defVar(ncid,'lon','NC_FLOAT',x_dimid);
netcdf.putAtt(ncid,lon_varid,'units','degrees_east');
netcdf.putAtt(ncid,lon_varid,'long_name','Longitude');

depth_varid=netcdf.defVar(ncid,'depth','NC_FLOAT',z_dimid);
netcdf.putAtt(ncid,depth_varid,'units','m');
netcdf.putAtt(ncid,depth_varid,'positive','down');
netcdf.putAtt(ncid,depth_varid,'long_name','Depth below the surface');

var_varid=netcdf.defVar(ncid,'TAlk','NC_FLOAT',[x_dimid y_dimid z_dimid]);
netcdf.putAtt(ncid,var_varid,'units','micro-mol kg-1');
netcdf.putAtt(ncid,var_varid,'long_name','seawater alkalinity expressed as mole equivalent per unit mass');
netcdf.putAtt(ncid,var_varid,'missing_value',fillv);
netcdf.endDef(ncid);

netcdf.putVar(ncid,lat_varid,single(lat));
netcdf.putVar(ncid,lon_varid,single(lon_new));
netcdf.putVar(ncid,depth_varid,single(depth));
netcdf.putVar(ncid,var_varid,single(xvar_out));

netcdf.close(ncid);

