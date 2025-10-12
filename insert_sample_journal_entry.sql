
-- Insertar journal_entry
INSERT INTO journal_entry (entry_id, entity_id, period_id, entry_date, description, source_module, is_posted)
VALUES (1, 1, 1, '2025-10-12', 'Venta de productos agrícolas', 'INVOICE', true);

-- Insertar líneas en general_ledger
INSERT INTO general_ledger (ledger_id, entity_id, account_id, period_id, entry_id, debit, credit, currency_code, partner_id, cost_center_id)
VALUES
  (1, 1, 1, 1, 1, 1190, 0, 'PEN', 1, 1), -- Caja y Bancos
  (2, 1, 2, 1, 1, 0, 1000, 'PEN', 1, 1), -- Ventas de Productos
  (3, 1, 3, 1, 1, 0, 190, 'PEN', 2, 2);   -- IVA por Pagar
