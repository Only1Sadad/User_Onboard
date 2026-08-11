#!/bin/bash 

umask 077

# check if root
if [ "$EUID" -ne 0 ]; then
        echo "Sorry Stop You Have To Be Superman(ie root) To fly"
        exit 1
fi

# declare variables and assign values
groups=("Quality" "Inspection" "Material")
date=$(date '+%m-%d-%Y %H:%M:%S')
log="/var/log/onboarding.logs"

# Create Groups
for g in "${groups[@]}"; do
        if groupadd "$g" 2> /dev/null; then
                echo " Group: $g Successfully Created $date" >> "$log"
        else
                echo " Group: $g Already exists $date" >> "$log"
        fi
done

# Check If File Exists
if [ ! -f "newhires.csv" ]; then
        echo "Error: file newhires.csv does not exist $date" >> "$log"
        exit 1
fi

# Create Users
awk 'NR > 1' newhires.csv | while IFS=',' read -r first last dept; do
        # verify department match
        check=false
        for g in "${groups[@]}"; do
                if [[ "$g" == "$dept" ]]; then
                        check=true
                        break
                fi
        done
        if [ "$check" == "false" ]; then
                echo "Error: Department assigned to User:${first}.${last} is incorrect $date" >> "$log"
                continue
        fi
        # Create User
        if useradd "${first}.${last}" -g "$dept" 2> /dev/null; then
                echo "User:${first}.${last} Successfully Created $date" >> "$log"
                # Expand Password
                login="${first}${last}"
                while [ ${#login} -lt 8 ]; do
                        login="${login}1"
                done
                # Create Password
                echo "$login" | /usr/bin/passwd --stdin "${first}.${last}"
                echo "Password Successfully Created for: ${first}.${last} $date" >> "$log"
                # Set Password Expiry
                /usr/bin/chage -d 0 -M 90 -W 7 "${first}.${last}"
                echo "Password Expiration already set for ${first}.${last} $date" >> "$log"
        else
                echo "User: ${first}.${last} Already Exists $date" >> "$log"
        fi
done

# Finish Logs
echo "Onboarding completed at $date" >> "$log"
chown root:root "$log"
