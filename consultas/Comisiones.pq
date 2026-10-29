let
    Origen = Movimientos,
    #"Personalizada agregada" = Table.AddColumn(Origen, "ES_Comisión", each Text.Contains([Concepto], "comisi", Comparer.OrdinalIgnoreCase)
or Text.Contains([Concepto], "charges", Comparer.OrdinalIgnoreCase)
or Text.Contains([Concepto], "fee", Comparer.OrdinalIgnoreCase)),
    #"Filas filtradas" = Table.SelectRows(#"Personalizada agregada", each ([ES_Comisión] = true)),
    #"Consultas combinadas" = Table.NestedJoin(#"Filas filtradas", {"Divisa"}, tTipos, {"Divisa"}, "tTipos", JoinKind.LeftOuter),
    #"Se expandió tTipos" = Table.ExpandTableColumn(#"Consultas combinadas", "tTipos", {"Unidades_por_EUR"}, {"tTipos.Unidades_por_EUR"}),
    #"Personalizada agregada1" = Table.AddColumn(#"Se expandió tTipos", "Comision_EUR", each Number.Round(-[Importe]/[tTipos.Unidades_por_EUR],2)),
    #"Filas agrupadas" = Table.Group(#"Personalizada agregada1", {"Banco"}, {{"Total_comisiones_EUR", each List.Sum([Comision_EUR]), type number}})
in
    #"Filas agrupadas"
