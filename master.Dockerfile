# Use mysql version 8
FROM mysql:8.0

# Copy master my.cnf file
COPY master/master-config.cnf /etc/my.cnf