image_title = File.nameWithoutExtension;


Dialog.create("Difference of Gaussian");
Dialog.addMessage("Please specify your parameters.");


Dialog.addNumber("Small sigma", 2);
Dialog.addNumber("Large sigma", 5);

// One can add a Help button that opens a webpage
Dialog.addHelp("https://imagej.net/ij/macros/DialogDemo.txt");

// Finally show the GUI, once all parameters have been added
Dialog.show();

// Once the Dialog is OKed the rest of the code is executed
// ie one can recover the values in order of appearance 
small_sigma = Dialog.getNumber();
large_sigma = Dialog.getNumber();

run("Duplicate...", "title=small-sigma duplicate");
small_sigma_ID = getImageID();

run("Duplicate...", "title=large-sigma duplicate");
large_sigma_ID = getImageID();

selectImage(small_sigma_ID);
run("Gaussian Blur...", "sigma=" + small_sigma + " stack");

selectImage(large_sigma_ID);
run("Gaussian Blur...", "sigma=" + large_sigma + "  stack");

imageCalculator("Subtract create stack", "small-sigma","large-sigma");
rename(image_title + "_DoG_filtered")

selectImage(small_sigma_ID);
close();
selectImage(large_sigma_ID);
close();

resetMinAndMax;