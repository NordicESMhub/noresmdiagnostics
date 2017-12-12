clear all
close all

% Create the mask for nino3.4
gridtype = 'tnx1v1';
infile   = strcat('/projects/NS2345K/noresm_diagnostics_dev/MICOM_DIAG/grid_files/',gridtype,'/PlioMIP2/grid.nc');
outfile  = strcat('/projects/NS2345K/noresm_diagnostics_dev/MICOM_DIAG/grid_files/',gridtype,'/PlioMIP2/mask_nino34.nc');

plon  = ncread(infile,'plon');
plat  = ncread(infile,'plat');
pmask = ncread(infile,'pmask');
maskn = ncread(infile,'parea');

nx = length(plon(:,1)); ny = length(plon(1,:));
maskn(plat>5)=0;
maskn(plat<-5)=0;
maskn(plon<-170)=0;
maskn(plon>-120)=0;
maskn(pmask==0)=0;
maskn=maskn/max(max(maskn));

ncid=netcdf.create(outfile,'NC_CLOBBER');
x_dimid=netcdf.defDim(ncid,'x',nx);
y_dimid=netcdf.defDim(ncid,'y',ny);
maskn_varid=netcdf.defVar(ncid,'nino_mask','double',[x_dimid y_dimid]);
netcdf.putAtt(ncid,maskn_varid,'long_name','Mask for nino3.4');                                                                                   
netcdf.putAtt(ncid,maskn_varid,'units','unitless');
netcdf.endDef(ncid);
netcdf.putVar(ncid,maskn_varid,maskn);
netcdf.close(ncid);
