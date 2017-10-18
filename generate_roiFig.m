codeFolder = '/Users/kohler/code';
addpath(genpath(sprintf('%s/git/mrC',codeFolder)));
addpath(genpath(sprintf('%s/git/schlegel/matlab_lib',codeFolder)));

SUBJECTS_DIR = '/Volumes/Denali_4D2/kohler/fMRI_EXP/Handmovement/surfaces';
DATA_DIR = '/Volumes/Denali_4D2/kohler/fMRI_EXP/Handmovement/data';
SUB_ID='LS';

badFile = sprintf('%s/%s/badCombined.nii.gz',DATA_DIR,SUB_ID);
goodFile = sprintf('%s/%s/goodCombined.nii.gz',DATA_DIR,SUB_ID);
rhFile = sprintf('%s/%s/rh.wang_atlas_hand.nii.gz',DATA_DIR,SUB_ID);
lhFile = sprintf('%s/%s/lh.wang_atlas_hand.nii.gz',DATA_DIR,SUB_ID);

badMat = NIfTI.Read(badFile,'return','data');
goodMat = NIfTI.Read(goodFile,'return','data');
badMat = squeeze(badMat(:,:,:,1,2)); % get z-scores
goodMat = squeeze(goodMat(:,:,:,1,2)); % get z-scores


rhROI = NIfTI.Read(rhFile,'return','data');
lhROI = NIfTI.Read(lhFile,'return','data');

for z=1:18
    percSig(z,1,1) = length(find(lhROI == z & goodMat > 3.25 ))/length(find(lhROI == z));
    percSig(z,2,1) = length(find(lhROI == z & badMat > 3.09 ))/length(find(lhROI == z));
    percSig(z,1,2) = length(find(rhROI == z & goodMat > 3.25 ))/length(find(rhROI == z));
    percSig(z,2,2) = length(find(rhROI == z & badMat > 3.09 ))/length(find(rhROI == z));
    meanZ(z,1,1) = mean(goodMat(lhROI == z));
    meanZ(z,2,1) = mean(badMat(lhROI == z));
    meanZ(z,1,2) = mean(goodMat(rhROI == z));
    meanZ(z,2,2) = mean(badMat(rhROI == z));
end

%% MAKE FIGURES
% PERC FIGURE
close all;
fSize = 12;
includeROIs = {'V1' 'V2' 'V3' 'hV4' 'VO1' 'VO2','PHC1','PHC2',...
            'TO1','LO2','LO1','V3A','V3B','IPS0','IPS1','IPS2','IPS3','SPL1'};
gcaOpts = {'tickdir','out','ticklength',[0.02,0.02],'box','off','fontsize',fSize,'fontname','Helvetica','linewidth',lWidth};
figure;
for z = 1:2
    subplot(1,2,z);
    hold on;
    plot(percSig(:,:,z),'-o');
    ylim([-.1,.6]); xlim([.5,18.5]);
    if z==1
        title('LH');
        legend('good','bad')
        legend boxoff
        ylabel('significant voxels (%)','fontname','Helvetica','fontsize',fSize);
    else
        title('RH');
    end
    set(gca,gcaOpts{:},'xtick',1:18,'xticklabel',includeROIs,'ytick',0:.1:.6);
    rotateXLabels(gca,45);
    hold off
end
set(gcf, 'units', 'centimeters'); % make figure size units centimeters
oldPos = get(gcf, 'pos');
newPos = oldPos;
newPos(3) = 30;
newPos(4) = 10;
set(gcf, 'pos',newPos);
figName = sprintf('percROI_%s',SUB_ID);
export_fig([figName,'.pdf'],'-pdf','-transparent',gcf);

% MEAN FIGURE
figure;
for z = 1:2
    subplot(1,2,z);
    hold on;
    plot(meanZ(:,:,z),'-o');
    ylim([-4,4]); xlim([.5,18.5]);
    if z==1
        title('LH');
        legend('good','bad')
        legend boxoff
        ylabel('average Z-score','fontname','Helvetica','fontsize',fSize);
    else
        title('RH');
    end
    set(gca,gcaOpts{:},'xtick',1:18,'xticklabel',includeROIs,'ytick',-4:2:4);
    rotateXLabels(gca,45);
    hold off
end
set(gcf, 'units', 'centimeters'); % make figure size units centimeters
oldPos = get(gcf, 'pos');
newPos = oldPos;
newPos(3) = 30;
newPos(4) = 10;
set(gcf, 'pos',newPos);
figName = sprintf('meanROI_%s',SUB_ID);
export_fig([figName,'.pdf'],'-pdf','-transparent',gcf);
