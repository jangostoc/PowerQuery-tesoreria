let
    Origen = Table.Combine({Chase_US, Barclays, Santander}),
    #"Tipo cambiado" = Table.TransformColumnTypes(Origen,{{"Fecha", type date}, {"Importe", type number}})
in
    #"Tipo cambiado"
