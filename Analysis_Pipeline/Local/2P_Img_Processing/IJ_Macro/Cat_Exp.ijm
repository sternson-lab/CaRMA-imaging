path = File.openDialog("Select a Log File");
strLog = File.openAsString(path);
strLines=split(strLog,"\n");
nLineCount = lengthOf(strLines);
Cat_s = 0;
strFns ="";
setBatchMode(true);
for (nLine=0;nLine<nLineCount;nLine++)
{
	if(!startsWith(strLines[nLine],"#sav#:"))
	{
		open(strLines[nLine]);
		filename = getInfo("image.filename");
		print("Processing File: "+filename);
		strFns = strFns+ " image" + (nLine-Cat_s+1) + "=" + filename;
	}
	else
	{
		strSavFn=substring(strLines[nLine],6,lengthOf(strLines[nLine]));
		strFns = strFns+ " image" + (nLine-Cat_s+1) + "=[-- None --]";
		run("Concatenate...", "  title=[Concatenated Stacks]"+strFns);
		saveAs("Tiff", strSavFn);
		close();
		Cat_s = nLine+1;
		strFns = "";
	}
}
setBatchMode(false);