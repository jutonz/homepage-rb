set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y curl ca-certificates gnupg lsb-release git build-essential
apt-get install -y imagemagick libvips

apt-get install -y postgresql-common
/usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y

apt-get install -y \
  postgresql-18 \
  postgresql-client-18 \
  postgresql-server-dev-18

git clone --branch v0.8.2 https://github.com/pgvector/pgvector.git /tmp/pgvector
make -C /tmp/pgvector
make -C /tmp/pgvector install
rm -rf /tmp/pgvector

service postgresql start

su postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'postgres';\""
su postgres -c "psql -c \"CREATE EXTENSION IF NOT EXISTS vector;\""

mise settings ruby.compile=false
mise install
mise list
mise exec -- bundle install

echo $TEST_KEY > config/credentials/test.key
RAILS_ENV=test mise exec -- bin/rails db:setup
npx --yes playwright install --with-deps
