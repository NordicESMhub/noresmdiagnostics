clear all
close all

% Create a nice 19 color red-blue (9 red, 9 blue, 1 white) colorbap
red_blue = zeros(9,1);
blue_blue = zeros(9,1);
green_blue = zeros(9,1);
red_blue(4:9) = 30:30:180;
green_blue = 0:25:200;
blue_blue(1) = 140;
blue_blue(2) = 185;
blue_blue(3) = 225;
blue_blue(4:9) = 255;

blue_red = zeros(9,1);
red_red = zeros(9,1);
green_red = zeros(9,1);
blue_red(1:6) = 180:-30:30;
green_red = 200:-25:0;
red_red(9) = 140;
red_red(8) = 185;
red_red(7) = 225;
red_red(1:6) = 255;

cmap_br = zeros(19,3);
cmap_br(1:9,1) = red_blue;
cmap_br(1:9,2) = green_blue;
cmap_br(1:9,3) = blue_blue;
cmap_br(10,:) = [255 255 255];
cmap_br(11:19,1) = red_red;
cmap_br(11:19,2) = green_red;
cmap_br(11:19,3) = blue_red;
cmap_br



