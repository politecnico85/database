
-- Procedimiento para validar pruebas unitarias
CREATE OR REPLACE FUNCTION validate_unit_tests() RETURNS VOID AS $$
DECLARE
    test RECORD;
    actual_debit NUMERIC(18,2);
    actual_credit NUMERIC(18,2);
BEGIN
    FOR test IN SELECT * FROM UnitTestJournal LOOP
        -- Obtener débitos y créditos reales del JournalEntry correspondiente
        SELECT SUM(debit), SUM(credit)
        INTO actual_debit, actual_credit
        FROM JournalLine
        WHERE journal_entry_id = test.test_id;

        -- Comparar con valores esperados
        IF COALESCE(actual_debit, 0) = test.expected_debit AND COALESCE(actual_credit, 0) = test.expected_credit THEN
            UPDATE UnitTestJournal SET result = 'OK' WHERE test_id = test.test_id;
        ELSE
            UPDATE UnitTestJournal SET result = 'Error' WHERE test_id = test.test_id;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Ejecutar la función
SELECT validate_unit_tests();
