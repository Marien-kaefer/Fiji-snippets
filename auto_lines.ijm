/*


												- Written by Marie Held [mheldb@liverpool.ac.uk] August 2024
												  Liverpool CCI (https://cci.liverpool.ac.uk/)
________________________________________________________________________________________________________________________

BSD 2-Clause License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
*
*/

run("Fresh Start");
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack display redirect=None decimal=3");

//get input parameters
#@ String(value="Please specify the file for processing.", visibility="MESSAGE") message
#@ File (label = "File for segmentation:", style = "open") inputFile
#@ Integer(label="EB1 channel:" , value = 1) channel_to_process
#@ String(label="Image to process:", choices={"Max. Intensity Projection","Single Focal Plane"}, style="radioButtonHorizontal") MIP_SFP_choice
#@ String(label="Apply median filter?", choices={"Yes","No"}, style="radioButtonHorizontal") median_filter_choice


file_path = File.getDirectory(inputFile);
input_image_title = File.getName(inputFile);
input_image_title_no_ext = File.getNameWithoutExtension(inputFile);



//run("Bio-Formats Windowless Importer", "open=[" + file_path + File.separator + input_image_title + "]");
run("Bio-Formats", "open=[" + file_path + File.separator + input_image_title + "]");

input_ID = getImageID();
getPixelSize(unit, pixelWidth, pixelHeight);
if (unit == "micron") {
    unit = "µm";  // Use the µ symbol for microns
}
getDimensions(width, height, channels, slices, frames);

run("Duplicate...", "duplicate channels=" + channel_to_process);
channel_of_interest_ID = getImageID();

if (MIP_SFP_choice == "Single Focal Plane" ) {
	waitForUser("Duplicate the z plane to analyse, then click [OK].");
	image_to_segment = getImageID();
	run("Duplicate...", " ");
	image_to_segment_duplicate = getImageID();
}
if (MIP_SFP_choice == "Max. Intensity Projection"){
	run("Z Project...", "projection=[Max Intensity]");
	image_to_segment = getImageID();
	run("Duplicate...", " ");
	image_to_segment_duplicate = getImageID();
}

selectImage(image_to_segment_duplicate);

run("Subtract Background...");
run("Enhance Contrast", "saturated=0.35");
if (median_filter_choice == "Yes") {
	run("Median..."); 
}

setTool("freehand");
waitForUser("Draw a region of interest within which to analyse, then click [OK]");

run("Find Maxima..."); 
run("Select None");
mask_ID = getImageID();

saveAs("TIFF", file_path + File.separator + input_image_title_no_ext + "_EB1_mask.tif");
selectImage(mask_ID);
run("Analyze Particles...");
roiManager("save", file_path + File.separator + input_image_title_no_ext + "_EB1_ROIs.zip");

ROI_count = roiManager("count");
//print("ROI count: " + ROI_count); 

for (i = 0; i < (ROI_count) ; i++) {
//for (i = 0; i < 10; i++) {
	roiManager("select", i);
	//print("Ellipse creation " + i); 

	// Measure the ROI to get the fit of the ellipse
	roiManager("measure");
	x = getResult("XM", i);
	y = getResult("YM", i);
	width = getResult("Major", i);
	height = getResult("Minor", i);
	angle = getResult("Angle", i);
	aspect_ratio = height / width;  	
	//print("Ellipse parameters: " + x + ", " + y + ", " + width + ", " + height + ", " + aspect_ratio); 
	
	// Calculate the endpoints of the major axis line
	angleRad = Math.toRadians(angle);
	halfWidth = width / 2;
	
	x1 = round((x + halfWidth * cos(angleRad))/pixelWidth);
	y1 = round((y - halfWidth * sin(angleRad))/pixelWidth);
	x2 = round((x - halfWidth * cos(angleRad))/pixelWidth);
	y2 = round((y + halfWidth * sin(angleRad))/pixelWidth);
	//print("Line parameters: " + x1 + ", " + y1 + ", " + x2 + ", " + y2); 
	
	// Draw the line along the major axis
	makeLine(x1, y1, x2, y2);
	roiManager("add");
	roiManager("select", (roiManager("count")-1));	
	roiManager("rename", "Line_" + IJ.pad((i), 3));
}

initial_ROIs = newArray(ROI_count-1);
for (i = 0; i < ROI_count; i++) {
	initial_ROIs[i] = i; 
}

//Array.print(initial_ROIs); 
roiManager("select", initial_ROIs);

roiManager("delete");
roiManager("deselect");
roiManager("save", file_path + File.separator + input_image_title_no_ext + "_EB1_lines.zip");
selectImage(image_to_segment);

//run("Clear Results");
//selectImage(input_ID);
//Stack.setChannel(channel_to_process);
Table.create(input_image_title_no_ext + "_Line_Profiles");
ROI_count = roiManager("count");

getDimensions(width, height, channels, slices, frames);
makeLine(0, 0, width, height);
profile = getProfile();
profile_length = profile.length; 
// Calculate the distance values
distances = newArray(profile_length);
totalDistance = 0;
for (i = 0; i < profile_length; i++) {
    distances[i] = totalDistance;
    totalDistance += pixelWidth;  // Increment total distance by pixel width
}
Table.setColumn("Distance", distances);


// loop through all rois
for (i = 0; i < (ROI_count); i++) {
		// get roi line profile and add to results table
		roiManager("select", i);
		//print("ROI number: " + i);
		profile = getProfile();
		//Array.print(profile); 
		Table.setColumn("Profile_" + IJ.pad((i), 3), profile);
}
//selectWindow(input_image_title_no_ext + "_Line_Profiles");
saveAs("Results", file_path + File.separator + input_image_title_no_ext + "_Line_Profiles.csv");
run("Clear Results");

selectWindow("Results"); 
roiManager("deselect");
run("Set Measurements...", "display redirect=None decimal=3");
roiManager("multi-measure");
saveAs("Results", file_path + File.separator + input_image_title_no_ext + "_Line_Measurements.csv");

waitForUser("Done!");