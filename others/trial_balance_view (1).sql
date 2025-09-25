
CREATE OR REPLACE VIEW trial_balance AS
SELECT
    a.entity_id,
    fp.period_code,
    a.account_code,
    a.account_name,
    a.category,
    a.normal_side,
    SUM(CASE WHEN jl.side = 'DEBIT' THEN jl.amount ELSE 0 END) AS total_debit,
    SUM(CASE WHEN jl.side = 'CREDIT' THEN jl.amount ELSE 0 END) AS total_credit
FROM
    journal_line jl
    JOIN journal_entry je ON jl.entry_id = je.entry_id
    JOIN fiscal_period fp ON je.period_id = fp.period_id
    JOIN account a ON jl.account_id = a.account_id
WHERE
    a.is_postable = true
GROUP BY
    a.entity_id, fp.period_code, a.account_code, a.account_name, a.category, a.normal_side;
