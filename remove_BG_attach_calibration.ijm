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

//open file to be processed

title = getTitle(); 
filename_without_extension = File.nameWithoutExtension;
directory = File.directory;
run("Duplicate...", " ");
duplicate_title = getTitle(); 
run("Gaussian Blur...", "sigma=50"); //blur the duplicate to make fine details invisible and keep large, blurry background objects/uneven illumination only
imageCalculator("Subtract create 32-bit", title,duplicate_title); // subtract blurred image from original image
BG_subtracted_image = getTitle(); 

selectWindow(duplicate_title); 
close(); 

//initiate user interaction to calculate and attach calibration
selectWindow(title); 
waitForUser("Calibration measurement", "Please draw a straight line along the whole length of the scale bar. Then click [OK].");
run("Measure");
scale_bar_length_pixel = getResult("Length", 0); 
run("Clear Results");
close("Results"); 
selectWindow(title); 
close(); 

Dialog.create("Calibration");
Dialog.addNumber("Length of scale bar in nm", 500);
Dialog.show();

scale_bar_length_nm = Dialog.getNumber();

calibration = scale_bar_length_pixel / scale_bar_length_nm ;  // calculate calibration from measured scale bar length (pixel) and scale bar length printed on image
selectWindow(BG_subtracted_image);
setVoxelSize(calibration, calibration, 0, "nm");
//save final pre-processed image in same folder as original image 
saveAs("TIFF", directory + File.separator + filename_without_extension + "_BG-removed-calibrated.tif"); 
