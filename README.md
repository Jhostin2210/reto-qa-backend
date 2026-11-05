# Reto QA Backend · API de Usuarios de ServeRest con Karate DSL

Suite de pruebas automatizadas para el CRUD de usuarios de [ServeRest](https://serverest.dev/) (`/usuarios`) con **Karate DSL 1.5** y **JUnit 5**.

| Endpoint | Operación | Feature |
|---|---|---|
| `GET /usuarios` | Listar y filtrar usuarios | `listar-usuarios.feature` |
| `POST /usuarios` | Registrar usuario | `registrar-usuario.feature` |
| `GET /usuarios/{_id}` | Buscar usuario por ID | `buscar-usuario-por-id.feature` |
| `PUT /usuarios/{_id}` | Actualizar usuario | `actualizar-usuario.feature` |
| `DELETE /usuarios/{_id}` | Eliminar usuario | `eliminar-usuario.feature` |
| Flujo completo | POST → GET → PUT → DELETE | `ciclo-vida-usuario.feature` |

**Cobertura:** 55 escenarios (casos positivos y negativos), validación de esquemas JSON en todas las respuestas exitosas, datos de prueba generados dinámicamente y limpieza automática de los datos creados.

---

## 1. Requisitos

| Herramienta | Versión | Verificar con |
|---|---|---|
| Java JDK | **17 o superior** (recomendado 21 LTS) | `java -version` |
| Maven | **No es necesario**: el proyecto incluye Maven Wrapper (`mvnw`) | — |
| Internet | Acceso a `serverest.dev` y a Maven Central | — |

> Si tienes Maven instalado puedes usar `mvn` en lugar de `mvnw`. Los comandos son los mismos.

## 2. Ejecutar las pruebas

Desde la carpeta del proyecto:

```bash
# Windows (PowerShell o CMD)
.\mvnw.cmd clean test

# Linux / macOS / Git Bash
./mvnw clean test
```

La primera ejecución descarga Maven y las dependencias, así que tarda unos minutos. Las siguientes tardan unos 30 segundos.

### Opciones útiles

| Qué | Comando (Windows; en Linux/macOS usa `./mvnw`) |
|---|---|
| Solo pruebas de humo | `.\mvnw.cmd test "-Dkarate.options=--tags @smoke"` |
| Solo casos negativos | `.\mvnw.cmd test "-Dkarate.options=--tags @negativo"` |
| Un endpoint específico | `.\mvnw.cmd test "-Dkarate.options=--tags @registrar"` |
| Un solo feature | `.\mvnw.cmd test "-Dkarate.options=classpath:serverest/usuarios/eliminar-usuario.feature"` |
| Cambiar número de hilos | `.\mvnw.cmd test -Dthreads=1` |
| ServeRest local | `npx serverest@latest` (en otra terminal) y luego `.\mvnw.cmd test -Dkarate.env=local` |
| Otra URL | `.\mvnw.cmd test -DbaseUrl=http://mi-servidor:3000` |

**Tags disponibles:** `@smoke`, `@positivo`, `@negativo`, `@e2e`, `@usuarios`, `@listar`, `@registrar`, `@buscar`, `@actualizar`, `@eliminar`.

Desde el IDE (IntelliJ o VS Code con Java) también puedes ejecutar `src/test/java/serverest/usuarios/UsuariosRunner.java`, que tiene un método por feature.

## 3. Reportes

Al terminar se generan:

- `target/karate-reports/karate-summary.html`: reporte HTML de Karate. Ábrelo en el navegador; cada request y response aparece con su detalle.
- `target/karate-reports/*.json`: reportes en formato Cucumber JSON, útiles para CI.
- `target/surefire-reports/`: reporte JUnit.
- `target/karate.log`: log completo de requests y responses.

## 4. Estructura del proyecto

```
backend-karate-serverest/
├── pom.xml                         # Dependencias (Karate, Datafaker) y plugins
├── mvnw / mvnw.cmd / .mvn/         # Maven Wrapper (no hace falta instalar Maven)
├── README.md
├── INFORME.md                      # Estrategia de automatización y patrones
└── src/test/java/
    ├── karate-config.js            # Configuración global: ambientes, timeouts y helpers globales
    ├── logback-test.xml            # Logging
    └── serverest/
        ├── ServeRestTest.java      # Runner paralelo (lo usa mvn test)
        ├── usuarios/               # Features: uno por endpoint + flujo E2E
        │   ├── UsuariosRunner.java # Runner para el IDE
        │   ├── listar-usuarios.feature
        │   ├── registrar-usuario.feature
        │   ├── buscar-usuario-por-id.feature
        │   ├── actualizar-usuario.feature
        │   ├── eliminar-usuario.feature
        │   └── ciclo-vida-usuario.feature
        ├── schemas/                # Esquemas JSON (fuzzy matching de Karate)
        │   ├── usuario.json
        │   ├── lista-usuarios.json
        │   ├── registro-exitoso.json
        │   └── mensaje.json
        ├── data/                   # Datos de prueba estáticos
        │   ├── mensajes.json       # Mensajes esperados de la API
        │   └── usuarios-invalidos.json  # Casos negativos (data-driven)
        └── helpers/                # Utilidades reutilizables
            ├── DataGenerator.java      # Generación de datos (Datafaker)
            ├── usuario-builder.js      # Builder de payloads de usuario
            ├── crear-usuario.js        # Crea un usuario y lo registra para limpieza
            ├── limpiar-usuarios.js     # Hook afterScenario que borra los usuarios creados
            ├── crear-usuario.feature   # @ignore: POST reutilizable
            ├── eliminar-usuario.feature# @ignore: DELETE reutilizable
            └── soporte-carrito.feature # @ignore: login, producto y carrito
```

## 5. Escenarios automatizados

<details>
<summary>Ver detalle (55 escenarios)</summary>

**GET /usuarios** (10)
- ✅ Listar todos: status 200, esquema válido y `quantidade` igual al tamaño de la lista.
- ✅ Un usuario recién creado aparece en el listado.
- ✅ Filtrar por `email` devuelve exactamente ese usuario.
- ✅ Filtrar por `_id` devuelve un único usuario.
- ✅ Filtrar por `administrador=true` y por `administrador=false` (outline).
- ✅ Filtrar por un email que no existe devuelve `{ quantidade: 0, usuarios: [] }`.
- ❌ Filtros inválidos (administrador no booleano, email mal formado, parámetro no permitido) devuelven 400.

**POST /usuarios** (17)
- ✅ Registrar un usuario administrador y uno común: 201, esquema válido y persistencia comprobada con GET.
- ❌ Email duplicado: 400.
- ❌ Body vacío: 400 con los 4 campos obligatorios.
- ❌ 13 casos data-driven desde `usuarios-invalidos.json`: campos ausentes, vacíos, tipos incorrectos, email inválido, administrador inválido y campo no permitido.

**GET /usuarios/{_id}** (6)
- ✅ Buscar un usuario existente: 200, esquema válido y datos iguales a los enviados.
- ❌ ID inexistente, usuario ya eliminado e ID con formato inválido (3 variantes): 400.

**PUT /usuarios/{_id}** (17)
- ✅ Actualizar todos los campos: 200 y persistencia comprobada.
- ✅ Actualizar solo el nombre conservando el email.
- ✅ PUT sobre un ID inexistente registra un usuario nuevo y devuelve 201 (comportamiento de *upsert* de ServeRest).
- ❌ Usar el email de otro usuario: 400, y el usuario original no cambia.
- ❌ Los 13 casos inválidos data-driven.

**DELETE /usuarios/{_id}** (4)
- ✅ Eliminar un usuario existente: 200, y luego GET devuelve 400.
- ❌ Eliminar un ID inexistente: 200 con "Nenhum registro excluído".
- ❌ Eliminar dos veces el mismo usuario.
- ❌ Usuario con carrito: 400 con `idCarrinho`, y el usuario sigue existiendo.

**E2E** (1)
- ✅ Ciclo de vida completo: registrar, listar, buscar, actualizar, eliminar y verificar.

</details>

## 6. Solución de problemas

| Problema | Solución |
|---|---|
| `'java' no se reconoce...` o `JAVA_HOME not found` | Instala un JDK 17+ (por ejemplo [Temurin 21](https://adoptium.net)) y define `JAVA_HOME` apuntando a la carpeta del JDK, **sin** `\bin`. Luego reabre la terminal. |
| `UnsupportedClassVersionError` | El JDK es menor a 17. Actualiza a 17 o 21. |
| Timeouts o `Connection refused` | `serverest.dev` está caído o hay un proxy bloqueando. Usa ServeRest local: `npx serverest@latest` y luego `-Dkarate.env=local`. |
| Caracteres raros (Ã©) en la consola | Es solo visual. Ejecuta `chcp 65001` antes del comando. |
| Proxy corporativo | `.\mvnw.cmd test -Dhttps.proxyHost=... -Dhttps.proxyPort=...` |
