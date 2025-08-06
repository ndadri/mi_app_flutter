-- Migration script to add 'state' column to mascotas table
ALTER TABLE mascotas ADD COLUMN state VARCHAR(20);
