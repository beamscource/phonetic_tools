# Script merging two TextGrids
# Author: Eugen Klein, July 2014

form Enter directory and directory of the tier to merge
	sentence Diraudio E:\ZAS\Description_planning\audio
	sentence Dirmerge E:\ZAS\Description_planning\
endform

# create list of all folders inside the directory
Create Strings as directory list... folderList 'diraudio$'
# number of folders inside 
numFolder = Get number of strings
# assign a folder index
folIndx = 1

while not (numFolder = 0)

	select Strings folderList
    current_folder$ = Get string... folIndx
	
	# Read Strings from raw text file... 'dirlabels$'\'current_folder$'\.txt
	# numLabels = Get number of strings

	Create Strings as file list... fileList 'diraudio$'\'current_folder$'\*.TextGrid
	numFiles = Get number of strings
	
	## Loop through files and make grids

for fileNr from 1 to numFiles
     Read from file... 'dirmerge$'\response.TextGrid
	 select Strings fileList
     current_file$ = Get string... fileNr
     Read from file... 'diraudio$'\'current_folder$'\'current_file$'
     object_name$ = selected$ ("TextGrid")
          
     select TextGrid 'object_name$'
     plus TextGrid response
     Merge

     select TextGrid merged

     Write to text file... 'diraudio$'\'current_folder$'\'object_name$'.TextGrid
     # select all
     # minus Strings fileList
     # Remove
endfor

numFolder = numFolder - 1
folIndx = folIndx + 1

endwhile
