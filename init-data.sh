#!/bin/bash
set -e

echo "Running PostgreSQL initialization script..."

# Check if required env vars exist
if [ -z "${POSTGRES_NON_ROOT_USER:-}" ] || [ -z "${POSTGRES_NON_ROOT_PASSWORD:-}" ]; then
    echo "SETUP WARNING: POSTGRES_NON_ROOT_USER or POSTGRES_NON_ROOT_PASSWORD not provided!"
    exit 0
fi

# Create user ONLY if it does not already exist
USER_EXISTS=$(psql -U "$POSTGRES_USER" -tAc "SELECT 1 FROM pg_roles WHERE rolname='${POSTGRES_NON_ROOT_USER}'")

if [ "$USER_EXISTS" != "1" ]; then
    echo "Creating non-root PostgreSQL user: $POSTGRES_NON_ROOT_USER"

    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE USER ${POSTGRES_NON_ROOT_USER} WITH PASSWORD '${POSTGRES_NON_ROOT_PASSWORD}';
        GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_NON_ROOT_USER};
        GRANT CREATE ON SCHEMA public TO ${POSTGRES_NON_ROOT_USER};
EOSQL

    echo "User created and permissions granted."
else
    echo "Non-root user '${POSTGRES_NON_ROOT_USER}' already exists. Skipping creation."
fi

echo "PostgreSQL initialization completed!"
