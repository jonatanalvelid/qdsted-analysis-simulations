macro "BinarizeVesicles [N]" {
	selectWindow("Tub");
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
}