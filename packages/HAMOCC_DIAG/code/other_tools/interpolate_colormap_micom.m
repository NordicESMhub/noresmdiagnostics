clear all
close all

fid=fopen('blueyellowred2.rgb','r');
A=textscan(fid,'%f %f %f',-1);
fclose(fid);
cmap_in=cell2mat(A)
ncols_in=length(cmap_in(:,1))
ncols_out=20;
cmap_out=zeros(ncols_out,3);

cmap_out(1,:) = cmap_in(1,:);
cmap_out(2,:) = interp_col(cmap_in(1,:),cmap_in(2,:),0.33);
cmap_out(3,:) = interp_col(cmap_in(1,:),cmap_in(2,:),0.67);
cmap_out(4:17,:) = cmap_in(2:15,:);
cmap_out(18,:) = interp_col(cmap_in(15,:),cmap_in(16,:),0.33);
cmap_out(19,:) = interp_col(cmap_in(15,:),cmap_in(16,:),0.67);
cmap_out(20,:) = cmap_in(16,:);
round(cmap_out)

return

% Do some extra interpolation to arrive at 21 colors
cmap_tmp1 = zeros(2,3);
cmap_tmp2 = zeros(2,3);

% Replace cmap_out(5) with two colors:
cmap_tmp1(1,:) = interp_col(cmap_out(4,:),cmap_out(6,:),0.33);
cmap_tmp1(2,:) = interp_col(cmap_out(4,:),cmap_out(6,:),0.67);

% Replace cmap_out(18) with two colors:
cmap_tmp2(1,:) = interp_col(cmap_out(17,:),cmap_out(19,:),0.33);
cmap_tmp2(2,:) = interp_col(cmap_out(17,:),cmap_out(19,:),0.67);

cmap_out_tmp = cmap_out;
cmap_out(5:6,:) = cmap_tmp1(:,:);
cmap_out(7:18,:) = cmap_out_tmp(6:17,:);
cmap_out(19:20,:) = cmap_tmp2(:,:);
cmap_out(21,:) = cmap_out_tmp(19,:);
round(cmap_out)
