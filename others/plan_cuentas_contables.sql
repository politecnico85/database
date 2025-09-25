
-- Plan de cuentas contables
CREATE TABLE Account (
    account_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    type VARCHAR(50), -- Asset, Liability, Equity, Revenue, Expense
    currency_id INT,
    parent_account_id INT,
    is_active BOOLEAN DEFAULT TRUE
);

-- Inserción de cuentas principales y subcuentas
-- Activos
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Activos', 'Asset', 1, NULL);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Efectivo y Bancos', 'Asset', 1, 1);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Caja General', 'Asset', 1, 2);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Banco Nacional - Cliente A', 'Asset', 1, 2);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Banco Continental - Cliente B', 'Asset', 1, 2);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Banco Local XYZ - Cuenta Empresa', 'Asset', 1, 2);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Cuentas por cobrar', 'Asset', 1, 1);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Inventario', 'Asset', 1, 1);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Activos Fijos', 'Asset', 1, 1);

-- Pasivos
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Pasivos', 'Liability', 1, NULL);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Cuentas por pagar', 'Liability', 1, 11);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Deuda Bancaria', 'Liability', 1, 11);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Ingresos Diferidos', 'Liability', 1, 11);

-- Patrimonio
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Patrimonio', 'Equity', 1, NULL);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Capital Social', 'Equity', 1, 15);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Utilidades Retenidas', 'Equity', 1, 15);

-- Ingresos
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Ingresos', 'Revenue', 1, NULL);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Ventas de Productos', 'Revenue', 1, 18);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Servicios Profesionales', 'Revenue', 1, 18);

-- Gastos
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Gastos', 'Expense', 1, NULL);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Gastos Administrativos', 'Expense', 1, 21);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Gastos de Ventas', 'Expense', 1, 21);
INSERT INTO Account (name, type, currency_id, parent_account_id) VALUES ('Depreciación', 'Expense', 1, 21);
