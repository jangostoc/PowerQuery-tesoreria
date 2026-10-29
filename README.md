# Power Query para tesorería · Posición de caja de un grupo internacional

Proyecto de **Power Query en Excel** aplicado al trabajo de un **analista de tesorería**: unificar extractos bancarios de varios bancos y países, calcular la posición de caja del grupo por sociedad y divisa, convertirla a euros y revisar las comisiones bancarias.

> **English summary.** Excel Power Query model that consolidates bank statements from three banks in three different formats (Spain, UK, US), computes the group cash position by entity and currency, converts it to EUR with an FX table, and reviews bank fees. All data is fictitious.

## El caso

**Entertainment Forever** es un grupo ficticio de ocio en vivo con tres sociedades: España, Reino Unido y Estados Unidos. Al cierre del viernes 24/10/2026, tesorería necesita la **posición de caja del grupo** a partir de los extractos de la semana, que llegan de cada banco en un formato distinto:

| Fichero | Banco | Sociedad | Retos del formato |
|---|---|---|---|
| [`Santander_ES.csv`](datos/Santander_ES.csv) | Santander | Entertainment Forever España SL (cuentas en EUR y USD) | Separador `;`, decimales con coma y miles con punto, fecha dd/mm/aaaa |
| [`Barclays_UK.xlsx`](datos/Barclays_UK.xlsx) | Barclays | Entertainment Forever UK Ltd (cuentas en GBP y EUR) | Filas de título encima de la tabla; columnas *Debit* y *Credit* separadas en lugar de un importe con signo |
| [`Chase_US.csv`](datos/Chase_US.csv) | Chase | Entertainment Forever USA Inc (una cuenta en USD) | Separador `,`, fecha mm/dd/aaaa; el fichero no indica la cuenta ni la divisa |

El libro [`libro/Tesoreria_PowerQuery.xlsx`](libro/Tesoreria_PowerQuery.xlsx) contiene además dos tablas maestras:

- **tCuentas**: cuenta, banco, sociedad, divisa y saldo inicial a 19/10/2026.
- **tTipos**: tipos de cambio (unidades de divisa por 1 EUR).

## El flujo

```
Santander_ES.csv ──► Santander ──┐
Barclays_UK.xlsx ──► Barclays  ──┼──► Movimientos ──► MovCuenta ──┐
Chase_US.csv     ──► Chase_US  ──┘        │                       ▼
                                          │       tCuentas ──► Saldos_Cuenta ──► PosicionCaja ◄── tTipos
                                          │                                                      │
                                          └──────────────────────► Comisiones ◄──────────────────┘
```

1. **Una consulta por banco** limpia su formato y lo lleva a las mismas 6 columnas: `Fecha · Banco · Cuenta · Concepto · Importe · Divisa`, con importe positivo para cobros y negativo para pagos.
2. **Movimientos** anexa los tres extractos en una única tabla.
3. **MovCuenta** suma los movimientos de la semana por cuenta.
4. **Saldos_Cuenta** parte de tCuentas, cruza con MovCuenta y calcula `Saldo_final = Saldo_inicial + Movimientos`.
5. **PosicionCaja** agrupa por sociedad y divisa, cruza con tTipos y convierte a EUR.
6. **Comisiones** filtra los cargos bancarios y suma su coste en EUR por banco.

## Las consultas

El código M de cada consulta está en [`consultas/`](consultas/):

| Consulta | Qué hace |
|---|---|
| [Santander](consultas/Santander.pq) | Lee el CSV español con `;` y añade la columna Banco |
| [Barclays](consultas/Barclays.pq) | Quita las filas de título, tipa columnas y calcula `Importe = Credit − Debit` |
| [Chase_US](consultas/Chase_US.pq) | Convierte fechas e importes con configuración regional `en-US` y añade Cuenta y Divisa, que el fichero no trae |
| [Movimientos](consultas/Movimientos.pq) | Anexa los tres extractos |
| [tCuentas](consultas/tCuentas.pq) · [tTipos](consultas/tTipos.pq) | Cargan las tablas maestras del propio libro |
| [MovCuenta](consultas/MovCuenta.pq) | Suma de movimientos por cuenta |
| [Saldos_Cuenta](consultas/Saldos_Cuenta.pq) | Saldo inicial + movimientos = saldo final por cuenta |
| [PosicionCaja](consultas/PosicionCaja.pq) | Saldo por sociedad y divisa, convertido a EUR |
| [Comisiones](consultas/Comisiones.pq) | Comisiones bancarias por banco en EUR |

