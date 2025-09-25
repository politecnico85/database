
-- Tabla para pruebas unitarias
CREATE TABLE UnitTestJournal (
    test_id SERIAL PRIMARY KEY,
    description TEXT,
    expected_debit NUMERIC(18,2),
    expected_credit NUMERIC(18,2),
    result TEXT
);

-- Ejemplo 1: Compra de equipo en efectivo
-- Se incrementa el activo 'Equipos' y se reduce el activo 'Efectivo'
INSERT INTO JournalEntry (date, description, module) VALUES ('2025-09-01', 'Compra de equipo en efectivo', 'General');
INSERT INTO JournalLine (journal_entry_id, account_id, debit, credit, currency_id, amount_original, amount_base)
VALUES (1, 201, 2000, 0, 1, 2000, 2000); -- Equipos
INSERT INTO JournalLine (journal_entry_id, account_id, debit, credit, currency_id, amount_original, amount_base)
VALUES (1, 101, 0, 2000, 1, 2000, 2000); -- Efectivo

-- Ejemplo 2: Venta a crédito
-- Se reconoce ingreso y se crea cuenta por cobrar
INSERT INTO JournalEntry (date, description, module) VALUES ('2025-09-02', 'Venta a crédito', 'AR');
INSERT INTO JournalLine (journal_entry_id, account_id, debit, credit, currency_id, amount_original, amount_base)
VALUES (2, 102, 1500, 0, 1, 1500, 1500); -- Cuentas por cobrar
INSERT INTO JournalLine (journal_entry_id, account_id, debit, credit, currency_id, amount_original, amount_base)
VALUES (2, 401, 0, 1500, 1, 1500, 1500); -- Ingresos

-- Ejemplo 3: Pago de factura de proveedor
-- Se reduce la obligación y el efectivo
INSERT INTO JournalEntry (date, description, module) VALUES ('2025-09-03', 'Pago a proveedor', 'AP');
INSERT INTO JournalLine (journal_entry_id, account_id, debit, credit, currency_id, amount_original, amount_base)
VALUES (3, 202, 800, 0, 1, 800, 800); -- Cuentas por pagar
INSERT INTO JournalLine (journal_entry_id, account_id, debit, credit, currency_id, amount_original, amount_base)
VALUES (3, 101, 0, 800, 1, 800, 800); -- Efectivo

-- Ejemplo 4: Registro de depreciación
-- Se reconoce gasto y se acumula depreciación
INSERT INTO JournalEntry (date, description, module) VALUES ('2025-09-04', 'Depreciación mensual', 'Activos');
INSERT INTO JournalLine (journal_entry_id, account_id, debit, credit, currency_id, amount_original, amount_base)
VALUES (4, 501, 100, 0, 1, 100, 100); -- Gasto por depreciación
INSERT INTO JournalLine (journal_entry_id, account_id, debit, credit, currency_id, amount_original, amount_base)
VALUES (4, 301, 0, 100, 1, 100, 100); -- Depreciación acumulada

-- Ejemplo 5: Reconocimiento de ingreso diferido
-- Se convierte el pasivo en ingreso reconocido
INSERT INTO JournalEntry (date, description, module) VALUES ('2025-09-05', 'Reconocimiento de ingreso diferido', 'DeferredRevenue');
INSERT INTO JournalLine (journal_entry_id, account_id, debit, credit, currency_id, amount_original, amount_base)
VALUES (5, 203, 500, 0, 1, 500, 500); -- Ingreso diferido
INSERT INTO JournalLine (journal_entry_id, account_id, debit, credit, currency_id, amount_original, amount_base)
VALUES (5, 401, 0, 500, 1, 500, 500); -- Ingresos

-- Pruebas unitarias
INSERT INTO UnitTestJournal (description, expected_debit, expected_credit, result)
VALUES ('Compra de equipo', 2000, 2000, 'Pendiente');
INSERT INTO UnitTestJournal (description, expected_debit, expected_credit, result)
VALUES ('Venta a crédito', 1500, 1500, 'Pendiente');
INSERT INTO UnitTestJournal (description, expected_debit, expected_credit, result)
VALUES ('Pago a proveedor', 800, 800, 'Pendiente');
INSERT INTO UnitTestJournal (description, expected_debit, expected_credit, result)
VALUES ('Depreciación mensual', 100, 100, 'Pendiente');
INSERT INTO UnitTestJournal (description, expected_debit, expected_credit, result)
VALUES ('Ingreso diferido reconocido', 500, 500, 'Pendiente');
