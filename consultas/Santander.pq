let
    Origen = Csv.Document(File.Contents("C:\PowerQuery-tesoreria\datos\Santander_ES.csv"),[Delimiter=";", Columns=5, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Encabezados promovidos" = Table.PromoteHeaders(Origen, [PromoteAllScalars=true]),
    #"Personalizada agregada" = Table.AddColumn(#"Encabezados promovidos", "Banco", each "Santander"),
    #"Columnas reordenadas" = Table.ReorderColumns(#"Personalizada agregada",{"Fecha", "Banco", "Cuenta", "Concepto", "Importe", "Divisa"}),
    #"Tipo cambiado con configuración regional" = Table.TransformColumnTypes(#"Columnas reordenadas", {{"Importe", type number}}, "es-ES"),
    #"Tipo cambiado con configuración regional1" = Table.TransformColumnTypes(#"Tipo cambiado con configuración regional", {{"Fecha", type date}}, "es-ES")
in
    #"Tipo cambiado con configuración regional1"
