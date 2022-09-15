macro "SkeletonizeTubulinEE [N]" {
	selectWindow("Tub");
	run("Duplicate...","title=TubulinCopy");
	run("Duplicate...","title=TubulinCopy2");
	selectWindow("TubulinCopy2");
	run("Smooth");
	run("Smooth");
	run("Smooth");
	run("Smooth");
	getStatistics(throw1, avgVal, throw2, maxVal, throw3, throw4);
	setThreshold(maxVal / 8, maxVal);
	run("Make Binary");
	run("Dilate");
	run("Dilate");
	run("Divide...", "value=255");
	imageCalculator("Multiply create", "TubulinCopy2","TubulinCopy");
	rename("TubulinCopy3");
	run("Duplicate...", "title=TubulinCopy4");
	selectWindow("TubulinCopy4");
	run("Smooth");
	run("Make Binary");	
	run("Erode");
	run("Dilate");
	run("Duplicate...", "title=TubulinCopy5");
	selectWindow("TubulinCopy5");
	run("Skeletonize (2D/3D)");
}