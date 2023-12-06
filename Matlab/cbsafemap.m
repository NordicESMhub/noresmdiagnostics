function map=cbsafemap(n,scheme)
%CBSAFEMAP Returns colorblind safe colormap.
%
%   CBSAFEMAP(N,SCHEME) returns an Nx3 colormap. SCHEME can be one of the
%   following strings:
%
%       'RdYlBu'  Red-yellow-blue scheme (default)
%       'RdBu'    Red-blue scheme, symmetric about central white
%       'OrPu'    Orange-purple scheme, symmetric about central white
%       'BrBG'    Brown-blue/green scheme, symmetric about central white
%
%   If N is not specified, the size of the colormap is determined by the
%   current figure. If no figure exists, MATLAB creates one.

narginchk(0,2)
nargoutchk(0,1)

if nargin<2
  scheme='rdylbu';
end
if nargin<1
  n=size(get(gcf,'colormap'),1);
end

switch lower(scheme)
  case 'rdylbu'
    basemap=RdYlBuMap;
  case 'rdbu'
    basemap=RdBuMap;
  case 'orpu'
    basemap=OrPuMap;
  case 'brbg'
    basemap=BrBGMap;
  otherwise
    error(['Invalid scheme ' scheme])
end

map=interp1(linspace(0,1,size(basemap,1)),basemap,linspace(0,1,n));

function basemap=RdYlBuMap
basemap=[  49  36 100;
           69 117 180;
          116 173 209;
          171 217 233;
          224 243 248;
          255 255 191;
          254 224 144;
          253 174  97;
          244 109  67;
          215  48  39;
          103   0  38]/255;

function basemap=RdBuMap
basemap=[  5  48  97;
          33 102 172;
          67 147 195;
         146 197 222;
         209 229 240;
         255 255 255;
         253 219 199;
         244 165 130;
         214  96  77;
         178  24  43;
         103   0  31]/255;

function basemap=OrPuMap
basemap=[ 45   0  75; 
          84  39 136;
         128 115 172;
         178 171 210;
         216 218 235;
         247 247 247;
         254 224 182;
         253 184  99;
         224 130  20;
         179  88   6;
         127  59   8]/255;

function basemap=BrBGMap
basemap=[  0  60  48; 
           1 102  94;
          53 151 143;
         128 205 193;
         199 234 229;
         245 245 245;
         246 232 195;
         223 190 125;
         191 129  45;
         140  81  10;
          84  48   5]/255;
