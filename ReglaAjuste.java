
package com.contabilidad.rules;

import com.contabilidad.model.AsientoContable;
import com.contabilidad.model.ProductoInventario;
import com.contabilidad.model.CuentaContable;

public class ReglaAjuste implements ReglaContable {

    @Override
    public AsientoContable aplicar(String tipoTransaccion, double monto, ProductoInventario producto, CuentaContable cuentaDebito, CuentaContable cuentaCredito) {
        producto.agregarStock(2, producto.getValorUnitario()); // ejemplo: ajuste de inventario
        cuentaDebito.ajustarSaldo(monto);
        cuentaCredito.ajustarSaldo(-monto);

        return new AsientoContable(
            "Ajuste de inventario para " + producto.getNombre(),
            monto,
            cuentaDebito.getCodigo(),
            cuentaCredito.getCodigo()
        );
    }
}