## Resultados

**Posición de caja a 24/10/2026**

| Sociedad | Divisa | Saldo | Unidades por EUR | Saldo en EUR |
|---|---|---:|---:|---:|
| Entertainment Forever España SL | EUR | 886.580,65 | 1,0000 | 886.580,65 |
| Entertainment Forever España SL | USD | 161.665,00 | 1,0850 | 149.000,00 |
| Entertainment Forever UK Ltd | EUR | 66.250,00 | 1,0000 | 66.250,00 |
| Entertainment Forever UK Ltd | GBP | 469.989,80 | 0,8420 | 558.182,66 |
| Entertainment Forever USA Inc | USD | 1.256.110,85 | 1,0850 | 1.157.705,85 |
| **Total grupo** | | | | **2.817.719,16** |

**Comisiones bancarias de la semana**

| Banco | Total en EUR |
|---|---:|
| Santander | 166,87 |
| Barclays | 101,66 |
| Chase | 32,26 |
| **Total** | **300,79** |

**Controles de cuadre**

- El saldo final calculado de la cuenta de Chase (1.256.110,85 USD) coincide con el saldo que informa el propio banco en la columna *Balance* del extracto.
- La transferencia intragrupo de 50.000 EUR de España a Reino Unido aparece como pago en Santander y como cobro en Barclays, y se compensa en el total del grupo.

## Puntos técnicos

- **Configuración regional.** La misma cadena `10/23/2026` es una fecha válida en `en-US` y un error en `es-ES`, y `245.320,50` solo es un número en formato español. Por eso las fechas e importes se convierten en la consulta de cada banco con su configuración regional (`es-ES` para Santander, `en-US` para Chase), antes de anexar.
- **Debit y Credit en un extracto.** Están escritos desde el punto de vista del banco: *credit* es dinero que entra en la cuenta y *debit* dinero que sale. Por eso `Importe = Credit − Debit`, sustituyendo los `null` por 0.
- **Búsqueda sin distinguir mayúsculas.** El filtro de comisiones usa `Text.Contains(..., Comparer.OrdinalIgnoreCase)`, porque Chase escribe `WIRE TRANSFER FEE` en mayúsculas y un filtro "Contiene fee" normal no lo encuentra.
- **Referencias en lugar de duplicados.** Las consultas de cálculo parten de Movimientos y de tCuentas con *Referencia*, así que cualquier cambio en el origen se propaga solo.

## Cómo usarlo

1. Descarga el repositorio y colócalo en `C:\PowerQuery-tesoreria\`, de forma que los extractos queden en `C:\PowerQuery-tesoreria\datos\`.
2. Abre `libro/Tesoreria_PowerQuery.xlsx` y pulsa **Datos → Actualizar todo**.
3. Para usar otra carpeta, cambia la ruta en el paso *Origen* de las consultas Santander, Barclays y Chase_US (**Datos → Obtener datos → Iniciar el Editor de Power Query**).

Para regenerar los extractos: `python datos/generar_datos.py` (necesita `openpyxl`).

## Posibles mejoras

- Guardar la ruta de la carpeta en un **parámetro** para no editar cada consulta.
- Leer cada banco **desde una carpeta** para procesar varias semanas de extractos de golpe.
- Sustituir el filtro de comisiones por palabras por una **tabla de reglas** (banco + texto → categoría) o por los códigos de transacción de los formatos MT940 / camt.053, y comparar lo cobrado con lo pactado en contrato.

---

*Todos los datos son ficticios. Entertainment Forever es una empresa inventada para el ejercicio.*
