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


-- =========================
-- Productos agrícolas
-- =========================
CREATE TABLE product (
    product_id bigserial PRIMARY KEY,
    entity_id bigint NOT NULL REFERENCES accounting_entity(entity_id),
    sku text NOT NULL,
    name text NOT NULL,
    unit text NOT NULL, -- ej: 'kg', 'ton', 'litro'
    price numeric NOT NULL,
    UNIQUE(entity_id, sku)
);

-- =========================
-- Inventario de productos
-- =========================
CREATE TABLE inventory_transaction (
    transaction_id bigserial PRIMARY KEY,
    entity_id bigint NOT NULL REFERENCES accounting_entity(entity_id),
    product_id bigint NOT NULL REFERENCES product(product_id),
    transaction_date date NOT NULL,
    quantity numeric NOT NULL,
    unit_cost numeric NOT NULL,
    transaction_type text NOT NULL, -- 'IN', 'OUT', 'ADJUSTMENT'
    reference text
);

-- =========================
-- Clientes
-- =========================
CREATE TABLE customer (
    customer_id bigserial PRIMARY KEY,
    entity_id bigint NOT NULL REFERENCES accounting_entity(entity_id),
    name text NOT NULL,
    tax_id text,
    address text
);

-- =========================
-- Facturación
-- =========================
CREATE TABLE invoice (
    invoice_id bigserial PRIMARY KEY,
    entity_id bigint NOT NULL REFERENCES accounting_entity(entity_id),
    customer_id bigint NOT NULL REFERENCES customer(customer_id),
    invoice_date date NOT NULL,
    due_date date,
    total_amount numeric NOT NULL,
    status text NOT NULL DEFAULT 'DRAFT' -- 'DRAFT', 'ISSUED', 'PAID'
);

CREATE TABLE invoice_line (
    line_id bigserial PRIMARY KEY,
    invoice_id bigint NOT NULL REFERENCES invoice(invoice_id),
    product_id bigint NOT NULL REFERENCES product(product_id),
    quantity numeric NOT NULL,
    unit_price numeric NOT NULL,
    total_line_amount numeric NOT NULL
);
