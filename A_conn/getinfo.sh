#!/bin/bash
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         if ($2 == "type") {
            printf("%s\n", $3);
         }
      }
   }'
}
function extract_uses {
    local yaml_file=$1
    awk -v prefix="transforms__" '
    BEGIN { in_transforms = 0 }
    {
        if ($1 ~ /^transforms:/) {
            in_transforms = 1
        } else if (in_transforms && $1 ~ /^-/) {
            if ($2 == "uses:") {
                gsub(/:$/, "", $3)  # Remove the colon from the value
                printf("%s\n", $3);
            }
        } else if (in_transforms && $1 !~ /^[[:space:]]*-/) {
            in_transforms = 0
        }
    }' "$yaml_file"
}

# Example usage
car_type=$(parse_yaml car-connector.yaml)
mqtt_type=$(parse_yaml mqtt-helsinki.yaml)
smcar_type=$(extract_uses car-connector.yaml)
smuses_type=$(extract_uses mqtt-helsinki.yaml)

echo $car_type
echo $mqtt_type
echo $smcar_type
echo $smuses_type

