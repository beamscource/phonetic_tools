form Select directory
	sentence Diraudio E:\ZAS\Description_planning_German\audio
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
	
	# get all audio files inside the directory
	Create Strings as file list... fileList 'diraudio$'\'current_folder$'\*.wav
	numFiles = Get number of strings

	## Loop through files

	for k from 1 to numFiles
		select Strings fileList
		current_file$ = Get string... k
		Read from file... 'diraudio$'\'current_folder$'\'current_file$'
		sound$ = selected$ ("Sound")

		grid$ = "'diraudio$'\'current_folder$'\'sound$'.TextGrid"
       	Read from file... 'grid$'
  	
		plus Sound 'sound$'
		Edit
		pause Annotate tiers, then press continue...
		minus Sound 'sound$'
		Save as text file... 'grid$'
		select all
		minus Strings fileList
		minus Strings folderList
		Remove
	endfor

	numFolder = numFolder - 1
	folIndx = folIndx + 1
	
	select all
	minus Strings folderList
	Remove
	
endwhile
select all
Remove