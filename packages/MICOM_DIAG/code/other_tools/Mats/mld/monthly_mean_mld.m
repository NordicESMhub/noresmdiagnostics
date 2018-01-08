expid='NOIIA_T62_tn14_micomdev3_ref';
expid='NOIIA_T62_tn14_micomdev3_CE1';
expid='NOIIA_T62_tn14_micomdev3_CE05';
expid='NOIIA_T62_tn14_micomdev3_CE1_moment';
expid='NOIIA_T62_tn14_micomdev3_ncpl24_01';
expid='NOIIA_T62_tn14_micomdev3_ncpl24_02';
expid='NOIIA_T62_tn14_micomdev3_ncpl24_03';
expid='NOIIA_T62_tn14_micomdev3_ncpl24_04';
expid='NOIIA_T62_tn14_micomdev3_ncpl12_01';
datesep='-';
grid_file='/work-common/shared/noresm/inputdata/ocn/micom/tnx1v4/20170601/grid.nc';
fyear=33;
lyear=62;
month=9;
sigjmp=0.03;
fill_value=-1e33;

prefix=['/fimm/work/matsbn/vilje-work/matsbn/noresm/' expid '/run/' expid '.micom.hm.'];
prefix=['/fimm/work/matsbn/vilje-work/matsbn/archive/' expid '/ocn/hist/' expid '.micom.hm.'];
outpath='/fimm/work/matsbn/monthly_mean_mld/';

month_str={'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'};

% Get dimensions and time attributes
sdate=sprintf('%4.4d%c%2.2d',fyear,datesep,month);
nx=ncgetdim([prefix sdate '.nc'],'x');
ny=ncgetdim([prefix sdate '.nc'],'y');
nz=ncgetdim([prefix sdate '.nc'],'sigma');
ny=ny-1;
time_long_name=ncgetatt([prefix sdate '.nc'],'long_name','time');
time_units=ncgetatt([prefix sdate '.nc'],'units','time');
time_calendar=ncgetatt([prefix sdate '.nc'],'calendar','time');

% Read grid information
plon=ncgetvar(grid_file,'plon');
plat=ncgetvar(grid_file,'plat');
parea=ncgetvar(grid_file,'parea');
pclon=ncgetvar(grid_file,'pclon');
pclat=ncgetvar(grid_file,'pclat');
plon=plon(:,1:end-1);
plat=plat(:,1:end-1);
parea=parea(:,1:end-1);
pclon=permute(pclon(:,1:end-1,:),[3 1 2]);
pclat=permute(pclat(:,1:end-1,:),[3 1 2]);

% Create netcdf file.
ncid=netcdf.create([outpath '/' expid '_mld003_' month_str{month} '_' num2str(fyear) '-' num2str(lyear) '.nc'],'NC_CLOBBER');

% Define dimensions.
ni_dimid=netcdf.defDim(ncid,'ni',nx);
nj_dimid=netcdf.defDim(ncid,'nj',ny);
time_dimid=netcdf.defDim(ncid,'time',netcdf.getConstant('NC_UNLIMITED'));
nvertices_dimid=netcdf.defDim(ncid,'nvertices',4);

% Define variables and assign attributes
time_varid=netcdf.defVar(ncid,'time','double',time_dimid);
netcdf.putAtt(ncid,time_varid,'long_name',time_long_name);
netcdf.putAtt(ncid,time_varid,'units',time_units);
netcdf.putAtt(ncid,time_varid,'calendar',time_calendar);

tlon_varid=netcdf.defVar(ncid,'TLON','double',[ni_dimid nj_dimid]);
netcdf.putAtt(ncid,tlon_varid,'long_name','T grid center longitude');
netcdf.putAtt(ncid,tlon_varid,'units','degrees_east');
netcdf.putAtt(ncid,tlon_varid,'bounds','lont_bounds');

tlat_varid=netcdf.defVar(ncid,'TLAT','double',[ni_dimid nj_dimid]);
netcdf.putAtt(ncid,tlat_varid,'long_name','T grid center latitude');
netcdf.putAtt(ncid,tlat_varid,'units','degrees_north');
netcdf.putAtt(ncid,tlat_varid,'bounds','latt_bounds');

