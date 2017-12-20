clear expr ph

expr(1)=struct('name','NAER1850CNOC_f19_g16_03', ...
               'name_disp','CMIP5', ...
               'first_year',1, ...
               'last_year',200, ...
               'display_first_year',1, ...
               'add_to_expr',[], ...
               'color',cmu.colors('black'), ...
               'print',0, ...
               'grid_file','/hexagon/work/shared/noresm/inputdata/ocn/micom/gx1v6/20100629/grid.nc', ...
               'monthly_diagnostics',1,...
               'path','/fimm/work/matsbn/norstore-NS2345K/noresm/cases/NAER1850CNOC_f19_g16_03/ocn/hist');
expr(2)=struct('name','NBF1850_f19_tn11_SA_edsprs_02', ...
               'name_disp','BCCR fast', ...
               'first_year',1, ...
               'last_year',200, ...
               'display_first_year',1, ...
               'add_to_expr',[], ...
               'color',cmu.colors('pumpkin'), ...
               'print',0, ...
               'grid_file','/hexagon/work/shared/noresm/inputdata/ocn/micom/tnx1v1/20120120/grid.nc', ...
               'monthly_diagnostics',0,...
               'path','/fimm/work/matsbn/norstore-NS2345K/noresm/cases/NBF1850_f19_tn11_SA_edsprs_02/ocn/hist');
expr(3)=struct('name','N1850C5OL45OCL32_30mar2016_f19_tn11', ...
               'name_disp','NorESM\_c1.2-LM', ...
               'first_year',1, ...
               'last_year',200, ...
               'display_first_year',1, ...
               'add_to_expr',[], ...
               'color',cmu.colors('forest green (web)'), ...
               'print',0, ...
               'grid_file','/hexagon/work/shared/noresm/inputdata/ocn/micom/tnx1v1/20120120/grid.nc', ...
               'monthly_diagnostics',1,...
               'path','/fimm/work/matsbn/norstore-NS2345K/noresm/cases/N1850C5OL45OCL32_30mar2016_f19_tn11/ocn/hist');
expr(4)=struct('name','N1850C5OL45OCL32_01apr2016_f09_tn11', ...
               'name_disp','NorESM\_c1.2-MM', ...
               'first_year',1, ...
               'last_year',200, ...
               'display_first_year',1, ...
               'add_to_expr',[], ...
               'color',cmu.colors('red'), ...
               'print',0, ...
               'grid_file','/hexagon/work/shared/noresm/inputdata/ocn/micom/tnx1v1/20120120/grid.nc', ...
               'monthly_diagnostics',1,...
               'path','/fimm/work/matsbn/norstore-NS2345K/noresm/cases/N1850C5OL45OCL32_01apr2016_f09_tn11/ocn/hist');
expr(5)=struct('name','N1850C5OL45L32_f09_tn0251_T02', ...
               'name_disp','NorESM\_c1.2-MH', ...
               'first_year',1, ...
               'last_year',200, ...
               'display_first_year',1, ...
               'add_to_expr',[], ...
               'color',cmu.colors('blue'), ...
               'print',0, ...
               'grid_file','/hexagon/work/shared/noresm/inputdata/ocn/micom/tnx0.25v1/20130930/grid.nc', ...
               'monthly_diagnostics',1,...
               'path','/fimm/work/matsbn/norstore-NS2345K/noresm/cases/N1850C5OL45L32_f09_tn0251_T02/ocn/hist');
expr(6)=struct('name','N1850C5OL32_27may2016_f19_tn11', ...
               'name_disp','NorESM\_c1.2-LM with CLM4.0', ...
               'first_year',1, ...
               'last_year',200, ...
               'display_first_year',1, ...
               'add_to_expr',[], ...
               'color',cmu.colors('cyan'), ...
               'print',0, ...
               'grid_file','/hexagon/work/shared/noresm/inputdata/ocn/micom/tnx1v1/20120120/grid.nc', ...
               'monthly_diagnostics',1,...
               'path','/fimm/work/matsbn/hexagon-work/matsbn/archive/N1850C5OL32_27may2016_f19_tn11/ocn/hist');


mw=ones(1,12)/12;
mw=[31 28 31 30 31 30 31 31 30 31 30 31]/365;
picpath='/fimm/home/nersc/matsbn/NorClim/diag/pic/';
fontsize=12;
linewidth=2.0;

legend_list=[];

