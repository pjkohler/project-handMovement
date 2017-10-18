codeFolder = '/Users/kohler/code';
addpath(genpath(sprintf('%s/git/mrC',codeFolder)));
addpath(genpath(sprintf('%s/git/schlegel/matlab_lib',codeFolder)));

SUBJECTS_DIR = '/Volumes/Denali_4D2/kohler/fMRI_EXP/Handmovement/surfaces';
DATA_DIR = '/Volumes/Denali_4D2/kohler/fMRI_EXP/Handmovement/data';

subList = {'LS','AO','JZ'};
rightThresh = [3.09,2.86,2.99];
leftThresh = [3.25];

doLeft = false;
for s=1:length(subList)
    SUB_ID=subList{s};
    if strcmp(subList{s},'LS')
        doLeft = true;
    else
        doLeft = false;
    end
    % rois
    rhFile = sprintf('%s/%s/rh.wang_atlas_hand.nii.gz',DATA_DIR,SUB_ID);
    lhFile = sprintf('%s/%s/lh.wang_atlas_hand.nii.gz',DATA_DIR,SUB_ID);
    rhROI = NIfTI.Read(rhFile,'return','data');
    lhROI = NIfTI.Read(lhFile,'return','data');
    
    % right
    rightFile = sprintf('%s/%s/rightCombined.nii.gz',DATA_DIR,SUB_ID);
    rightMat = NIfTI.Read(rightFile,'return','data');
    rightMat = squeeze(rightMat(:,:,:,1,2)); % get z-scores
    
    % left
    if doLeft
        leftFile = sprintf('%s/%s/leftCombined.nii.gz',DATA_DIR,SUB_ID);
        leftMat = NIfTI.Read(leftFile,'return','data');
        leftMat = squeeze(leftMat(:,:,:,1,2)); % get z-scores
    else
    end

    for z=1:18
        percSig{s}(z,1,1) = length(find(lhROI == z & rightMat > rightThresh(s) ))/length(find(lhROI == z));
        percSig{s}(z,1,2) = length(find(rhROI == z & rightMat > rightThresh(s) ))/length(find(rhROI == z));
        meanZ{s}(z,1,1) = mean(rightMat(lhROI == z));
        meanZ{s}(z,1,2) = mean(rightMat(rhROI == z));
        if doLeft
            percSig{s}(z,2,1) = length(find(lhROI == z & leftMat > leftThresh(s) ))/length(find(lhROI == z));
            percSig{s}(z,2,2) = length(find(rhROI == z & leftMat > leftThresh(s) ))/length(find(rhROI == z));
            meanZ{s}(z,2,1) = mean(leftMat(lhROI == z));
            meanZ{s}(z,2,2) = mean(leftMat(rhROI == z));
        else
        end
    end
end

%% MAKE FIGURES
close all;
fSize(1) = 12;
fSize(2) = 18;
lWidth = 2;
includeROIs = {'V1' 'V2' 'V3' 'hV4' 'VO1' 'VO2','PHC1','PHC2',...
            'TO1','LO2','LO1','V3A','V3B','IPS0','IPS1','IPS2','IPS3','SPL1'};
gcaOpts = {'tickdir','out','ticklength',[0.02,0.02],'box','off','fontsize',fSize(1),'fontname','Helvetica','linewidth',lWidth};
meanFig = figure;
percFig = figure;

for t = 1:2
    for s=1:length(subList)
        for z = 1:2
            % PERC FIGURE OR MEAN FIGURE
            if t == 1
                figure(percFig)
                plotData = percSig{s}(:,:,z);
                yMin = -.1; yMax = .6; yUnit = .1;
                yLabel = 'significant voxels (%)';
            else
                figure(meanFig)
                plotData = meanZ{s}(:,:,z);
                yMin = -4; yMax = 4;  yUnit = 2;
                yLabel = 'average Z-score';
            end
            subplot(3,2,z+(s-1)*2);
            hold on;
            plot(plotData,'-o');
            ylim([yMin,yMax]); xlim([.5,18.5]);
            if z==1
                title(sprintf('%s: LH',subList{s}),'fontname','Helvetica','fontsize',fSize(2));
                if s == 1
                    legend('right hand','left hand','location','northwest')
                    legend boxoff
                elseif s == 2
                    ylabel(yLabel,'fontname','Helvetica','fontsize',fSize(2));
                else
                end
            else
                title(sprintf('%s: RH',subList{s}),'fontname','Helvetica','fontsize',fSize(2));
            end
            set(gca,gcaOpts{:},'xtick',1:18,'xticklabel',includeROIs,'ytick',yMin:yUnit:yMax);
            rotateXLabels(gca,45);
            hold off
        end
        set(gcf, 'units', 'centimeters'); % make figure size units centimeters
        oldPos = get(gcf, 'pos');
        newPos = oldPos;
        newPos(3) = 30;
        newPos(4) = 30;
        set(gcf, 'pos',newPos);
    end
end

export_fig('meanROI.pdf','-pdf','-transparent',meanFig);
export_fig('percROI.pdf','-pdf','-transparent',percFig);