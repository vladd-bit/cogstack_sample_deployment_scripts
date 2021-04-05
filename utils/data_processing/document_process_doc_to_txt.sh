#!/usr/bin/env bash

root_project_data_dir="../../data/"

files_to_match="*.doc"

folders_to_process=('cogstack_processing_1')

encoding="utf-8"

extension=".doc"
output_extension=".txt"

LOG_FILE="__prepare_docs.log"

officer_binary="/usr/bin/soffice"

if [ "$(uname)" == "Darwin" ]; then
    officer_binary="/usr/local/bin/soffice"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    officer_binary="C:/Program Files/LibreOffice/program/soffice.exe"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    officer_binary4="C:/Program Files/LibreOffice/program/soffice.exe"
fi

for folder_to_process in $folders_to_process; do
    if [ -d "$root_project_data_dir$folder_to_process" ]; then
        file_paths=$(find $root_project_data_dir$folder_to_process/ -name "$files_to_match")
        processed_folder_name="processed_"$folder_to_process
        
        if [ ! -d "$root_project_data_dir$processed_folder_name" ]; then
            mkdir -p $root_project_data_dir$processed_folder_name;
        fi

        for file_path in $file_paths; do
          file_name_base=$(basename $file_path)
          file_name="${file_name_base%.*}"
        
          file_path_new_file_ext=${file_path%$extension}$output_extension
         
          if [ ! -f $file_path_new_file_ext ]; then
            "$officer_binary" --headless --invisible --convert-to txt:Text --outdir $file_path_without_file_name $file_path >> $LOG_FILE
            echo "Finished processing : "$file_path
          else
            echo "File $file_path already processed... skipping "
          fi
        done
    fi
done