for nexp=1:length(expr)

  % Load stored time series data if available
  if exist(['saln_ts_' expr(nexp).name '.mat'])
    load(['saln_ts_' expr(nexp).name '.mat'])
  else
    year_list=[];
    saln=[];
  end

  % If stored time series data is continous in time and cover the
  % requested time period, skip reading data from disk
  if isempty(year_list)||any(diff(year_list)~=1)|| ...
     year_list(1)>expr(nexp).first_year||year_list(end)<expr(nexp).last_year

    % Try to complement the time series by reading and transforming data
    % from disk
    year_missing=[];
    years_added=0;
    grid_info_read=0;
    for year=expr(nexp).first_year:expr(nexp).last_year
      cyear=sprintf('%4.4d',year);
      if isempty(find(year_list==year))
        if expr(nexp).monthly_diagnostics
          if exist([expr(nexp).path '/' expr(nexp).name '.micom.hm.' ...
                    cyear '-01.nc'])
            complete_year=1;
            disp([expr(nexp).name ' ' cyear])
            for month=1:12
              cmonth=sprintf('%2.2d',month);
              fname=[expr(nexp).path '/' expr(nexp).name '.micom.hm.' ...
                     cyear '-' cmonth '.nc'];
              if exist(fname)

                if ~grid_info_read
                  ncid=netcdf.open(expr(nexp).grid_file,'NC_NOWRITE');
                  varid=netcdf.inqVarID(ncid,'parea');
                  area=netcdf.getVar(ncid,varid);
                  varid=netcdf.inqVarID(ncid,'pmask');
                  mask=netcdf.getVar(ncid,varid);
                  varid=netcdf.inqVarID(ncid,'plat');
                  lat=netcdf.getVar(ncid,varid);
                  varid=netcdf.inqVarID(ncid,'plon');
                  lon=netcdf.getVar(ncid,varid);
                  nreg=netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'nreg');
                  netcdf.close(ncid)

                  area(find(mask==0))=nan;
                  area_sum=nansum(area(:));

                  grid_info_read=1;
                end

                ncid=netcdf.open(fname,'NC_NOWRITE');
                varid=netcdf.inqVarID(ncid,'saln');
                tmp=netcdf.getVar(ncid,varid);
                scale_factor=netcdf.getAtt(ncid,varid,'scale_factor');
                add_offset=netcdf.getAtt(ncid,varid,'add_offset');
                fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
                saln3d=ones(size(tmp))*nan;
                ind=find(tmp~=fill_value);
                saln3d(ind)=double(tmp(ind))*scale_factor+add_offset;
                if nreg==2
                  saln3d(:,end,:)=nan;
                end
                varid=netcdf.inqVarID(ncid,'dp');
                tmp=netcdf.getVar(ncid,varid);
                scale_factor=netcdf.getAtt(ncid,varid,'scale_factor');
                add_offset=netcdf.getAtt(ncid,varid,'add_offset');
                fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
                dp3d=ones(size(tmp))*nan;
                ind=find(tmp~=fill_value);
                dp3d(ind)=double(tmp(ind))*scale_factor+add_offset;
                if nreg==2
                  dp3d(:,end,:)=nan;
                end
                netcdf.close(ncid)

                saln_tmp(month)=nansum(reshape(nansum(saln3d.*dp3d,3).*area,1,[]))/nansum(reshape(nansum(dp3d,3).*area,1,[]));

              else
                complete_year=0;
                break
              end
            end
            if complete_year
              years_added=1;
              year_list(end+1)=year;
              saln=[saln saln_tmp];
            else
              year_missing=[year_missing year];
            end
          else
            year_missing=[year_missing year];
          end
        else
          fname=[expr(nexp).path '/' expr(nexp).name '.micom.hy.' ...
                 cyear '.nc'];
          if exist(fname)
            disp([expr(nexp).name ' ' cyear])

            if ~grid_info_read
              ncid=netcdf.open(expr(nexp).grid_file,'NC_NOWRITE');
              varid=netcdf.inqVarID(ncid,'parea');
              area=netcdf.getVar(ncid,varid);
              varid=netcdf.inqVarID(ncid,'pmask');
              mask=netcdf.getVar(ncid,varid);
              varid=netcdf.inqVarID(ncid,'plat');
              lat=netcdf.getVar(ncid,varid);
              varid=netcdf.inqVarID(ncid,'plon');
              lon=netcdf.getVar(ncid,varid);
              nreg=netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'nreg');
              netcdf.close(ncid)

              area(find(mask==0))=nan;
              area_sum=nansum(area(:));

              grid_info_read=1;
            end

            ncid=netcdf.open(fname,'NC_NOWRITE');
            varid=netcdf.inqVarID(ncid,'saln');
            tmp=netcdf.getVar(ncid,varid);
            scale_factor=netcdf.getAtt(ncid,varid,'scale_factor');
            add_offset=netcdf.getAtt(ncid,varid,'add_offset');
            fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
            saln3d=ones(size(tmp))*nan;
            ind=find(tmp~=fill_value);
            saln3d(ind)=double(tmp(ind))*scale_factor+add_offset;
            if nreg==2
              saln3d(:,end,:)=nan;
            end
            varid=netcdf.inqVarID(ncid,'dp');
            tmp=netcdf.getVar(ncid,varid);
            scale_factor=netcdf.getAtt(ncid,varid,'scale_factor');
            add_offset=netcdf.getAtt(ncid,varid,'add_offset');
            fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
            dp3d=ones(size(tmp))*nan;
            ind=find(tmp~=fill_value);
            dp3d(ind)=double(tmp(ind))*scale_factor+add_offset;
            if nreg==2
              dp3d(:,end,:)=nan;
            end
            netcdf.close(ncid)

            saln_tmp=nansum(reshape(nansum(saln3d.*dp3d,3).*area,1,[]))/nansum(reshape(nansum(dp3d,3).*area,1,[]));

            saln_tmp=saln_tmp*ones(1,12);

            years_added=1;
            year_list(end+1)=year;
            saln=[saln saln_tmp];
          else
            year_missing=[year_missing year];
          end
        end
      end
    end

    if ~isempty(year_missing)
      disp([expr(nexp).name ': Could not find data for the years: ' ...
           num2str(year_missing)])
    end

    % If the time series has been extended, sort the series and store
    % the updated time series
    if years_added
      [year_list svind]=sort(year_list);
      smind=(ones(12,1)*(svind-1)*12)+(1:12)'*ones(1,length(svind));
      saln=reshape(saln(smind),1,[]);
      save(['saln_ts_' expr(nexp).name '.mat'], ...
           'year_list','saln')
    end

  end

  expr(nexp).year_list=year_list;
  expr(nexp).saln=saln;
  if ~isempty(expr(nexp).name_disp)&&isempty(expr(nexp).add_to_expr)
    legend_list(end+1)=nexp;
  end

