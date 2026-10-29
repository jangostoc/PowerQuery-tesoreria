let
    Origen = Excel.Workbook(File.Contents("C:\PowerQuery-tesoreria\datos\Barclays_UK.xlsx"), null, true),
    Statement_Sheet = Origen{[Item="Statement",Kind="Sheet"]}[Data],
    #"Encabezados promovidos" = Table.PromoteHeaders(Statement_Sheet, [PromoteAllScalars=true]),
    #"Tipo cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos",{{"Barclays Business - Account statement", type any}, {"Column2", type text}, {"Column3", type text}, {"Column4", type any}, {"Column5", type any}, {"Column6", type text}}),
    #"Filas superiores quitadas" = Table.Skip(#"Tipo cambiado",2),
    #"Encabezados promovidos1" = Table.PromoteHeaders(#"Filas superiores quitadas", [PromoteAllScalars=true]),
    #"Tipo cambiado1" = Table.TransformColumnTypes(#"Encabezados promovidos1",{{"Date", type date}, {"Account", type text}, {"Description", type text}, {"Debit", type number}, {"Credit", type number}, {"Currency", type text}}),
    #"Personalizada agregada" = Table.AddColumn(#"Tipo cambiado1", "Importe", each (if[Credit]=null then 0 else [Credit])-(if[Debit]=null then 0 else [Debit])),
    #"Tipo cambiado2" = Table.TransformColumnTypes(#"Personalizada agregada",{{"Importe", type number}}),
    #"Columnas con nombre cambiado" = Table.RenameColumns(#"Tipo cambiado2",{{"Date", "Fecha"}, {"Account", "Cuenta"}, {"Description", "Concepto"}, {"Currency", "Divisa"}}),
    #"Otras columnas quitadas" = Table.SelectColumns(#"Columnas con nombre cambiado",{"Fecha", "Cuenta", "Concepto", "Divisa", "Importe"}),
    #"Personalizada agregada1" = Table.AddColumn(#"Otras columnas quitadas", "Banco", each "Barclays"),
    #"Columnas reordenadas" = Table.ReorderColumns(#"Personalizada agregada1",{"Fecha", "Banco", "Cuenta", "Concepto", "Importe", "Divisa"})
in
    #"Columnas reordenadas"
