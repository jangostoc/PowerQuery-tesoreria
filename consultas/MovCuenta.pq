let
    Origen = Movimientos,
    #"Filas agrupadas" = Table.Group(Origen, {"Cuenta"}, {{"Movimientos", each List.Sum([Importe]), type nullable number}})
in
    #"Filas agrupadas"
