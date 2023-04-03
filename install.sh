#!/bin/bash

postgres () {
        #lsb_id=`lsb_release -i | awk '{print $3}'`
        echo "Installing postgresql....."
        if [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then 
                echo "Detected OS as Ubuntu $(lsb_release -r)"
                sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
                wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
                sudo apt-get update
                sudo apt-get -y install postgresql
        elif [ -f /etc/fedora-release ]; then
                echo "Detected OS as Fedora $(lsb_release -r)"
                sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/F-37-x86_64/pgdg-fedora-repo-latest.noarch.rpm
                sudo dnf install -y postgresql15-server
                sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
                sudo systemctl enable postgresql-15
                sudo systemctl start postgresql-15
        elif [ -f /etc/redhat-release ]; then 
                echo "Detected OS as RedHat $(lsb_release -r)"
                # Install the repository RPM:
                sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

                # Install PostgreSQL:
                sudo yum install -y postgresql15-server

                # Optionally initialize the database and enable automatic start:
                sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
                sudo systemctl enable postgresql-15
                sudo systemctl start postgresql-15
        else
                echo "Operating system does not support PostgreSQL"
        fi
}

redis () {
        echo "Installing Redis"
        if [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
                echo "Detected OS as Ubuntu/Debian: $(lsb_release -r)"
                curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

                echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | \
                        sudo tee /etc/apt/sources.list.d/redis.list

                sudo apt-get update
                sudo apt-get install redis
        else
                echo "Did not detect supported operating system"
        fi
}

if [ $# -lt 1 ]; then
        echo "No arguments provided"
        exit 1
fi

for x in $@
do
        if [ x == "postgresql" ]; then
                postgresql
        elif [ x == "redis" ]; then
                redis
        else
                echo "Unknown database. Request to be added in script via the issue page on Github"
        fi
done
