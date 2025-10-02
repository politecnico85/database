
package com.contabilidad.service;

import com.contabilidad.model.AsientoContable;
import com.contabilidad.model.CuentaContable;
import com.contabilidad.model.ProductoInventario;
import com.contabilidad.rules.ReglaContable;
import com.contabilidad.rules.ReglaCompra;
import com.contabilidad.rules.ReglaVenta;
import com.contabilidad.rules.ReglaAjuste;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OrquestadorContableService {

    @Autowired
    private ProductoInventarioService productoInventarioService;

    @Autowired
    private CuentaContableService cuentaContableService;

    @Autowired
    private AsientoContableService asientoContableService;

    public AsientoContable procesarTransaccion(String tipoTransaccion, double monto, Long productoId,
                                               String cuentaDebitoCodigo, String cuentaCreditoCodigo) {

        ProductoInventario producto = productoInventarioService.obtenerPorId(productoId);
        CuentaContable cuentaDebito = cuentaContableService.obtenerPorCodigo(cuentaDebitoCodigo);
        CuentaContable cuentaCredito = cuentaContableService.obtenerPorCodigo(cuentaCreditoCodigo);

        ReglaContable regla;

        switch (tipoTransaccion.toUpperCase()) {
            case "COMPRA":
                regla = new ReglaCompra();
                break;
            case "VENTA":
                regla = new ReglaVenta();
                break;
            case "AJUSTE":
                regla = new ReglaAjuste();
                break;
            default:
                throw new IllegalArgumentException("Tipo de transacción no soportado: " + tipoTransaccion);
        }

        AsientoContable asiento = regla.aplicar(tipoTransaccion, monto, producto, cuentaDebito, cuentaCredito);

        productoInventarioService.actualizar(producto);
        cuentaContableService.actualizar(cuentaDebito);
        cuentaContableService.actualizar(cuentaCredito);
        asientoContableService.registrar(asiento);

        return asiento;
    }
}
