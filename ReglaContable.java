
package com.contabilidad.rules;

import com.contabilidad.model.AsientoContable;
import com.contabilidad.model.ProductoInventario;
import com.contabilidad.model.CuentaContable;

@FunctionalInterface
public interface ReglaContable {
    AsientoContable aplicar(String tipoTransaccion, double monto, ProductoInventario producto, CuentaContable cuentaDebito, CuentaContable cuentaCredito);
}
