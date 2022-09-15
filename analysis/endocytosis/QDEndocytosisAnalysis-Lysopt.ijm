macro "QD endocytosis analysis [F12]" {
	////Text here is obsolete, automated for a whole directory now.
	//Before running, open three images in order; the original actin image, 
	//the original mitochondria image and the manually created binary mask
	//showing where the stripes are in the actin image. 
	//All three window/image/file titles should start with "Image_XXX", 
	//where XXX is a three digit ID number.
	//Mark any of these three images and start the script.

	tol = 255/4;
	noImages = 4;
	rectSize = 15;
	findMaximaAvgFactor = 1;
	findQDsAvgFactor = 1.3;
	
	saveDir = "D:\\Data analysis\\QD - Endocytosis\\Temp\\"
	dir = getDirectory("Choose the directory");
	
	filelist = getFileList(dir);
	Array.sort(filelist);
	filenamebase = "\\"+dir+"\\";
	
	showProgress(0, filelist.length/noImages)
	
	for(r=0;r<filelist.length/noImages;r++) {
		for(s=0;s<noImages;s++) {
			print(d2s(noImages*r+s,0));
			filepath = filenamebase+filelist[noImages*r+s];
			open(filepath);
			if(s==0) {
				getPixelSize(unit, pixelWidth, pixelHeight);
				getDimensions(width, height, channels, slices, frames);
				run("Options...", "iterations=1 count=1 black");
			} 
			run("Set Scale...", "distance=1 known="+pixelWidth+" pixel=1 unit=micron");
		}
		
		wait(1000);
		
		imnameor = getTitle();
		imname = substring(imnameor, 0, 8);
	
		//Taking the images and renaming them in a standard way.
		run("Images to Stack", "name=ImageStack title="+imname+" keep");
		noSlices = nSlices;
		if(noSlices==4) {
			run("Stack to Images");
			selectWindow("ImageStack-0001");
			rename("QDSTEDImage");
			selectWindow("ImageStack-0002");
			rename("QDSTEDOnlyImage");
			run("Smooth");
			selectWindow("ImageStack-0003");
			rename("TubulinSTEDImage");
			selectWindow("ImageStack-0004");
			rename("VesiclesSTEDImage");	
		} else {
			exit("You need four images to run the macro, all named with the initial substring XXXX. Opened in order; one actin image, one mitochondria image, one non-stripes binary mask and optionally one soma binary mask.");
		}

		//Starting the analysis by subtracting the QDSTEDonly from the QDSTED image.
		imageCalculator("Subtract create","QDSTEDImage","QDSTEDOnlyImage");
		rename("QDSTEDSubtractedImage");
		changeValues(-1000, 0, 0);

		//Continue by finding all maxima in the subtracted QDSTED image, with a very generous threshold.
		selectWindow("QDSTEDImage");
		run("Duplicate...", "title=QDSTEDImageSmooth");
		selectWindow("QDSTEDImage");
		run("Duplicate...", "title=QDSTEDImageRect");
		selectWindow("QDSTEDImageSmooth");
		run("Smooth");
		run("Smooth");
		run("Smooth");
		run("Smooth");
		run("Smooth");
		getStatistics(throw1, avgVal, throw2, throw5, throw3, throw4);
		run("Find Maxima...", "noise="+(avgVal * findMaximaAvgFactor)+" output=[Point Selection] exclude");
		getSelectionCoordinates(xCoor, yCoor);
		roiManager("reset");
		
		//Draw rectangles around each maxima, in the original QD STED image, and sum the values inside the ROIs.
		selectWindow("QDSTEDImageRect");
		getStatistics(throw1, avgVal, throw2, throw5, throw3, throw4);
		for (i=0;i<xCoor.length;i++) {
			makeRectangle(xCoor[i], yCoor[i], rectSize, rectSize);
			roiManager("add");
		}
		run("Set Measurements...", "integrated limit redirect=None decimal=3");
		roiManager("Measure");
		
		//Pick only the maxima where the sum inside the ROI is greater than the sum inside a rectangle with the average pixel value.
		lengthRes = nResults();
		rawIntDen = newArray(lengthRes);
		for(i=0;i<lengthRes;i++) {
			rawIntDen[i] = getResult("RawIntDen",i);
		}
		run("Clear Results");
		//Array.getStatistics(rawIntDen, throw1, maxSum, throw2, throw3);
		m=0;
		for(i=0;i<lengthRes;i++) {
			if (rawIntDen[i] > avgVal * rectSize * rectSize * findQDsAvgFactor) {
				setResult("x", m, xCoor[i]);
				setResult("y", m, yCoor[i]);
				setResult("RawIntDens", m, rawIntDen[i]);
				setResult("i", m, i);
				m++;
				updateResults();
			}
		}
		print("Number of maxima:");
		print(lengthRes);
		print("Number of detected QDs:");
		print(m);
		//Save QD positions in a text file.
		filenametxt=imname+"_QDPositions"+".txt";
		saveAs("results", saveDir+filenametxt);
		print("Saved QD positions...");
	
		//Save all the detected QD maxima
		run("Clear Results");
		for (i=0;i<xCoor.length;i++) {
			setResult("x", i, xCoor[i]);
			setResult("y", i, yCoor[i]);
		}
		filenametxt=imname+"_QDPositionsAll"+".txt";
		saveAs("results", saveDir+filenametxt);
		print("Saved all QD positions...");
		
		//Save subtracted QD image.
		selectWindow("QDSTEDSubtractedImage");
		filenametiff=imname+"_QDSubtractedImage"+".tif";
		saveAs("Tiff", saveDir+filenametiff);
		print("Saved subtracted QD image...");

		//Go on to the vesicles image and save a binary version of that, for further analysis in MATLAB.
		selectWindow("VesiclesSTEDImage");
		run("Duplicate...", "title=VesicleSTEDImage2");
		selectWindow("VesicleSTEDImage2");
		run("Smooth");
		run("Make Binary");
		run("Erode");
		run("Erode");
		run("Erode");
		run("Erode");
		run("Erode");
		run("Erode");
		run("Dilate");
		run("Dilate");
		run("Dilate");
		run("Erode");

		//Save binary vesicles image.
		selectWindow("VesicleSTEDImage2");
		filenametiff=imname+"_VesiclesBinaryImage"+".tif";
		saveAs("Tiff", saveDir+filenametiff);
		print("Saved binary vesicles image...");

		//Go on to the tubulin image and save a skeletonized version of that, for further analysis in MATLAB.
		selectWindow("TubulinSTEDImage");
		run("Duplicate...", "title=TubulinSTEDImage2");
		selectWindow("TubulinSTEDImage2");
		run("Smooth");
		run("Smooth");
		run("Make Binary");
		run("Erode");
		run("Dilate");
		run("Duplicate...", "title=TubulinSTEDImage3");
		selectWindow("TubulinSTEDImage3");
		run("Skeletonize (2D/3D)");

		//Save binarized tubulin image.
		selectWindow("TubulinSTEDImage2");
		filenametiff=imname+"_TubulinBinaryImage"+".tif";
		saveAs("Tiff", saveDir+filenametiff);
		print("Saved binarized tubulin image...");		

		//Save skeletonized tubulin image.
		selectWindow("TubulinSTEDImage3");
		filenametiff=imname+"_TubulinSkelImage"+".tif";
		saveAs("Tiff", saveDir+filenametiff);
		print("Saved skeletonized tubulin image...");		

		//Save all the original images also in the output folder. 
		//Save vesicles image.
		selectWindow("VesiclesSTEDImage");
		filenametiff=imname+"_VesiclesImage"+".tif";
		saveAs("Tiff", saveDir+filenametiff);
		print("Saved vesicles image...");
		
		//Save QD STED image.
		selectWindow("QDSTEDImage");
		filenametiff=imname+"_QDImage"+".tif";
		saveAs("Tiff", saveDir+filenametiff);
		print("Saved QD STED image...");
		
		//Save smoothed QD STED image.
		selectWindow("QDSTEDImageSmooth");
		filenametiff=imname+"_QDImageSmooth"+".tif";
		saveAs("Tiff", saveDir+filenametiff);
		print("Saved smoothed QD STED image...");
		
		//Save tubulin image.
		selectWindow("TubulinSTEDImage");
		filenametiff=imname+"_TubulinImage"+".tif";
		saveAs("Tiff", saveDir+filenametiff);
		print("Saved tubulin image...");
		
		//Save QD STEDonly image.
		selectWindow("QDSTEDOnlyImage");
		filenametiff=imname+"_QDSoImage"+".tif";
		saveAs("Tiff", saveDir+filenametiff);
		print("Saved QD STEDonly image...");

		//Save the pixel sizes.
		run("Clear Results");
		setResult("PxWidth",0,pixelWidth);
		setResult("PxLength",0,pixelHeight);
		filenametxt=imname+"_PixelSizes"+".txt";
		saveAs("results", saveDir+filenametxt);
	
		print("Finished!");
		showProgress(r, filelist.length/noImages);
		wait(1000);
		run("Close All");
		
	}

	// Save a last file with all the settings
	run("Clear Results");
	setResult("RectangleSize",0,rectSize);
	setResult("FindMaxAvgFactor",0,findMaximaAvgFactor);
	setResult("FindQDsAvgFactor",0,findQDsAvgFactor);
	filenametxt="AnalysisParameters"+".txt";
	saveAs("results", saveDir+filenametxt);
	
}