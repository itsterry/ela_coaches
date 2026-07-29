CREATE DATABASE ela_coaches_production;
CREATE DATABASE ela_coaches_production_cache;
CREATE DATABASE ela_coaches_production_queue;
CREATE DATABASE ela_coaches_production_cable;
CREATE USER 'ela_coaches'@'%' IDENTIFIED BY 'FdDwCmVZqO5cwuujXWDv4w9c';
GRANT ALL PRIVILEGES ON ela_coaches_production.* TO 'ela_coaches'@'%';
GRANT ALL PRIVILEGES ON ela_coaches_production_cache.* TO 'ela_coaches'@'%';
GRANT ALL PRIVILEGES ON ela_coaches_production_queue.* TO 'ela_coaches'@'%';
GRANT ALL PRIVILEGES ON ela_coaches_production_cable.* TO 'ela_coaches'@'%';
