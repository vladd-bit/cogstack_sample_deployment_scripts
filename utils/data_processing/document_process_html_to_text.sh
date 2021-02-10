#!/usr/bin/env bash

root_project_data_dir="../../data/"

files_to_match="*.html"

folders_to_process=('cogstack_processing_1')

encoding="utf-8"

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
          file_path_new_file_ext=${file_path%.html}

          file_path_without_file_name="${file_path//$file_name.*}"

          echo "$(python -m html2text $file_path $encoding)"  > $file_path_new_file_ext".txt" 
          echo "Finished processing : "$file_path  
        done
    fi
done
