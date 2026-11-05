# Informe · Estrategia de automatización (Backend, Karate DSL)

## 1. Alcance y enfoque

El objetivo es validar la historia de usuario *"Como administrador quiero gestionar los usuarios a través de la API"* sobre los 5 endpoints de `/usuarios` de ServeRest. Cada criterio de aceptación tiene su propio feature con escenarios positivos y negativos. Además, un flujo E2E recorre el ciclo de vida completo del recurso.

| Criterio de aceptación | Feature | Positivos | Negativos |
|---|---|---|---|
| Obtener la lista de usuarios | `listar-usuarios` | 7 | 3 |
| Registrar usuario con datos válidos | `registrar-usuario` | 2 | 15 |
| Buscar usuario por ID | `buscar-usuario-por-id` | 1 | 5 |
| Actualizar usuario existente | `actualizar-usuario` | 3 | 14 |
| Eliminar usuario | `eliminar-usuario` | 1 | 3 |
| Flujo completo | `ciclo-vida-usuario` | 1 | – |

Para los negativos se aplicaron técnicas de diseño de pruebas:

- **Partición de equivalencia:** campos ausentes, vacíos, con tipo incorrecto, con formato inválido o no permitidos.
- **Valores límite** del ID: menos de 16, más de 16 y exactamente 16 caracteres pero con símbolos.
- **Transiciones de estado:** buscar o eliminar un usuario ya eliminado.
- **Reglas de negocio:** email único, upsert en PUT y prohibición de eliminar un usuario que tiene carrito.

## 2. Patrones y decisiones de diseño

| Patrón | Dónde | Por qué |
|---|---|---|
| **Un feature por endpoint** | `serverest/usuarios/*.feature` | Cada archivo corresponde a un criterio de aceptación. Así es fácil ubicar y mantener las pruebas. |
| **Configuración centralizada por ambiente** | `karate-config.js` | La URL se elige con `karate.env` (`qa`, `local`) o `-DbaseUrl`. Los timeouts y los helpers son globales. |
| **Esquemas JSON reutilizables** | `serverest/schemas/*.json` | Validación estructural con el *fuzzy matching* de Karate (`#string`, `#regex`, `#[] schema`, `#number? _ >= 0`). Un cambio de contrato se corrige en un solo lugar. |
| **Builder de datos de prueba** | `usuario-builder.js` + `DataGenerator.java` | `generarUsuario({ administrador: 'false' })` crea un payload válido y único. Solo se sobrescribe lo que importa al escenario. Datafaker genera nombres y passwords realistas, y el email combina timestamp con UUID para que no choque con datos de otros usuarios de la API pública. |
| **Data-driven testing** | `usuarios-invalidos.json` + `Scenario Outline` dinámico | Los 13 casos inválidos están en un JSON y se reutilizan en POST y en PUT. Agregar un caso no requiere tocar código. |
| **Mensajes esperados externalizados** | `data/mensajes.json` | Evita textos repetidos en los features. Si la API cambia un mensaje, se cambia una sola vez. |
| **Helpers reutilizables (llamadas a features)** | `helpers/*.feature` con `@ignore` | Las precondiciones (crear usuario, login, producto, carrito) se resuelven vía API con `call`, no repitiendo pasos. |
| **Setup y teardown automáticos** | `crearUsuario()` + `configure afterScenario = limpiarUsuarios` | Todo usuario creado se registra en `idsCreados` y se elimina al final del escenario, aunque haya fallado. El escenario de carrito agrega su propia limpieza: cancelar carrito, borrar producto y borrar usuario. |
| **Escenarios independientes** | Todos | Cada escenario crea sus propios datos y no depende del orden ni de datos existentes. Esto permite la **ejecución en paralelo** (4 hilos por defecto). |
| **Verificación de persistencia** | POST, PUT, DELETE | Además del status y del mensaje, se consulta el recurso con GET para confirmar el efecto real. |

## 3. Validaciones aplicadas en cada respuesta

1. **Status code** exacto.
2. **Esquema JSON** (tipos, formato del `_id` de 16 alfanuméricos y `administrador` limitado a `"true"` o `"false"`).
3. **Contenido**: el mensaje exacto y los datos devueltos iguales a los enviados (`match response == karate.merge(usuario, { _id: id })`).
4. **Consistencia**: `quantidade == usuarios.length`, y todos los filtrados cumplen el filtro (`match each`).
5. **Errores**: el body de error debe ser exactamente `{ campo: mensaje }`, sin claves extra.

## 4. Hallazgos sobre el comportamiento de la API

Se documentan como pruebas porque son reglas de negocio de ServeRest:

- `PUT` con un ID inexistente **crea** un usuario (201) en lugar de devolver 404.
- `DELETE` con un ID inexistente responde **200** con "Nenhum registro excluído", no 404.
- Los "no encontrado" responden **400**, no 404.
- `administrador` es un string (`"true"`/`"false"`). El booleano `true` se rechaza.

## 5. Ejecución y reportes

- `mvnw test` ejecuta `ServeRestTest`, que corre la suite en paralelo y falla el build si algún escenario falla. Así se integra directo a CI (se incluye `.github/workflows/karate.yml`).
- Reportes: HTML de Karate, Cucumber JSON y JUnit XML en `target/`.
- Filtrado por tags: `@smoke`, `@positivo`, `@negativo`, `@e2e` y uno por endpoint.

## 6. Posibles mejoras

- Validar contra la especificación OpenAPI/Swagger de ServeRest (por ejemplo con `json-schema-validator`).
- Pruebas de rendimiento reutilizando los mismos features con Karate-Gatling.
- Publicar el reporte HTML en GitHub Pages desde el pipeline.
