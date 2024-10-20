#!/bin/bash

# Hard-code which module files need which field to be required in the schema changeset
declare -a file_field_pairs=(
    "fly_schemas/fly_env_from.ex:env_var"
    "fly_schemas/fly_machine_secret.ex:env_var"
    # Add more file:field pairs as needed
)

# Function to add the validation line to a file
add_validation() {
    local file="$1"
    local field="$2"
    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        return 1
    fi

    # Create a temporary file
    temp_file=$(mktemp)
    # echo "Created temporary file $temp_file"

    sed -i '' -e "/def changeset(schema, attrs) do/{N;/\n    schema/ a\\
        |> validate_required([:$field])
    }" "$file"

    # Check if sed command was successful
    if [ $? -ne 0 ]; then
        echo "Error: sed command failed for $file"
        rm "$temp_file"
        return 1
    fi

    # Move the temporary file to replace the original file
    # mv "$temp_file" "$file"

    echo "Processed $file"
}

# Main script
echo "Starting to process files..."

for pair in "${file_field_pairs[@]}"; do
    IFS=':' read -r file field <<< "$pair"
    if add_validation "$file" "$field"; then
        echo "Successfully added validation for :$field to $file"
    else
        echo "Failed to process $file"
    fi
done

echo "All files processed."