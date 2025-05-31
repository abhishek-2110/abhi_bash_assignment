#!/bin/bash

# Input CSV File
CSV_FILE="users.csv"

# Download if it's a URL (optional feature)
if [[ "$CSV_FILE" =~ ^https?:// ]]; then
    wget -O temp.csv "$CSV_FILE"
    CSV_FILE="temp.csv"
fi

# Read CSV and skip header
tail -n +2 "$CSV_FILE" | while IFS=, read -r email birthdate groups folder
do
    username=$(echo "$email" | cut -d'@' -f1)
    month=$(date -d "$birthdate" +%m)
    year=$(date -d "$birthdate" +%Y)
    password="${month}${year}"

    echo "Creating user: $username"
    useradd -m -s /bin/bash "$username"
    echo "$username:$password" | chpasswd

    IFS=';' read -ra GRP <<< "${groups//\"/}"
    for g in "${GRP[@]}"; do
        groupadd -f "$g"
        usermod -aG "$g" "$username"
    done

    mkdir -p "$folder"
    chown root:"$g" "$folder"
    chmod 770 "$folder"

    ln -s "$folder" "/home/$username/shared"
    chown -h "$username:$g" "/home/$username/shared"

done
