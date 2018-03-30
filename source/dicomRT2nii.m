%============================================
% 
%   Dicom-RT convertor to nii 
%
%   Author: Jana Lipkova
%   NOTE: This function use libraries writen by outher people, see folder
%   lib for more details
%============================================
% Description:
%------------------
% The dicomRT plans are exported from the planning system as a folder
% containing:
% - medical volume, saved as series of dcm files
% - RT plan, saved as RS*.dcm
%
% This script takes as input path the direcotry containingt the medical
% volume and the RT plan, extract the medical volume and all the
% treatment ROI and save them all as nifty files
%
% Usage:
%-----------
% folder DicomRTdata contains sample DicomRT data, to use it:
% dicomRT2nii('DicomRTdata')


function dicomRT2nii(DICOMdir)

addpath('../lib/')
addpath('../lib/toolbox_matlab_nifti')
addpath('../lib/dicomrt2matlab')
addpath('../lib/dicm2nii')

% PART 1)
%------------
% i)   Create nifty folder if it doesn't exist
% ii)  Convert the dicom volume into nifty
% iii) Read in the nifty volume to use the same structure for the RT plans

% i) create nifty folder if it doesn't exist
NiiDir     = [DICOMdir(1:end),'_nifty/'];
NiiDirVol = [NiiDir,'Volume/'];
NiiDirROI  = [NiiDir,'ROI/'];


if( 7~=exist(NiiDir,'dir'))
    mkdir(NiiDir)
    sprintf('-------------------------------------------------------')
    sprintf('Folder %s does not exist, so I am creating it',NiiDir)
    
    if( 7~=exist(NiiDirVol,'dir'))
        mkdir(NiiDirVol)
    end;
    
    if( 7~=exist(NiiDirROI,'dir'))
        mkdir(NiiDirROI)
    end;
    
end;

% ii) Convert the dicom volume into nifty
type=1; % 1 nii.gz
dicm2nii(DICOMdir,NiiDirVol,type);
sprintf('Medical volume is saved as nifty to folder %s',NiiDirVol) 

% % iii) Read in the nifty volume to use the same structure for the RT plans
NiiFileName = dir([NiiDirVol,'*.nii.gz']);
dataNii = MRIread([NiiDirVol,NiiFileName.name]);


% PART 2
%--------------
% i) Get the name of the RT file
% ii) Convert the RT-Dicom to mat file
% iii) Extract the ROI from the mat file + save them as nifty

% i) Get the name of the RT file
RTfileTmp = dir([DICOMdir,'/RS*.dcm']);
RTfile    = [DICOMdir,'/',RTfileTmp.name];
sprintf('Reading the dicomRT with name: %s',RTfileTmp.name)

% ii) Extract RT-Dicoms -> save them into mat
dicomrt2matlab(RTfile,DICOMdir);


% iii) Read in the mat structure + extract ROI + save as nifty
RTmatFileName = [RTfile(1:end-3),'mat'];
data = load(RTmatFileName);
nROI = size(data.contours,2);
bCompress = 1; 
sprintf('Extracting ROI and saving as nifty to directory %s',NiiDirROI)

for i = 1:nROI
    
    % Get ROI name + remove empty spaces
    'creating ROI:'
    ROIname = data.contours(i).ROIName;
    ROIname = ROIname(find(~isspace(ROIname)))
    
    % Read segm. and convert from boolean to numeric
    segm = data.contours(i).Segmentation;
    segm = double(segm);
    
    % Rotate the segm to be compatible with the dcm volume
    segm = rotate90_3D(segm,1);
    segm = rotate90_3D(segm,1);
    segm = rotate90_3D(segm,1);

    % Write to nifty
    dataNii.vol = segm;
    MRIwrite(dataNii, [NiiDirROI,ROIname,'.nii.gz']);
end;

sprintf('-------------------- DONE -----------------------------')


