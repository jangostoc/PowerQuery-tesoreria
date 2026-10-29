let
    Origen = Csv.Document(File.Contents("C:\PowerQuery-tesoreria\datos\Chase_US.csv"),[Delimiter=",", Columns=5, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Encabezados promovidos" = Table.PromoteHeaders(Origen, [PromoteAllScalars=true]),
    #"Columnas con nombre cambiado" = Table.RenameColumns(#"Encabezados promovidos",{{"Posting Date", "Fecha"}, {"Description", "Concepto"}}),
    #"Tipo cambiado con configuración regional" = Table.TransformColumnTypes(#"Columnas con nombre cambiado", {{"Fecha", type text}}, "en-US"),
    #"Columnas con nombre cambiado1" = Table.RenameColumns(#"Tipo cambiado con configuración regional",{{"Amount", "Importe"}}),
    #"Tipo cambiado con configuración regional1" = Table.TransformColumnTypes(#"Columnas con nombre cambiado1", {{"Importe", type number}}, "en-US"),
    #"Personalizada agregada" = Table.AddColumn(#"Tipo cambiado con configuración regional1", "Banco", each "Chase"),
    #"Personalizada agregada1" = Table.AddColumn(#"Personalizada agregada", "Cuenta", each "CHASE-4821"),
    #"Personalizada agregada2" = Table.AddColumn(#"Personalizada agregada1", "Divisa", each "USD"),
    #"Otras columnas quitadas" = Table.SelectColumns(#"Personalizada agregada2",{"Fecha", "Concepto", "Importe", "Banco", "Cuenta", "Divisa"}),
    #"Columnas reordenadas" = Table.ReorderColumns(#"Otras columnas quitadas",{"Fecha", "Banco", "Cuenta", "Concepto", "Importe", "Divisa"}),
    #"Tipo cambiado con configuración regional2" = Table.TransformColumnTypes(#"Columnas reordenadas", {{"Fecha", type date}}, "en-US")
in
    #"Tipo cambiado con configuración regional2"
