%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           MICOM DIAGNOSTICS (Matlab package)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Contributed by Mats Bentsen 
% Modified by Detelina Ivanova, detelina.ivanova@nersc.no
% 24/03/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plots AMOC Time Series from extracted time series of MOC variables (netcdf files) 
% Creates and saves plot of  AMOC time series (choice of 4 plot options) for set of 3 experiments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all;

% Grunch & Hexagon (Change the paths if local set-up)
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/mats
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4f
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/matlab_netcdf_5_0
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/eosben07
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/eoslib05
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/evenmat

% Set a structure with experiments' information:
expr(1)=struct('name','N1850_f19_tn11_01_default', ...
               'name_disp','N1850\_Tf19\_tn11\_01\_default', ...
               'first_year',1, ...
               'last_year',200, ...
               'display_first_year',1, ...
               'filetype','hy', ...
               'linewidth',2, ...
               'color','k', ...
               'print',1, ...
               'path','/fimm/work/detivan/mnt/viljework/archive/N1850_f19_tn11_01_default/ocn/hist');
expr(2)=struct('name','N1850_f19_tn11_E16', ...
               'name_disp','N1850\_f19\_tn11\_E16', ...
               'first_year',1, ...
               'last_year',215, ...
               'display_first_year',1, ...
               'filetype','hy', ...
               'linewidth',1.2, ...
               'color','b', ...
               'print',1, ...
               'path','/fimm/work/detivan/mnt/viljework/archive/N1850_f19_tn11_E16/ocn/hist');
expr(3)=struct('name','N1850_f19_tn11_MLE1', ...
               'name_disp','N1850\_f19\_tn11\_MLE1', ...
               'first_year',1, ...
               'last_year',200, ...
               'display_first_year',1, ...
               'filetype','hm', ...
               'linewidth',1.2, ...
               'color','r', ...
               'print',1, ...
               'path','/fimm/work/detivan/mnt/viljework/archive/N1850_f19_tn11_MLE1/ocn/hist');



% Set the path to the processed results from this script. You need to create the directory in advance
workpath=['/fimm/work/detivan/noresm/micom_diag/diag_new/'];

% Set the path to the plots directory. You need to create the directory in advance
picpath=['/fimm/work/detivan/noresm/micom_diag/web_plots_new/'];

% Set the plotting mode:
% plot_mode=0: plot max. AMOC between 20N-60N, at 26.5N, and at 45.0N together
% plot_mode=1: plot max. AMOC between 20N-60N.
% plot_mode=2: plot max. AMOC at 26.5N.
% plot_mode=3: plot max. AMOC at 45.0N.
plot_mode=2

% Latitude interval for maximum AMOC search
lat1=20;
lat2=60;

legend_list=[];

% Reading & Extracting the AMOC time series

%for nexp=1:1
for nexp=1:length(expr)
clear amocmax amoc265 amoc450
fyear=expr(nexp).first_year;
lyear=expr(nexp).last_year;
expid=expr(nexp).name;
ftype=expr(nexp).filetype

% Filename of the amoc time series saved in previous run of this script
amocfile=[workpath expid '/' expid '.' ftype '_maxmoc_' num2str(fyear) '-' num2str(lyear) '.nc'];

if exist(amocfile)
              expr(nexp).amocmax=ncread(amocfile,'amocmax');
              expr(nexp).amoc265=ncread(amocfile,'amoc265');
              expr(nexp).amoc450=ncread(amocfile,'amoc450');
else
    
% File with extracted MOC variables
fname=[workpath expid '/moc_' expid '_' ftype '.' num2str(fyear) '-' num2str(lyear) 'y.nc']
              ncid=netcdf.open(fname,'NC_NOWRITE');

              varid=netcdf.inqVarID(ncid,'lat');
              lat=netcdf.getVar(ncid,varid);
                
              varid=netcdf.inqVarID(ncid,'time');
              time=netcdf.getVar(ncid,varid);
              time=time/365.;                  %Convert Days to Years
              time_long_name=ncgetatt(fname,'long_name','time');
              time_units=ncgetatt(fname,'units','time');
              time_calendar=ncgetatt(fname,'calendar','time');

              ind1=min(find(lat>=lat1));
              ind2=max(find(lat<=lat2));
              ind265=find(abs(lat-26.5)==min(abs(lat-26.5)),1);
              ind450=find(abs(lat-45.0)==min(abs(lat-45.0)),1);

              varid=netcdf.inqVarID(ncid,'mmflxd');
              mmflxd=netcdf.getVar(ncid,varid);
              fill_value=netcdf.getAtt(ncid,varid,'_FillValue');
              
              netcdf.close(ncid)
              
              mmflxd(find(mmflxd==fill_value))=nan;

              amocmax=nanmax(squeeze(nanmax(squeeze(mmflxd(ind1:ind2,:,1,:))*1e-9)));
              amoc265=nanmax(squeeze(mmflxd(ind265,:,1,:))*1e-9);
              amoc450=nanmax(squeeze(mmflxd(ind450,:,1,:))*1e-9);

              expr(nexp).amocmax=amocmax;
              expr(nexp).amoc265=amoc265;
              expr(nexp).amoc450=amoc450;

% Save the extracted time series of max AMOC, AMOC @ 26.5N and AMOC @ 45N
% Create netcdf file.
ncid=netcdf.create(amocfile,'NC_CLOBBER');

% Define dimensions.
time_dimid=netcdf.defDim(ncid,'time',netcdf.getConstant('NC_UNLIMITED'));

