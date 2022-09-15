macro "BinarizeVesicles [B]" {
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
}