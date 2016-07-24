MFTCarver

This is a simple tool to dump individual $MFT records. It scans the input for the signature on either each byte or on each sector/512 bytes. Input must be a file.

Syntax is:
MftCarver.exe /InputFile: /OutputPath: /RecordSize: /ScanAllBytes:

Examples
MftCarver.exe /InputFile:c:\slack.bin
MftCarver.exe /InputFile:c:\slack.bin /ScanAllBytes:1
MftCarver.exe /InputFile:c:\memdump.bin /RecordSize:1024
MftCarver.exe /InputFile:c:\unallocated.chunk /OutputPath:e:\temp /RecordSize:4096
MftCarver.exe /InputFile:c:\unallocated.chunk /OutputPath:e:\temp /RecordSize:4096 /ScanAllBytes:1

If no input file is given as parameter, a fileopen dialog is launched. Output will default to program directory if omitted. Output is split in 3, in addition to a log file. Example output may look like:
Carver_MFT_2015-02-14_21-46-54.log
Carver_MFT_2015-02-14_21-46-54.wfixups.MFT
Carver_MFT_2015-02-14_21-46-54.wofixups.MFT
Carver_MFT_2015-02-14_21-46-54.false.positives.MFT

If not mft record size is supplied as parameter, it will default to 1024 which is the most common one.

This tool is handy when you have no means of accessing a healthy $MFT. For instance a memory dump or damaged volume. The tool will by default first attempt to apply fixups, and if it fails it will retry by skipping fixups. Applying fixups here means verifying the update sequence array and applying it.

Memory dumps may contain numerous $MFT records and that can be easily extracted. When done, preferrably run mft2csv on the output file to decode the extracted $MFT records. Configuration of mft2csv on the 2 different output files:
For the .wofixups.MFT output configure "Broken $MFT" and "skip fixups".
For the .wfixups.MFT output configure "Broken $MFT".

It is advised to check the log file generated. There will be verbose information written. Especially the false positives and their offsets can be found here, in addition to the separate output file containing all false positives. For when parsing for records of size 1024, there may be false positives of records with size 4096. This size is unusual though.

The test of the record structure is rather comprehensive, and the output quality is excellently divided in 3.

Changelog:
v1.0.0.13: Added /ScanAllBytes as new parameter. Default is 0. If set, then scanning will be performed on every byte, instead of per sector (only works on images and files).
v1.0.0.12: Added OutputPath as parameter. Commandline syntax changes. Changed the output file names to be prefixed with Carver_MFT_
v1.0.0.11: Appended .MFT on the false positive output.
v1.0.0.10: Added limit on loop when evaluating record structure, due to possible infinite loops with damaged record structure.
v1.0.0.9: Added functionality for dumping flagged false positives into a separate file.
v1.0.0.8: Added support for splitting output in 2 for found records with and without fixups applied. Added logging.
v1.0.0.7: Fixed bug in sanity check. 
v1.0.0.6: Reverted to default scanning of every sector.
v1.0.0.5: Fixed bug in sanity check.
v1.0.0.4: Fixed performance bug.
v1.0.0.3: Added sanity check of the MFT record structure, to filter out false positives.
v1.0.0.2: Added support for configuring MFT record size to 4096 bytes.