%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	MICOM DIAGNOSTICS (Matlab package)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detelina Ivanova, detelina.ivanova@nersc.no
% 30/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plots Volume Transports Time Series from voltran annual time series netcdf files 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all;
% Grunch & Hexagon (Change the paths if local set-up)
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/mats
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/m_map1.4f
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/matlab_netcdf_5_0
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/eosben07
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/eoslib05
addpath /work-common/shared/bjerknes/diagnostics/Packages/MICOM_DIAG/matlab_tools/evenmat

addpath /fimm/home/nersc/detivan/Matlab

workpath=['/fimm/work/detivan/noresm/micom_diag/diag_new/'];

picpath=['/fimm/work/detivan/noresm/micom_diag/web_plots_new/'];

% Observational ranges of the volume transports 
% Plotted with black dash lines
obsmin=[1.8,0.33,0,-3,129,0.1,0,1.5,25,-2,4.15,-11.6,-5,-12.1,-15];
obsmax=[1.8,1.33,0,-4,145,0.1,0,1.9,35,-4,4.65,-15.7,-26,-1.5,-5];


% Reading the Model transports
% from netcdf files with volume transport time series 
% extracted from the original model output with nco operators

fyear=1;
lyear=200;
expid='N1850_f19_tn11_01_default';
%expid='N1850_f19_tn11_lsri_steering_gm';


fname=[workpath expid '/voltr_' expid '_hy.' num2str(fyear) '-' num2str(lyear)...
                  'y.nc']

time=ncread(fname,'time');
section=ncread(fname,'section');
voltr=ncread(fname,'voltr')
% Convert kg/s -> Sv
voltr=voltr/1035.*1e-6;           
                
  
time=tgrida(0.5,fyear,length(voltr));

figure('units','inches','position',[1 1 9 12])
x=[fyear,lyear];

cmap=hsv(15);

for nsec=1:14
  if nsec==5
   subplot(7,2,nsec)
   ph(nsec)=plot(time,voltr(15,:),'-','LineWidth',2,'Color',cmap(15,:));grid on; hold on
   ave=mean(voltr(15,:)); y=[ave,ave];
   line(x,y,'LineWidth',2,'Color',cmap(15,:));
   xlabel('year','FontSize',8) 
ylabel('Sv','FontSize',8) 
title(str_name_disp(section(:,15)'))
 set(gca,'Xlim',[0,200])
 else
   subplot(7,2,nsec)
   ph(nsec)=plot(time,voltr(nsec,:),'-','LineWidth',2,'Color',cmap(nsec,:));grid on; hold on
      ave=mean(voltr(nsec,:)); y=[ave,ave];
   line(x,y,'LineWidth',2,'Color',cmap(nsec,:));hold on
if obsmax(nsec) ~=0.
   y=[obsmax(nsec),obsmax(nsec)]
   line(x,y,'LineWidth',1.2,'LineStyle','--','Color','k');hold on
   y=[obsmin(nsec),obsmin(nsec)]
   line(x,y,'LineWidth',1.2,'LineStyle','--','Color','k');hold on
end
  xlabel('year','FontSize',8) 
ylabel('Sv','FontSize',8) 
 title(str_name_disp(section(:,nsec)'))
set(gca,'Xlim',[0,200])
  end
end
%print('volume_transports','-dpng','-r0')

% ACC (Drake passage) in separate figure
figure('units','inches','position',[10 9 10 5])
plot(time,voltr(5,:),'-','LineWidth',2,'Color',cmap(5,:));grid on; hold on
   ave=mean(voltr(5,:)); y=[ave,ave];
   line(x,y,'LineWidth',2,'Color',cmap(5,:));hold on
y=[obsmax(5),obsmax(5)]
   line(x,y,'LineWidth',1.2,'LineStyle','--','Color','k');hold on
y=[obsmin(5),obsmin(5)]
   line(x,y,'LineWidth',1.2,'LineStyle','--','Color','k');hold on

xlabel('year','FontSize',10) 
ylabel('Sv','FontSize',10) 
title(['Drake Passage Volume Transport, ',str_name_disp(expid)])
set(gca,'Xlim',[0,200])
%print('ACC_volume_transport','-dpng','-r0')

