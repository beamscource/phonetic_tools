
form Select directory, file type, and tiers
	sentence Diraudio E:\ZAS\Description_planning_German\audio
	# sentence Dirlabels E:\ZAS\Description_planning\labels
	sentence Tier(s) response # disfluency
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

	Create Strings as file list... fileList 'diraudio$'\'current_folder$'\*.wav
	numFiles = Get number of strings
	
	## Loop through files and make grids

	for i from 1 to numFiles
		select Strings fileList
		current_file$ = Get string... i
		Read from file... 'diraudio$'\'current_folder$'\'current_file$'
		sound$ = selected$ ("Sound")
		To TextGrid... "'tier$'"
		Save as text file... 'diraudio$'\'current_folder$'\'sound$'.TextGrid
    endfor
		
	numFolder = numFolder - 1
	folIndx = folIndx + 1
	
	select all
	minus Strings folderList
	Remove
endwhile

select all
Remove
clearinfo
echo Done.