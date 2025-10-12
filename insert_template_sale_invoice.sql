
-- Insertar plantilla contable
INSERT INTO journal_template (template_id, entity_id, template_code, description, source_module, is_active)
VALUES (1, 1, 'SALE-INVOICE', 'Plantilla contable para venta con IVA', 'INVOICE', true);

-- Insertar líneas de plantilla
INSERT INTO journal_template_line (line_id, template_id, account_id, side, amount_expression, currency_code, cost_center_id, partner_role)
VALUES
  (1, 1, 1, 'DEBIT', 'total_amount', 'PEN', 1, 'CUSTOMER'), -- Caja y Bancos
  (2, 1, 2, 'CREDIT', 'subtotal_amount', 'PEN', 1, 'CUSTOMER'), -- Ventas de Productos
  (3, 1, 3, 'CREDIT', 'tax_amount', 'PEN', 2, 'TAX_AUTHORITY'); -- IVA por Pagar
