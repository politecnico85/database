from decimal import Decimal
from domain.aggregates.nota_credito_aggregate import NotaCreditoAggregate
from domain.repositories.nota_credito_repository import NotaCreditoRepository
from domain.repositories.factura_repository import FacturaRepository
from domain.services.inventario_service import InventarioService
from domain.specifications.nota_credito_specifications import LineasValidasContraFactura

class NotaCreditoService:
    def __init__(self, nc_repo: NotaCreditoRepository, factura_repo: FacturaRepository, inventario_service: InventarioService):
        self.nc_repo = nc_repo
        self.factura_repo = factura_repo
        self.inventario_service = inventario_service

    def crear_y_emitir_nota_credito(self, datos: dict) -> NotaCreditoAggregate:
        factura_agg = self.factura_repo.obtener_por_id(datos['id_factura_modificada'])
        if not factura_agg:
            raise ValueError("Factura no existe.")

        aggregate = NotaCreditoAggregate.crear_nueva(**datos)
        linea = LineaNotaCredito(
            id_producto=1,
            descripcion="Devolución Prod1",
            cantidad=2,
            valor_item_cobrado=Decimal('10.00')
        )
        aggregate.agregar_linea(linea)

        if not LineasValidasContraFactura(factura_agg).is_satisfied_by(aggregate.root):
            raise ValueError("Líneas exceden cantidades de factura original.")

        movimientos = aggregate.emitir(self.inventario_service, factura_agg.root.id_bodega, factura_agg)
        self.nc_repo.guardar(aggregate)
        return aggregate