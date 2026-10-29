let
    Origen = Saldos_Cuenta,
    #"Filas agrupadas" = Table.Group(Origen, {"Sociedad", "Divisa"}, {{"Saldo", each List.Sum([Saldo_Final]), type nullable number}}),
    #"Consultas combinadas" = Table.NestedJoin(#"Filas agrupadas", {"Divisa"}, tTipos, {"Divisa"}, "tTipos", JoinKind.LeftOuter),
    #"Se expandió tTipos" = Table.ExpandTableColumn(#"Consultas combinadas", "tTipos", {"Unidades_por_EUR"}, {"Unidades_por_EUR"}),
    #"Personalizada agregada" = Table.AddColumn(#"Se expandió tTipos", "Saldo_EUR", each Number.Round([Saldo]/[Unidades_por_EUR],2))
in
    #"Personalizada agregada"
