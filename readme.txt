MFTCarver

This is a simple tool to dump individual $MFT records. It scans the input for signatures in addition to record validations. Input must be a file.

Syntax is:
MftCarver.exe /InputFile: /OutputPath: /RecordSize:
Examples
MftCarver.exe /InputFile:c:\slack.bin
MftCarver.exe /InputFile:c:\slack.bin
MftCarver.exe /InputFile:c:\memdump.bin /RecordSize:1024
MftCarver.exe /InputFile:c:\unallocated.chunk /OutputPath:e:\temp /RecordSize:4096
MftCarver.exe /InputFile:c:\unallocated.chunk /OutputPath:e:\temp /RecordSize:4096
MftCarver.exe /InputFile:c:\slack.chunk /OutputPath:e:\temp /RecordSize:1024 /VerifyFragment:1 /OutFragmentName:MftFragments.bin /CleanUp:1

If no input file is given as parameter, a fileopen dialog is launched. Output will default to program directory if omitted. Output is split in 3, in addition to a log file. Example output may look like:
Carver_MFT_2015-02-14_21-46-54.log
Carver_MFT_2015-02-14_21-46-54.wfixups.MFT
Carver_MFT_2015-02-14_21-46-54.wofixups.MFT
Carver_MFT_2015-02-14_21-46-54.false.positives.MFT

For the last example the only file generated would be:
e:\temp\MftFragments.bin

If not mft record size is supplied as parameter, it will default to 1024 which is the most common one.

This tool is handy when you have no means of accessing a healthy $MFT. For instance a memory dump or damaged volume. The tool will by default first attempt to apply fixups, and if it fails it will retry by skipping fixups. Applying fixups here means verifying the update sequence array and applying it.

Memory dumps may contain numerous $MFT records and that can be easily extracted. When done, preferrably run mft2csv on the output file to decode the extracted $MFT records. Configuration of mft2csv on the 2 different output files:
For the .wofixups.MFT output configure "Broken $MFT" and "skip fixups".
For the .wfixups.MFT output configure "Broken $MFT".

Parsing with Mft2Csv on the output generated with /VerifyFragment:1 will require Mft2Csv to be run with these options set: "skip fixups" and "Broken $MFT".

It is advised to check the log file generated. There will be verbose information written. Especially the false positives and their offsets can be found here, in addition to the separate output file containing all false positives. For when parsing for records of size 1024, there may be false positives of records with size 4096. This size is unusual though.

The test of the record structure is rather comprehensive, and the output quality is excellently divided in 3.