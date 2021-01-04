#!/usr/bin/env bash

# This is the DATA directory inside the postgres database Docker image. 
root_project_data_dir="./"

files_to_match="*.txt"

folders_to_process=('cogstack_processing_1' 'cogstack_processing_2')

docker_db_container_name="cogstack-pipeline_databank-db_1"

docker_db_container_ip_address=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $docker_db_container_name)

for folder_to_process in $folders_to_process; do
    if [ -d "$root_project_data_dir$folder_to_process" ]; then

        file_paths=$(find $root_project_data_dir$folder_to_process/ -name "$files_to_match")

        processed_folder_name="processed_"$folder_to_process

        if [ ! -d "$root_project_data_dir$processed_folder_name" ]; then
            mkdir -p $root_project_data_dir$processed_folder_name;
        fi
        
        for file_path in $file_paths; do
            file_name=$(basename $file_path)
            file_name="${file_name%.*}"

            # gets the file name and adds it to the CSV (the delimiter in this case is a pipe "|") file as a field at the beginning : file_ID|column1|column2...
            sed -i -e "/^$file_name|/!s/$file_name\|/$file_name\|/" $file_path

            # inserts it into the DB
            psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DATABANK_DB" --hostname "$docker_db_container_ip_address" <<-EOSQL
                \copy TABLENAME from $file_path delimiter '|' csv header NULL ''; 
            EOSQL

            # moves it to a processed folder
            mv $file_path $root_project_data_dir$processed_folder_name
            printf "\n"
            echo "Finished processing file:" $filename
        done
    fi
done