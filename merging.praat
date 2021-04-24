# Script merging two TextGrids
# Author: Eugen Klein, July 2014

form Enter directory and search string
	sentence Directory E:\ZAS\Praat_labeling\p1_dat_wav\list_a
	sentence Dirmerge E:\ZAS\Praat_labeling
endform

Create Strings as file list... fileList 'directory$'\*.TextGrid
numberFiles = Get number of strings

for fileNr from 1 to numberFiles
     select Strings fileList
     current_file$ = Get string... fileNr
     Read from file... 'directory$'\'current_file$'
     object_name$ = selected$ ("TextGrid")
     Read from file... 'dirmerge$'\add.TextGrid
     
     select TextGrid 'object_name$'
     plus TextGrid add
     Merge

     select TextGrid merged

     Write to text file... 'directory$'\'object_name$'.TextGrid
     select all
     minus Strings fileList
     Remove
endfor