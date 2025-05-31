#!/bin/bash

LOGFILE="/var/log/user_script.log"

echo "User creation started at $(date)" | tee -a "$LOGFILE"

if [ -z "$1" ]; then
  echo "Usage: $0 <csv_file_or_url>" | tee -a "$LOGFILE"
  exit 1
fi

CSVFILE="$1"

# If CSV is a URL, download it
if [[ "$CSVFILE" =~ ^https?:// ]]; then
  echo "Downloading CSV from $CSVFILE..." | tee -a "$LOGFILE"
  wget -q -O /tmp/userlist.csv "$CSVFILE"
  CSVFILE="/tmp/userlist.csv"
fi

if [ ! -f "$CSVFILE" ]; then
  echo "CSV file not found: $CSVFILE" | tee -a "$LOGFILE"
  exit 1
fi

# Process CSV lines, skip header and empty lines
tail -n +2 "$CSVFILE" | while IFS=',' read -r email birthdate groups sharedFolder; do
  # Trim spaces and quotes
  email=$(echo "$email" | xargs)
  birthdate=$(echo "$birthdate" | xargs)
  groups=$(echo "$groups" | tr -d '"' | xargs)
  sharedFolder=$(echo "$sharedFolder" | tr -d '"' | xargs)

  # Skip empty lines or if email is empty
  if [[ -z "$email" ]]; then
    continue
  fi

  # Extract username: first letter of first name + surname (part after dot)
  # Example: Karan.patel@otago.co.nz -> kpatel
  localpart="${email%@*}"  # before @
  first_name="${localpart%%.*}"  # before first dot
  surname="${localpart#*.}"       # after first dot

  if [[ -z "$first_name" || -z "$surname" ]]; then
    echo "Invalid email format for user: $email" | tee -a "$LOGFILE"
    continue
  fi

  username="$(echo "${first_name:0:1}${surname}" | tr '[:upper:]' '[:lower:]')"

  # Password from birthdate: MMYYYY
  # Birthdate format assumed YYYY-MM-DD
  IFS='-' read -r byear bmonth bday <<< "$birthdate"
  password="${bmonth}${byear}"

  echo "Processing user: $username with password $password" | tee -a "$LOGFILE"

  # Check if user already exists
  if id "$username" &>/dev/null; then
    echo "User $username already exists, skipping creation." | tee -a "$LOGFILE"
  else
    echo "Creating user $username" | tee -a "$LOGFILE"
    useradd -m -s /bin/bash "$username"

    echo "${username}:${password}" | chpasswd

    # Create and assign secondary groups
    IFS=',' read -ra group_array <<< "$groups"
    for grp in "${group_array[@]}"; do
      grp=$(echo "$grp" | xargs) # trim spaces
      if ! getent group "$grp" >/dev/null; then
        echo "Creating group $grp" | tee -a "$LOGFILE"
        groupadd "$grp"
      fi
      usermod -aG "$grp" "$username"
    done

    # Setup shared folder and permissions
    if [ ! -d "$sharedFolder" ]; then
      echo "Creating shared folder $sharedFolder" | tee -a "$LOGFILE"
      mkdir -p "$sharedFolder"
    fi

    # Set group ownership to first group in the list and permission 770
    firstgrp="${group_array[0]}"
    chgrp "$firstgrp" "$sharedFolder"
    chmod 770 "$sharedFolder"

    # Create symlink in user's home
    ln -sfn "$sharedFolder" "/home/$username/shared"

    echo "User $username setup complete" | tee -a "$LOGFILE"
  fi
done

echo "User creation finished at $(date)" | tee -a "$LOGFILE"
