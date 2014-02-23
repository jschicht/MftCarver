MFTCarver

This is a simpel tool to dump individual $MFT records. It scans the input for the signature on each sector/512 bytes. Input can be a file or PhysicalDriveN.

Syntax is:
MFTCarver input output

Example
MFTCarver c:\memdump.bin C:\temp\MftExtractMem.bin
MFTCarver PhysicalDrive3 c:\temp\MftExtractDisk3.bin

If no input is given, a fileopen dialog is launched. If output is not given, it will be set as the same as input, but with an .MFT extension.

This tool is handy when you have no means of accessing a healthy $MFT. For instance a memory dump or damaged volume.

Memory dumps contains a lot of $MFT records and can be easily extracted. When done, preferrably run mft2csv on the output file to decode the extracted $MFT records. For memory dumps configure mft2csv to use "Skip Fixups" and "Broken $MFT".