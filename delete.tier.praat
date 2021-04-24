# Script delete tiers from TextGrid
# Author: Eugen Klein, Dezember 2014

form Enter directory and search string
	sentence Directory E:\ZAS\Praat_labeling\p1_dat_wav\list_a
endform

Create Strings as file list... fileList 'directory$'\*.TextGrid
numberFiles = Get number of strings

for fileNr from 1 to numberFiles
     select Strings fileList
     current_file$ = Get string... fileNr
     Read from file... 'directory$'\'current_file$'
     object_name$ = selected$ ("TextGrid")
     select TextGrid 'object_name$'
     tierNr = Get number of tiers
	 numberInter = Get number of intervals... tierNr
	 
	 for interNr from 1 to numberInter
		
		oldLab$ = Get label of interval... tierNr interNr
		
		if oldLab$ = "xxx"
			select TextGrid 'object_name$'
			Set interval text... tierNr interNr
			Write to text file... 'directory$'\'object_name$'.TextGrid
		endif
			
     select all
     minus Strings fileList
     Remove
endfor
