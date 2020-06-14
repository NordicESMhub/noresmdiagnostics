clear all
close all

% Create the mask for enso indices 3 and 3.4
index_type = '34';
gridtypes  = {'gx1v5','gx1v6','gx3v7','tnx0.083v1','tnx0.25v1','tnx0.25v3','tnx0.25v4','tnx1.5v1','tnx1v1','tnx1v2','tnx1v3','tnx1v4','tnx2v1'};

%ng = length(gridtypes);

ng = 1;
for ig = 1:ng
 gridtype = 'tnx1v1'; % gridtypes{ig};
 disp(gridtype)
 infile   = strcat('/projects/NS2345K/noresm_diagnostics_dev/MICOM_DIAG/grid_files/',gridtype,'/PlioMIP2/grid.nc');
 outfile  = strcat('/projects/NS2345K/noresm_diagnostics_dev/MICOM_DIAG/grid_files/',gridtype,'/PlioMIP2/mask_nino',index_type,'.nc');

 plon  = ncread(infile,'plon');
 plat  = ncread(infile,'plat');
 pmask = ncread(infile,'pmask');
 maskn = ncread(infile,'parea');

 nx = length(plon(:,1)); ny = length(plon(1,:));
 maskn(plat>5)=0;
 maskn(plat<-5)=0;
 if strcmp(index_type,'3')
   maskn(plon<-150)=0;
   maskn(plon>-90)=0;
 end
 if strcmp(index_type,'34')
   maskn(plon<-170)=0;
   maskn(plon>-120)=0;
 end
 maskn(pmask==0)=0;
 maskn=maskn/max(max(maskn));

 ncid=netcdf.create(outfile,'NC_CLOBBER');
 x_dimid=netcdf.defDim(ncid,'x',nx);
 y_dimid=netcdf.defDim(ncid,'y',ny);
 maskn_varid=netcdf.defVar(ncid,strcat('mask',index_type),'double',[x_dimid y_dimid]);
 netcdf.putAtt(ncid,maskn_varid,'long_name',strcat('Mask for Nino',index_type));
 netcdf.putAtt(ncid,maskn_varid,'units','unitless');
 netcdf.endDef(ncid);
 netcdf.putVar(ncid,maskn_varid,maskn);
 netcdf.close(ncid);
end
