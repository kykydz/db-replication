# Use mysql version 8
# Use mysql version 8
FROM mysql:8.0

# Copy replica my.cnf file
COPY replica/replica-config.cnf /etc/my.cnf