end

% Combine time series if requested
for nexp=1:length(expr)
  nexpa=expr(nexp).add_to_expr;
  if ~isempty(nexpa) && ~isempty(expr(nexpa).year_list)
    year_list=expr(nexpa).year_list;
    saln=expr(nexpa).saln;
    ind=find(year_list>expr(nexpa).last_year,1,'first');
    if isempty(ind)
      year_list=[year_list expr(nexp).year_list];
      saln=[saln expr(nexp).saln];
    else
      year_list=[year_list(1:ind-1) expr(nexp).year_list];
      saln=[saln(1:(ind-1)*12) expr(nexp).saln];
    end
    [year_list svind]=sort(year_list);
    smind=(ones(12,1)*(svind-1)*12)+(1:12)'*ones(1,length(svind));
    saln=reshape(saln(smind),1,[]);
    expr(nexpa).year_list=year_list;
    expr(nexpa).saln=saln;
    expr(nexpa).first_year=min(expr(nexpa).first_year,expr(nexp).first_year);
    expr(nexpa).last_year=max(expr(nexpa).last_year,expr(nexp).last_year);
  end
end


% Plot the time series

%figure('visible','off')
clf
hold on

for nexp=1:length(expr)
  if isempty(expr(nexp).add_to_expr)
    year_list=expr(nexp).year_list;
    saln=expr(nexp).saln;

    saln_yr=mw*reshape(saln,12,[]);
    if strcmp(expr(nexp).name,'NAER1850CNOC_f19_g16_03')
      ind=find(year_list==100);
      if ~isempty(ind)
        saln_yr(ind)=.5*(saln_yr(ind-1)+saln_yr(ind+1));
      end
    end
    if strcmp(expr(nexp).name,'N1850C5OL45L32_f09_tn0251_T02')
      ind=find(year_list==33);
      if ~isempty(ind)
        saln_yr(ind)=.5*(saln_yr(ind-1)+saln_yr(ind+1));
      end
      ind=find(year_list==51);
      if ~isempty(ind)
        saln_yr(ind)=.5*(saln_yr(ind-1)+saln_yr(ind+1));
      end
      ind=find(year_list==39);
      if ~isempty(ind)
        saln_yr(ind)=.5*(saln_yr(ind-1)+saln_yr(ind+1));
      end
    end

    iyf=find(year_list>=expr(nexp).first_year,1);
    iyl=find(year_list<=expr(nexp).last_year,1,'last');
    year_list=year_list(iyf:iyl);
    saln_yr=saln_yr(iyf:iyl);
    year_discont=[diff(year_list)~=1 1];
    iyl=0;
    while iyl<length(year_list)
      iyf=iyl+1;
      iyl=iyl+find(year_discont(iyf:end)==1,1);
      time=expr(nexp).display_first_year-expr(nexp).first_year+ ...
           year_list(iyf:iyl);
      ph(nexp)=plot(time,saln_yr(iyf:iyl), ...
                    '-','LineWidth',linewidth,'Color',expr(nexp).color);
    end

  end
end


if ~isempty(legend_list)
  h=legend(ph(legend_list),expr(legend_list).name_disp,'location','Best');
  set(h,'FontSize',fontsize)
  legend boxoff
end
grid on
box on
axis tight
set(gca,'FontSize',fontsize) 
xlabel('year','FontSize',fontsize) 
ylabel('g/kg','FontSize',fontsize) 
title('Global mean salinity','FontSize',fontsize) 

% Print the time series

for nexp=length(expr):-1:1
  if expr(nexp).print
    if ~exist([picpath '/' expr(nexp).name])
      mkdir([picpath '/' expr(nexp).name])
    end
    print (gcf,'-dpng', '-r300', [picpath '/' expr(nexp).name '/saln_ts.png'])
    break
  end
end
