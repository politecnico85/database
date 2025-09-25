
CREATE OR REPLACE VIEW income_statement AS
SELECT
    a.entity_id,
    fp.period_code,
    a.account_code,
    a.account_name,
    a.category,
    SUM(CASE WHEN jl.side = 'DEBIT' THEN jl.amount ELSE 0 END) AS total_debit,
    SUM(CASE WHEN jl.side = 'CREDIT' THEN jl.amount ELSE 0 END) AS total_credit,
    SUM(CASE WHEN a.normal_side = 'DEBIT' THEN jl.amount ELSE -jl.amount END) AS net_amount
FROM
    journal_line jl
    JOIN journal_entry je ON jl.entry_id = je.entry_id
    JOIN fiscal_period fp ON je.period_id = fp.period_id
    JOIN account a ON jl.account_id = a.account_id
WHERE
    a.category IN ('REVENUE', 'EXPENSE', 'CONTRA_REVENUE', 'CONTRA_EXPENSE')
    AND a.is_postable = true
GROUP BY
    a.entity_id, fp.period_code, a.account_code, a.account_name, a.category;
