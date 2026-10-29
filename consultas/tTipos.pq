let
    Origen = Excel.CurrentWorkbook(){[Name="tTipos"]}[Content],
    #"Tipo cambiado" = Table.TransformColumnTypes(Origen,{{"Divisa", type text}, {"Unidades_por_EUR", type number}})
in
    #"Tipo cambiado"
