
-- =========================
-- Asientos de cierre contable
-- =========================
-- Este script genera asientos que trasladan el resultado del periodo a una cuenta de patrimonio
-- Supone que existe una cuenta de cierre como 'Resultado del Ejercicio'

-- Ejemplo: procedimiento para generar asiento de cierre
CREATE OR REPLACE FUNCTION generate_closing_entry(p_entity_id bigint, p_period_id bigint, p_result_account_id bigint)
RETURNS void AS $$
DECLARE
    total_income numeric;
    total_expense numeric;
    net_result numeric;
    closing_entry_id bigint;
BEGIN
    -- Calcular ingresos
    SELECT SUM(jl.amount) INTO total_income
    FROM journal_line jl
    JOIN journal_entry je ON jl.entry_id = je.entry_id
    JOIN account a ON jl.account_id = a.account_id
    WHERE je.period_id = p_period_id AND a.category = 'REVENUE' AND jl.side = 'CREDIT';

    -- Calcular gastos
    SELECT SUM(jl.amount) INTO total_expense
    FROM journal_line jl
    JOIN journal_entry je ON jl.entry_id = je.entry_id
    JOIN account a ON jl.account_id = a.account_id
    WHERE je.period_id = p_period_id AND a.category = 'EXPENSE' AND jl.side = 'DEBIT';

    -- Resultado neto
    net_result := COALESCE(total_income, 0) - COALESCE(total_expense, 0);

    -- Crear asiento de cierre
    INSERT INTO journal_entry(entity_id, period_id, entry_date, description, source_module, is_posted)
    VALUES (p_entity_id, p_period_id, current_date, 'Cierre contable del periodo', 'CLOSING', true)
    RETURNING entry_id INTO closing_entry_id;

    -- Cierre de cuentas de ingresos
    INSERT INTO journal_line(entry_id, account_id, amount, side, description)
    SELECT closing_entry_id, a.account_id, jl.amount, 'DEBIT', 'Cierre ingreso'
    FROM journal_line jl
    JOIN journal_entry je ON jl.entry_id = je.entry_id
    JOIN account a ON jl.account_id = a.account_id
    WHERE je.period_id = p_period_id AND a.category = 'REVENUE' AND jl.side = 'CREDIT';

    -- Cierre de cuentas de gastos
    INSERT INTO journal_line(entry_id, account_id, amount, side, description)
    SELECT closing_entry_id, a.account_id, jl.amount, 'CREDIT', 'Cierre gasto'
    FROM journal_line jl
    JOIN journal_entry je ON jl.entry_id = je.entry_id
    JOIN account a ON jl.account_id = a.account_id
    WHERE je.period_id = p_period_id AND a.category = 'EXPENSE' AND jl.side = 'DEBIT';

    -- Traslado del resultado a cuenta de patrimonio
    IF net_result > 0 THEN
        INSERT INTO journal_line(entry_id, account_id, amount, side, description)
        VALUES (closing_entry_id, p_result_account_id, net_result, 'CREDIT', 'Resultado del ejercicio');
    ELSE
        INSERT INTO journal_line(entry_id, account_id, amount, side, description)
        VALUES (closing_entry_id, p_result_account_id, -net_result, 'DEBIT', 'Resultado del ejercicio');
    END IF;
END;
$$ LANGUAGE plpgsql;
