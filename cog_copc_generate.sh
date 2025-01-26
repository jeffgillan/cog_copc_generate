#!/bin/bash

# Define input and output directories
input_dir="/input"


# Iterate over all files in the input directory
for file in "$input_dir"/*; do
    # Check if the file has a .las or .laz extension
    if [[ "$file" == *.las || "$file" == *.laz ]]; then
        # Extract the base name of the file (without directory and extension)
        filename=$(basename "$file")
        base_name="${filename%.*}"
        # Define the output file path with .copc.laz extension
        output_file="$input_dir/${base_name}.copc.laz"
        # Run untwine to convert the file to COPC format
        untwine --files="$file" --output_dir="$output_file" --single_file 
    else
        echo "Skipping non-LAS/LAZ file: $file"
    fi
done

# Iterate over all files in the input directory
for file in "$input_dir"/*; do
    # Check if the file has a .tif extension
    if [[ "$file" == *.tif ]]; then
        # Extract the base name of the file (without directory and extension)
        filename=$(basename "$file")
        base_name="${filename%.*}"
        # Define the output file path with .copc.laz extension
        output_file="$input_dir/${base_name}_cog.tif"
        # Run gdal to convert the file to COG format
        gdal_translate -of COG -co COMPRESS=LZW "$file" "$output_file" 
    else
        echo "Skipping non-tif file: $file"
    fi
done