tarea_varid=netcdf.defVar(ncid,'tarea','double',[ni_dimid nj_dimid]);
netcdf.putAtt(ncid,tarea_varid,'long_name','area of T grid cells');
netcdf.putAtt(ncid,tarea_varid,'units','m^2');
netcdf.putAtt(ncid,tarea_varid,'coordinates','TLON TLAT');

lont_bounds_varid=netcdf.defVar(ncid,'lont_bounds','double',[nvertices_dimid ni_dimid nj_dimid]);
netcdf.putAtt(ncid,lont_bounds_varid,'long_name','longitude boundaries of T cells');
netcdf.putAtt(ncid,lont_bounds_varid,'units','degrees_east');

latt_bounds_varid=netcdf.defVar(ncid,'latt_bounds','double',[nvertices_dimid ni_dimid nj_dimid]);
netcdf.putAtt(ncid,latt_bounds_varid,'long_name','latitude boundaries of T cells');
netcdf.putAtt(ncid,latt_bounds_varid,'units','degrees_north');

mld_varid=netcdf.defVar(ncid,'mld','float',[ni_dimid nj_dimid time_dimid]);
netcdf.putAtt(ncid,mld_varid,'long_name','mixed layer depth');
netcdf.putAtt(ncid,mld_varid,'units','m');
netcdf.putAtt(ncid,mld_varid,'_FillValue',single(fill_value));
netcdf.putAtt(ncid,mld_varid,'coordinates','TLON TLAT');
netcdf.putAtt(ncid,mld_varid,'cell_measures','area: tarea');
netcdf.putAtt(ncid,mld_varid,'comment','The shallowest depth with a potential density (referenced at the surface) difference from the surface of more than 0.03 kg m-3');

% Global attributes

% End definitions and leave define mode.
netcdf.endDef(ncid)

% Provide values for time invariant variables.
netcdf.putVar(ncid,tlon_varid,plon);
netcdf.putVar(ncid,tlat_varid,plat);
netcdf.putVar(ncid,tarea_varid,parea);
netcdf.putVar(ncid,lont_bounds_varid,pclon);
netcdf.putVar(ncid,latt_bounds_varid,pclat);

% Retrieve mixed layer depths and write to netcdf variables
z=zeros(nx,ny,nz+1);
n=0;
for year=fyear:lyear
  n=n+1;
  sdate=sprintf('%4.4d%c%2.2d',year,datesep,month);
  disp(sdate)
  temp=ncgetvar([prefix sdate '.nc'],'temp');
  saln=ncgetvar([prefix sdate '.nc'],'saln');
  dz=ncgetvar([prefix sdate '.nc'],'dz');
  time=ncgetvar([prefix sdate '.nc'],'time');
  temp=temp(:,1:end-1,:);
  saln=saln(:,1:end-1,:);
  dz=dz(:,1:end-1,:);
  for k=1:nz
    z(:,:,k+1)=z(:,:,k)+dz(:,:,k);
  end
  sig0=rho(0,temp,saln);
% sig0top=sum(sig0(:,:,1:2).*dz(:,:,1:2),3)./sum(dz(:,:,1:2),3);
  sig0top=sig0(:,:,1);
  for j=1:ny
    for i=1:nx
      if isnan(temp(i,j,1))
        mld(i,j)=nan;
      else
        sig0trg=sig0top(i,j)+sigjmp;
        k1=find(sig0(i,j,:)<sig0trg,1,'last');
        k2=find(sig0(i,j,:)>sig0trg,1,'first');
        if isempty(k2)
          mld(i,j)=z(i,j,k1+1);
        else
          mld(i,j)=((sig0(i,j,k2)-sig0trg)*(z(i,j,k1+1)+z(i,j,k1)) ...
                   +(sig0trg-sig0(i,j,k1))*(z(i,j,k2+1)+z(i,j,k2))) ...
                   /(2*(sig0(i,j,k2)-sig0(i,j,k1)));
        end
      end
    end
  end
  mld(isnan(mld))=fill_value;
  netcdf.putVar(ncid,time_varid,n-1,1,time);
  netcdf.putVar(ncid,mld_varid,[0 0 n-1],[nx ny 1],single(mld));
end


% Close netcdf file
netcdf.close(ncid)

