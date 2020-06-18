# saintgene 2017
# save each arealist as a 3D ROI Mask

from java.io import File
from ini.trakem2.display import *
from java.util import List
from ij import IJ
from ij import WindowManager as WM
from ij.io import FileSaver
from ij.process import ImageConverter

#you need to open the TrakEM2 project, then run the script

#the directory to save the 3D ROI masks
savDir = "D:/Dropbox/Dropbox (HHMI)/PVH_Analysis/CaRMA_Wiki/Example_Data/ANM378231/ExVivo_InVivo_Reg/Reg/Reg_All_Planes/2p_ROIs/"

#the number of neurons to be exported
Label_Max = 99
 
ls = Display.getFront().getLayerSet()
als = ls.getZDisplayables(AreaList)

for al in als:
	al.setProperty("label",None)
	al.setVisible(False,True)

for i in range(1,Label_Max+1):
	NN = "N"+str(i)
	bFound = False
	for al in als:
		if NN == al.title:
			bFound = True
			al.setProperty("label",str(i))
			break
	if(not bFound):
		print(NN)
		print("miss")

File(savDir).mkdirs()

for al in als:
	if al.title.startswith('N'):
		print("processing: "+al.title)
		al.setVisible(True, True)
		al.exportAsLabels([al],None,1,0,int(ls.getDepth()),True,False,False)
		al.setVisible(False,True)
		imp = WM.getImage("Labels")
		ImageConverter(imp).convertToGray16()
		FileSaver(imp).saveAsTiff(savDir+al.title+".tif")
		imp.close()
		
print("done")