/*


												- Written by Marie Held [mheldb@liverpool.ac.uk] March 2024
												  Liverpool CCI (https://cci.liverpool.ac.uk/)
________________________________________________________________________________________________________________________

BSD 2-Clause License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
*
*/

//close all open image, reset ROI manager, clear results
run("Fresh Start");

//get input parameters
#@ String(value="Please select the background subtracted, calibrated file and the ROI set", visibility="MESSAGE") message
#@ File (label = "Background subtracted, calibrated file:", style = "open") inputFile
#@ File (label = "Tidied instance mask:", style = "open") inputMask
#@ Integer(label="Number of layers per object to be created: " , value = 3) number_of_layers

//open input files, read directory
open(inputFile);
title = getTitle(); 
filename_without_extension = File.nameWithoutExtension;
directory = File.directory;
open(inputMask);
run("glasbey_on_dark");
mask_title = getTitle(); 
mask_filename_without_extension = File.nameWithoutExtension;
scale_factors = newArray(number_of_layers); 

//generate ROIs from instance mask
selectWindow(mask_title); 
run("LabelMap to ROI Manager (2D)");

number_of_ROIs = roiManager("count");
//print("Number of ROIs: " + number_of_ROIs); 

// rename ROIs to something sensible and save ROI set
for (k=0; k < number_of_ROIs; k++){
		roiManager("select", k);
		roiManager("Rename", "Object_" + IJ.pad((k+1), 3));
}
roiManager("Save", directory + File.separator + filename_without_extension + "_ROIs.zip"); 

// calculate scale factors from number of layers to be created
scale_factors = newArray(number_of_layers); 
for (i = 0; i < (number_of_layers); i++) {
	scale_factors[i] = (number_of_layers - i) / number_of_layers ; 
}
//Array.print(scale_factors);


// ------------------------- generate incrementally smaller ROI rings -------------------------
for (k=0; k < number_of_ROIs; k++){
	for (i = 1; i < (scale_factors.length) ; i++) {
		roiManager("select", k);
		//print("ROI index: " + k); 
		//print("i: " + i);
		roiManager("Rename", "Object_" + IJ.pad((k+1), 3) + "_0");
	 	run("Scale... ", "x="+ scale_factors[i] + " y="+ scale_factors[i] + " centered");
		roiManager("Add");	
		roiManager("select", (roiManager("Count")-1));
		roiManager("Rename", "Object_" + IJ.pad((k+1), 3) + "_" + i);
	}
}

for (k = 1; k < (number_of_ROIs + 1); k++) {
    for (i = 1; i < (scale_factors.length); i++) {
        if (i == 1) {
            roi_ori = "Object_" + IJ.pad((k), 3) + "_0";
            index_ori = RoiManager.getIndex(roi_ori);
            roi_first = "Object_" + IJ.pad((k), 3) + "_1";
            index_first = RoiManager.getIndex(roi_first);
            roiManager("select", newArray(index_ori, index_first));
            roiManager("XOR");
            roiManager("Add");
            roiManager("select", (roiManager("Count") - 1));
            roiManager("Rename", "Object_" + IJ.pad((k), 3) + "_ring_" + i);
        } else {
            roi_first = "Object_" + IJ.pad((k), 3) + "_" + (i - 1);
            index_first = RoiManager.getIndex(roi_first);
            roi_second = "Object_" + IJ.pad((k), 3) + "_" + i;
            index_second = RoiManager.getIndex(roi_second);
            roiManager("select", newArray(index_first, index_second));
            roiManager("XOR");
            roiManager("Add");
            roiManager("select", (roiManager("Count") - 1));
            roiManager("Rename", "Object_" + IJ.pad((k), 3) + "_ring_" + i);
        }
    }

    roi_centre = "Object_" + IJ.pad((k), 3) + "_" + (scale_factors.length - 1);
    index_centre = RoiManager.getIndex(roi_centre);
    roiManager("select", index_centre);
    roiManager("Rename", "Object_" + IJ.pad((k), 3) + "_ring_" + scale_factors.length);

    for (i = 1; i < (scale_factors.length); i++) {
        roi_name = "Object_" + IJ.pad((k), 3) + "_" + (i - 1);
        index_roi = RoiManager.getIndex(roi_name);
        roiManager("select", index_roi);
        roiManager("Delete");
    }
}
//save ROI set with layers
roiManager("Save", directory + File.separator + filename_without_extension + "layered_ROI.zip"); 

selectWindow(title); 
roiManager("Show All");
waitForUser("Done!");