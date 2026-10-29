let
    Origen = Excel.CurrentWorkbook(){[Name="tCuentas"]}[Content],
    #"Tipo cambiado" = Table.TransformColumnTypes(Origen,{{"Cuenta", type text}, {"Banco", type text}, {"Sociedad", type text}, {"Divisa", type text}, {"Saldo_inicial", type number}})
in
    #"Tipo cambiado"
