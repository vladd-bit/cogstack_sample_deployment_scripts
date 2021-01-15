#!/usr/bin/env bash

root_project_data_dir="../../data/"

files_to_match="*.doc"

folders_to_process=('cogstack_processing_1')

encoding="utf-8"

officer_binary="/usr/bin/libreoffice"

LOG_FILE=__prepare_docs.log

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
          file_path_new_file_ext=${file_path%.doc}
        
          #$SOFFICE_BIN --headless --invisible --convert-to txt --outdir $file_path $TMP_DIR/mtsamples-type-*.txt >> $LOG_FILE

        done
    fi
done
