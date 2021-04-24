# Script for labeling non-empty interval tiers with words from a list
# Author: Eugen Klein, July 2014

form Enter directory and search string
	sentence Dirfile E:\ZAS\Praat_labeling\p1_dat_wav\list_a
	sentence Dirword E:\ZAS\Praat_labeling
	sentence WordList list_a
	integer Tier_(tierIndex) 2 
endform

wordIndex = 0

Create Strings as file list... fileList 'dirfile$'\*.TextGrid
numberFiles = Get number of strings

Read Strings from raw text file... 'dirword$'\'wordList$'.txt
numberWords = Get number of strings

for fileNr from 1 to numberFiles
	select Strings fileList
	fileName$ = Get string... fileNr
	Read from file... 'dirfile$'\'fileName$'
	currentFile$ = selected$("TextGrid")
	select TextGrid 'currentFile$'
	numberInter = Get number of intervals... tier
	#echo "Number of intervals " 'numberInter'
	emptyInter = 0
	#printline "Number of empty intervals " 'emptyInter'
	#pause
	
	for interNr from 1 to numberInter
		#printline "Interval number " 'interNr'
		#pause
		oldLab$ = Get label of interval... tier interNr
		if oldLab$ = "xxx"
			emptyInter = emptyInter + 1
			#printline "Empty interval " 'emptyInter'
			#pause
		else
			select Strings 'wordList$'
			wordNr = interNr - emptyInter + wordIndex
			#printline "Word number " 'wordNr'
			#pause
			newLab$ = Get string... wordNr
			posNr = interNr
			#printline "Interval position number " 'posNr'
			#pause
			select TextGrid 'currentFile$'
			Set interval text... tier posNr S_'newLab$'
			Save as text file... 'dirfile$'\'currentFile$'.TextGrid
		endif
	endfor
	Remove
	numberInter = numberInter - emptyInter
	#printline "Non-empty intervals " 'numberInter'
	#pause
	wordIndex = wordIndex + numberInter
	#printline "Number of processed words " 'wordIndex'
	#pause
endfor
