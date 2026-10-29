let
    Origen = tCuentas,
    #"Consultas combinadas" = Table.NestedJoin(Origen, {"Cuenta"}, MovCuenta, {"Cuenta"}, "MovCuenta", JoinKind.LeftOuter),
    #"Se expandió MovCuenta" = Table.ExpandTableColumn(#"Consultas combinadas", "MovCuenta", {"Movimientos"}, {"Movimientos"}),
    #"Valor reemplazado" = Table.ReplaceValue(#"Se expandió MovCuenta",null,0,Replacer.ReplaceValue,{"Movimientos"}),
    #"Personalizada agregada" = Table.AddColumn(#"Valor reemplazado", "Saldo_Final", each [Saldo_inicial]+[Movimientos]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Personalizada agregada",{{"Saldo_Final", type number}})
in
    #"Tipo cambiado"
