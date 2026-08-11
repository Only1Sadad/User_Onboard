
# User Onboarding Script

## Overview

This Bash script automates the process of onboarding new employees by:
- Creating system user accounts
- Assigning users to appropriate groups
- Setting secure initial passwords
- Configuring password expiration policies
- Maintaining a detailed audit log

**Target Environment:** RHEL 9/10, Rocky Linux, AlmaLinux, or any Red Hat-based distribution.

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/Only1Sadad/User-Onboarding-Script.git
cd User-Onboarding-Script

# 2. Prepare your CSV file
cp newhires.csv.example newhires.csv
# Edit newhires.csv with your employee data

# 3. Make the script executable
chmod +x onboarding.sh

# 4. Run as root
sudo ./onboarding.sh
```

## CSV File Format

The script expects a CSV file named `newhires.csv` in the following format:

| Column     | Description           |  Example     |
|------------|-----------------------|--------------|
| First Name | Employee's first name | Angela       |
| Last Name  | Employee's last name  | Smith        |
| DEPARTMENT | Match defined groups  | Quality      |

**Example:**
```csv
First Name,Last Name,DEPARTMENT
Angela,Smith,Quality
Brandon,Clark,Inspection
Catherine,Steph,Material
Daniel,Rick,Material
```

> **Important:** The `DEPARTMENT` column must exactly match one of the predefined groups: `Quality`, `Inspection`, or `Material`.

## Features

- **Root Privilege Check** - Script verifies it's running as root
- **Group Management** - Automatically creates required groups if they don't exist
- **User Creation** - Creates user accounts with the format `first.last`
- **Password Generation** - Auto-generates passwords (firstname+lastname + padding to 8 chars)
- **Password Expiry** - Forces password change on first login
- **Security Hardening** - Sets `umask 077`, restricts log file permissions
- **Comprehensive Logging** - Logs all actions to `/var/log/onboarding.logs`

##Installation

### Prerequisites

- Root or sudo access
- RHEL-based Linux distribution
- Basic system administration knowledge

### Step-by-Step Installation

```bash
# 1. Download the script
wget https://raw.githubusercontent.com/Only1Sadad/User-Onboarding-Script/refs/heads/main/onboarding.sh

# 2. Review the script (ALWAYS review scripts before running!)
cat onboarding.sh

# 3. Make it executable
chmod +x onboarding.sh

# 4. Prepare your CSV file with employee data
# Format: First Name,Last Name,DEPARTMENT

# 5. Run the script
sudo ./onboarding.sh
```


## Logging

All actions are logged to: **`/var/log/onboarding.logs`**

**Example Log Output:**
```
Group: Quality Already exists 08-03-2026 10:13:44
Group: Inspection Already exists 08-03-2026 10:13:4i4
Group: Material Already exists 08-03-2026 10:13:44
User: Angela.Smith Successfully Created 08-03-2026 10:13:44
Password Successfully Created for: Angela.Smith 08-03-2026 10:13:44
Password Expiration already set for Angela.Smith 08-03-2026 10:13:44
Onboarding completed at 08-03-2026 10:13:44
```

## Verification Commands

After running the script, verify users were created:

```bash
# Check if users exist
grep -E "Angela|Brandon|Catherine|Daniel" /etc/passwd

# Check groups
getent group Quality Inspection Material

# Check user groups
id Angela.Smith

# Check password expiration
chage -l Angela.Smith

# Check log file
cat /var/log/onboarding.logs
```

## Troubleshooting

### Issue: "User Already Exists" but user not found

**Cause:** The `useradd` command failed silently due to:
- Username contains invalid characters (period `.` may not be allowed)
- Group doesn't actually exist
- Home directory creation failed
- spacing issues coming from CSV file

**Solution:**
```bash
# Test useradd manually to see real error
/usr/bin/useradd Test.User -g Quality

# Check if username format is allowed
grep USERNAME /etc/login.defs

# Check for existing users
grep -i "angela" /etc/passwd
```

### Issue: "Permission denied" or "Operation not permitted"

**Cause:** Script is not running as root.

**Solution:**
```bash
# Run with sudo
sudo ./onboarding.sh

# Or switch to root
su -
./onboarding.sh
```

### Issue: CSV file not found

**Cause:** Script is running from a different directory.

**Solution:**
```bash
# Ensure CSV is in the same directory
ls -la newhires.csv

# Or use full path
# Edit script to use: /full/path/to/newhires.csv
```

## Security Considerations

| Security Feature       |  Implementation  |
|------------------------|------------------|
| Root-only execution    | Script checks EUID and exits if not root |
| Restrictive umask      | `umask 077` prevents other users from reading files |
| Secure log file        | `chmod 600 /var/log/onboarding.logs` |
| Password expiry        | Users must change password on first login (`chage -d 0`) |
| No hardcoded passwords | Passwords are generated and set automatically |

## Repository Structure

```
user-onboarding-script/
├── README.md              # This file
├── onboarding.sh          # Main script
├── newhires.csv.example   # Example CSV template
```

## Want to Contribe

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
