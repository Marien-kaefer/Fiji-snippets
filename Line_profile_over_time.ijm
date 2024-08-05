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
/*
 * 
INSTRUCTIONS: Open a time series image and navigate to the channel to be measured. Draw a line across the area where the line 
profiles are to be measured. Then click "Run" below. A table with the measured line profiles for each frame will be populated. 
 *
*/

// Ensure an image is open
if (nImages == 0) {
    print("No images are open.");
    exit();
}

// Get the number of slices in the time series
title = getTitle();
getDimensions(width, height, channels, slices, frames);

// Get pixel size and unit
getPixelSize(unit, pixelWidth, pixelHeight);
if (unit == "micron") {
    unit = "µm";  // Use the µ symbol for microns
}

// Initialize a table to store the line profiles for each time point
Table.create("Line_Profiles");

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

// Loop through each time point
for (t = 1; t <= frames; t++) {
    Stack.setFrame(t);
    // Get the intensity profile along the line
    profile = getProfile();
    profile_length = profile.length; 
    Table.setColumn("Frame_" + IJ.pad((t), 2), profile); // Store the profile in the table
}

