there are 3 variables in file tbFISH_All_Loc_v6b_clean.mat.

tbFISH_All: the table of raw FISH signals.
tbFISH_All_NormANM: the table of FISH signals normalized within each animal.
tbFISH_All_NormLoc: the table of FISH signals normalized within each anatomical position.

Each of these tables includes 41 variables as described below.
ANMID: the animal ID from which animal the neuron was imaged. value: 1 or 2 
SliceID: the slice ID indicating where the neuron is. value: 1-6. 1/2: aPVH; 3/4: mPVH; 5/6 pPVH
NID: the neuron ID in all segmentated cells in the brain slices.
Volume: the volume of the neuron. Unit: voxels.
Position: the position of neuron center in the images in [X, Y, Z] order. Unit: pixel
xxx_V, xxx_M and xxx_S are the voxels, mean intensity and total intensity of FISH signal of gene xxx.


