-- =========================
-- Extensiones
-- =========================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================
-- Catálogos y entidades
-- =========================
CREATE TABLE currency (
    currency_code char(3) PRIMARY KEY,      -- ISO 4217 (e.g., 'USD', 'EUR')
    name text NOT NULL,
    symbol text NOT NULL,                  -- e.g., '$', '€'
    decimal_places smallint NOT NULL DEFAULT 2,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    updated_at timestamp with time zone
);

CREATE TABLE accounting_entity (
    entity_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    base_currency char(3) NOT NULL REFERENCES currency(currency_code),
    razon_social text,
    ruc text,
    representante_legal text,
    parent_entity_id uuid REFERENCES accounting_entity(entity_id),
    timezone text NOT NULL DEFAULT 'UTC',
    is_consolidated boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);

CREATE TABLE fiscal_period (
    period_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id uuid NOT NULL REFERENCES accounting_entity(entity_id),
    period_code text NOT NULL,            -- e.g., '2025-08'
    fiscal_year int GENERATED ALWAYS AS (CAST(SUBSTRING(period_code FROM '^\d{4}') AS int)) STORED,
    start_date date NOT NULL,
    end_date date NOT NULL,
    is_closed boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    UNIQUE (entity_id, period_code),
    CHECK (start_date <= end_date),
    EXCLUDE USING GIST (entity_id WITH =, tsrange(start_date, end_date) WITH &&)
);

-- =========================
-- Plan de cuentas
-- =========================
CREATE TYPE account_category AS ENUM (
    'ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE',
    'CONTRA_ASSET', 'CONTRA_LIABILITY', 'CONTRA_EQUITY', 'CONTRA_REVENUE', 'CONTRA_EXPENSE',
    'OTHER_ASSET', 'OTHER_LIABILITY'
);

CREATE TYPE normal_balance AS ENUM ('DEBIT', 'CREDIT');

CREATE TABLE account (
    account_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id uuid NOT NULL REFERENCES accounting_entity(entity_id),
    account_code text NOT NULL,            -- e.g., '1000', '1100.01'
    account_name text NOT NULL,
    description text,
    category account_category NOT NULL,
    normal_side normal_balance NOT NULL,
    parent_account_id uuid REFERENCES account(account_id),
    is_postable boolean NOT NULL DEFAULT true,
    is_active boolean NOT NULL DEFAULT true,
    currency_code char(3) NOT NULL REFERENCES currency(currency_code),
    level int NOT NULL DEFAULT 1,
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    UNIQUE(entity_id, account_code),
    CHECK (account_id <> parent_account_id),
    CHECK (account_code ~ '^\d+(\.\d+)*$')
);

-- =========================
-- Dimensiones analíticas
-- =========================
CREATE TABLE cost_center (
    cost_center_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id uuid NOT NULL REFERENCES accounting_entity(entity_id),
    code text NOT NULL,
    name text NOT NULL,
    description text,
    parent_id uuid REFERENCES cost_center(cost_center_id),
    budget_amount numeric,
    budget_currency char(3) REFERENCES currency(currency_code),
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    UNIQUE(entity_id, code)
);

CREATE TABLE project (
    project_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id uuid NOT NULL REFERENCES accounting_entity(entity_id),
    code text NOT NULL,
    name text NOT NULL,
    description text,
    parent_id uuid REFERENCES project(project_id),
    budget_amount numeric,
    budget_currency char(3) REFERENCES currency(currency_code),
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    UNIQUE(entity_id, code)
);

-- =========================
-- Tablas de soporte para negocios
-- =========================
CREATE TABLE exchange_rate (
    rate_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_currency char(3) NOT NULL REFERENCES currency(currency_code),
    to_currency char(3) NOT NULL REFERENCES currency(currency_code),
    rate_date date NOT NULL,
    rate numeric(15,6) NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    updated_at timestamp with time zone,
    UNIQUE(from_currency, to_currency, rate_date)
);

CREATE TABLE tax_code (
    tax_code_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id uuid NOT NULL REFERENCES accounting_entity(entity_id),
    code text NOT NULL,
    name text NOT NULL,
    rate numeric(5,2) NOT NULL,
    account_id uuid REFERENCES account(account_id),
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    UNIQUE(entity_id, code)
);

CREATE TABLE partner (
    partner_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id uuid NOT NULL REFERENCES accounting_entity(entity_id),
    name text NOT NULL,
    type text CHECK (type IN ('CUSTOMER', 'VENDOR', 'EMPLOYEE')),
    tax_id text,
    address text,
    currency_code char(3) REFERENCES currency(currency_code),
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);

CREATE TABLE product (
    product_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id uuid NOT NULL REFERENCES accounting_entity(entity_id),
    code text NOT NULL,
    name text NOT NULL,
    type text CHECK (type IN ('GOOD', 'SERVICE')),
    unit_price numeric,
    cost_account_id uuid REFERENCES account(account_id),
    revenue_account_id uuid REFERENCES account(account_id),
    inventory_account_id uuid REFERENCES account(account_id),
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    UNIQUE(entity_id, code)
);

CREATE TABLE inventory (
    inventory_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id uuid NOT NULL REFERENCES product(product_id),
    quantity numeric NOT NULL,
    as_of_date date NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);

-- =========================
-- Transacciones
-- =========================
CREATE TABLE journal_entry (
    entry_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id uuid NOT NULL REFERENCES accounting_entity(entity_id),
    period_id uuid NOT NULL REFERENCES fiscal_period(period_id),
    entry_date date NOT NULL,
    description text,
    is_posted boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone NOT NULL DEFAULT current_timestamp,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);

CREATE TABLE general_ledger (
    ledger_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id uuid NOT NULL REFERENCES accounting_entity(entity_id),
    account_id uuid NOT NULL REFERENCES account(account_id),
    period_id uuid NOT