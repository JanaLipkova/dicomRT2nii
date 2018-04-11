# Dicom-RT convertor to nii

The dicomRT plans are exported from the planning system as a folder containing:
 * medical volume, saved as series of dcm files
 * RT plan, saved as RS*.dcm


This script takes as input path the direcotry containingt the medical volume and the RT plan, extract the medical volume and all the treatment ROI and save them all as nifty files

## Usage:
folder DicomRTdata contains sample DicomRT data, to use it:
```
dicomRT2nii('DicomRTdata')
```
 :panda_face:

