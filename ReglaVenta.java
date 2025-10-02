
package com.contabilidad.rules;

import com.contabilidad.model.AsientoContable;
import com.contabilidad.model.ProductoInventario;
import com.contabilidad.model.CuentaContable;

public class ReglaVenta implements ReglaContable {

    @Override
    public AsientoContable aplicar(String tipoTransaccion, double monto, ProductoInventario producto, CuentaContable cuentaDebito, CuentaContable cuentaCredito) {
        producto.reducirStock(5); // ejemplo: venta de 5 unidades
        cuentaDebito.ajustarSaldo(monto);
        cuentaCredito.ajustarSaldo(-monto);

        return new AsientoContable(
            "Venta de " + producto.getNombre(),
            monto,
            cuentaDebito.getCodigo(),
            cuentaCredito.getCodigo()
        );
    }
}