% Define variables and assign attributes
time_varid=netcdf.defVar(ncid,'time','float',time_dimid);
netcdf.putAtt(ncid,time_varid,'long_name',time_long_name);
netcdf.putAtt(ncid,time_varid,'units',time_units);
netcdf.putAtt(ncid,time_varid,'calendar',time_calendar);

amocmax_varid=netcdf.defVar(ncid,'amocmax','float',[time_dimid]);
netcdf.putAtt(ncid,amocmax_varid,'long_name','Maximum  Atlantic Meridional Overturning Circulation between 20N and 60N');
netcdf.putAtt(ncid,amocmax_varid,'units','Sv');

amoc265_varid=netcdf.defVar(ncid,'amoc265','float',[time_dimid]);
netcdf.putAtt(ncid,amoc265_varid,'long_name','Maximum  Atlantic Meridional Overturning Circulation at 26.5N');
netcdf.putAtt(ncid,amoc265_varid,'units','Sv');

amoc450_varid=netcdf.defVar(ncid,'amoc450','float',[time_dimid]);
netcdf.putAtt(ncid,amoc450_varid,'long_name','Maximum  Atlantic Meridional Overturning Circulation at 45N');
netcdf.putAtt(ncid,amoc450_varid,'units','Sv');

% Global attributes

% End definitions and leave define mode.
netcdf.endDef(ncid)

% Provide values for variables.
length(time)
for n=1:length(time)
  netcdf.putVar(ncid,time_varid,n-1,1,single(time(n)));
  netcdf.putVar(ncid,amocmax_varid, n-1,1,single(amocmax(n)));
  netcdf.putVar(ncid,amoc265_varid, n-1,1,single(amoc265(n)));
  netcdf.putVar(ncid,amoc450_varid, n-1,1,single(amoc450(n)));
end

% Close netcdf file
netcdf.close(ncid)

end

if ~isempty(expr(nexp).name_disp)
    legend_list(end+1)=nexp;
end

end

% Plotting the time series

figure
hold on
cmap=hsv(length(expr));
 

%for nexp=1:1
for nexp=1:length(expr)
      
  amocmax=expr(nexp).amocmax;
  amoc265=expr(nexp).amoc265;
  amoc450=expr(nexp).amoc450;
  ftype=expr(nexp).filetype;

  %When Monthly input - average to annual time series
  if (ftype=='hm')
  amocmax=mon2ann(amocmax);
  amoc265=mon2ann(amoc265);
  amoc450=mon2ann(amoc450);
  end
  
  iyf=expr(nexp).first_year;
  iyl=expr(nexp).last_year;
  time=iyf:1:iyl;
  amocmax_yr=amocmax(iyf:iyl);
  amoc265_yr=amoc265(iyf:iyl);
  amoc450_yr=amoc450(iyf:iyl);
    
  if     plot_mode==0
      ph(nexp)=plot(time,amocmax_yr(iyf:iyl), ...
                    '-','LineWidth',2,'Color',cmap(nexp,:));  %expr(nexp).color);
               plot(time,amoc265_yr(iyf:iyl), ...
                    '--','LineWidth',2,'Color',cmap(nexp,:)); %expr(nexp).color);
               plot(time,amoc450_yr(iyf:iyl), ...
                    ':','LineWidth',2,'Color',cmap(nexp,:));  %expr(nexp).color);
    elseif plot_mode==1
      ph(nexp)=plot(time,amocmax_yr(iyf:iyl), ...
                    '-','LineWidth',2,'Color',cmap(nexp,:));  %expr(nexp).color);
    elseif plot_mode==2
      ph(nexp)=plot(time,amoc265_yr(iyf:iyl), ...
                    '-','LineWidth',2,'Color',cmap(nexp,:));  %expr(nexp).color);
    elseif plot_mode==3
      ph(nexp)=plot(time,amoc450_yr(iyf:iyl), ...
                    '-','LineWidth',2,'Color',cmap(nexp,:));  %expr(nexp).color);
    end

end

if ~isempty(legend_list)
   h=legend(ph(legend_list),expr(legend_list).name_disp,'location','Best');
    set(h,'FontSize',8)
  legend boxoff
end

grid on
box on
axis tight
set(gca,'LineWidth',2,'FontSize',10) 
xlabel('year','FontSize',10) 
ylabel('Sv','FontSize',10) 

% Saving plots
if     plot_mode==0
  title([expr(nexp).name_disp ' Maximum Atlantic Meridional Overturning Circulation between\newline20N and 60N (solid line), at 26.5N (dashed line), and 45N (dotted line)'],'FontSize',12) 
  print(gcf,'-dpng','-r300',[picpath expr(nexp).name '/amoc_ts_ann_3exp_e16_e17_control.png'])
elseif plot_mode==1
  title('Maximum Atlantic Meridional Overturning Circulation between 20N and 60N','FontSize',12) 
  print(gcf,'-dpng','-r300',[picpath '/amoc_ts_20N-60N_ann_3exp_e16_e17_control.png'])
elseif plot_mode==2
  title('Maximum Atlantic Meridional Overturning Circulation at 26.5N','FontSize',12) 
  print(gcf,'-dpng','-r300',[picpath '/amoc_ts_26.5N_ann_3exp_e16_e17_control.png'])
elseif plot_mode==3
  title('Maximum Atlantic Meridional Overturning Circulation at 45N','FontSize',12) 
  print(gcf,'-dpng','-r300',[picpath '/amoc_ts_45N_ann_3exp_e16_e17_control.png'])
end


