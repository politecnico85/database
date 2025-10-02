
package com.contabilidad.rules;

import com.contabilidad.model.AsientoContable;
import com.contabilidad.model.ProductoInventario;
import com.contabilidad.model.CuentaContable;

public class ReglaCompra implements ReglaContable {

    @Override
    public AsientoContable aplicar(String tipoTransaccion, double monto, ProductoInventario producto, CuentaContable cuentaDebito, CuentaContable cuentaCredito) {
        producto.agregarStock(10, monto / 10); // ejemplo: 10 unidades
        cuentaDebito.ajustarSaldo(monto);
        cuentaCredito.ajustarSaldo(-monto);

        return new AsientoContable(
            "Compra de " + producto.getNombre(),
            monto,
            cuentaDebito.getCodigo(),
            cuentaCredito.getCodigo()
        );
    }
}
