--
-- 1. AUDIT TRIGGER FUNCTION
-- This function is designed to automatically manage the created_at, updated_at,
-- created_by, and updated_by fields on both INSERT and UPDATE operations.
--
CREATE OR REPLACE FUNCTION set_audit_timestamps()
RETURNS TRIGGER AS $$
BEGIN
    -- Logic for INSERT (Creation)
    IF TG_OP = 'INSERT' THEN
        NEW.created_at := NOW();
        NEW.updated_at := NEW.created_at;
        NEW.updated_by := NEW.created_by;
    -- Logic for UPDATE
    ELSIF TG_OP = 'UPDATE' THEN
        NEW.updated_at := NOW();
        -- Prevent immutable fields from being changed during an update
        NEW.created_at := OLD.created_at;
        NEW.created_by := OLD.created_by;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--
-- 2. INVOICE TABLE DEFINITION
-- Stores metadata about uploaded invoices.
--
CREATE TABLE IF NOT EXISTS invoice (
    id           SERIAL PRIMARY KEY,
    key          VARCHAR(255) NOT NULL UNIQUE,
    is_uploaded  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMP WITHOUT TIME ZONE,
    updated_at   TIMESTAMP WITHOUT TIME ZONE,
    created_by   VARCHAR(255) NOT NULL,
    updated_by   VARCHAR(255) NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_invoice_key ON invoice (key);

CREATE OR REPLACE TRIGGER trg_invoice_audit
BEFORE INSERT OR UPDATE ON invoice
FOR EACH ROW
EXECUTE FUNCTION set_audit_timestamps();