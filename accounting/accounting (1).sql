-- Extensiones útiles (opcional)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================
-- Catálogos y entidades
-- =========================
CREATE TABLE currency (
    currency_code  char(3) PRIMARY KEY,      -- ISO 4217 (e.g., 'USD', 'EUR')
    name           text NOT NULL
);

CREATE TABLE accounting_entity (
    entity_id      bigserial PRIMARY KEY,
    name           text NOT NULL,
    base_currency  char(3) NOT NULL REFERENCES currency(currency_code)
);

CREATE TABLE fiscal_period (
    period_id      bigserial PRIMARY KEY,
    entity_id      bigint NOT NULL REFERENCES accounting_entity(entity_id),
    period_code    text NOT NULL,            -- e.g., '2025-08'
    start_date     date NOT NULL,
    end_date       date NOT NULL,
    is_closed      boolean NOT NULL DEFAULT false,
    UNIQUE (entity_id, period_code),
    CHECK (start_date <= end_date)
);

-- =========================
-- Plan de cuentas
-- =========================
CREATE TYPE account_category AS ENUM (
  'ASSET','LIABILITY','EQUITY','REVENUE','EXPENSE',
  'CONTRA_ASSET','CONTRA_LIABILITY','CONTRA_EQUITY','CONTRA_REVENUE','CONTRA_EXPENSE'
);

CREATE TYPE normal_balance AS ENUM ('DEBIT','CREDIT');

CREATE TABLE account (
    account_id         bigserial PRIMARY KEY,
    entity_id          bigint NOT NULL REFERENCES accounting_entity(entity_id),
    account_code       text NOT NULL,            -- ej: '1000', '1100.01'
    account_name       text NOT NULL,
    category           account_category NOT NULL,
    normal_side        normal_balance NOT NULL,  -- ayuda para reportes/signos
    parent_account_id  bigint REFERENCES account(account_id),
    is_postable        boolean NOT NULL DEFAULT true, -- si false, solo agregación
    is_active          boolean NOT NULL DEFAULT true,
    UNIQUE(entity_id, account_code),
    CHECK (account_id <> parent_account_id)
);

-- =========================
-- Dimensiones opcionales
-- =========================
CREATE TABLE cost_center (
    cost_center_id  bigserial PRIMARY KEY,
    entity_id       bigint NOT NULL REFERENCES accounting_entity(entity_id),
    code            text NOT NULL,
    name            text NOT NULL,
    UNIQUE(entity_id, code)
);

CREATE TABLE project (
    project_id  bigserial PRIMARY KEY,
    entity_id   bigint NOT NULL REFERENCES accounting_entity(entity_id),
    code        text NOT NULL,
    name        text NOT NULL,
    UNIQUE(entity_id, code)
);
