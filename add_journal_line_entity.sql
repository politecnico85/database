
-- =========================
-- Detalle de Asientos Contables (Journal Line)
-- =========================
CREATE TABLE journal_line (
    line_id bigserial PRIMARY KEY,
    entry_id bigint NOT NULL REFERENCES journal_entry(entry_id),
    account_id bigint NOT NULL REFERENCES account(account_id),
    amount numeric NOT NULL,
    side normal_balance NOT NULL, -- 'DEBIT' o 'CREDIT'
    description text,
    cost_center_id bigint REFERENCES cost_center(cost_center_id),
    project_id bigint REFERENCES project(project_id),
    partner_id bigint REFERENCES partner(partner_id),
    currency_code char(3) REFERENCES currency(currency_code),
    amount_foreign numeric
);
