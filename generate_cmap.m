codeFolder = '/Users/kohler/code';
addpath(genpath([codeFolder,'/git/mrC']));
cBrewer = load('colorBrewer.mat');
colors = cBrewer.rgb20([1:14,17:end],:);
%colors = cat(1,colors(1:2:end,:),colors(2:2:end,:));
%colors = cat(1,[1,1,1],colors);
colors = flip(colors);
colors(:,4) = 0:(length(colors)-1);
%tempC = colors(3,:);
%colors(3,:) = colors(6,:);
%colors(6,:) = tempC;
%

%fid = fopen('cmap_new.txt','w');
%for z = 1:size(colors,1);
%    fprintf(fid,'%.02f %.02f %.02f %.0f\n',colors(z,1),colors(z,2),colors(z,3),colors(z,4));
%end
%fclose(fid);

projectFolder = '/Volumes/Denali_4D2/kohler/fMRI_EXP/HandmovementLS/data';
colorFile = sprintf('%s/handROImap.txt',projectFolder);

dlmwrite(colorFile,colors,'delimiter','\t','precision',3);

%system('MakeColorMap -fn handROImap.txt > handROI.1D.cmap');