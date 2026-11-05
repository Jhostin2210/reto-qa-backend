@usuarios @listar
Feature: GET /usuarios - Listar usuarios
  Como administrador del sistema
  Quiero obtener la lista de usuarios registrados
  Para consultar y filtrar la base de datos de usuarios

  Background:
    * url baseUrl
    * def idsCreados = []
    * configure afterScenario = limpiarUsuarios
    * def usuarioSchema = read('classpath:serverest/schemas/usuario.json')
    * def listaSchema = read('classpath:serverest/schemas/lista-usuarios.json')

  @smoke @positivo
  Scenario: Listar todos los usuarios retorna 200 y cumple el esquema
    Given path 'usuarios'
    When method get
    Then status 200
    And match header Content-Type contains 'application/json'
    And match response == listaSchema
    And match response.quantidade == karate.sizeOf(response.usuarios)

  @positivo
  Scenario: Un usuario recién registrado aparece en el listado
    * def creado = crearUsuario()
    Given path 'usuarios'
    When method get
    Then status 200
    And match response.usuarios contains deep { _id: '#(creado.id)', email: '#(creado.usuario.email)' }

  @positivo
  Scenario: Filtrar por email retorna exactamente el usuario registrado
    * def creado = crearUsuario()
    Given path 'usuarios'
    And param email = creado.usuario.email
    When method get
    Then status 200
    And match response == listaSchema
    And match response.quantidade == 1
    And match response.usuarios[0] == karate.merge(creado.usuario, { _id: creado.id })

  @positivo
  Scenario: Filtrar por _id retorna únicamente ese usuario
    * def creado = crearUsuario()
    Given path 'usuarios'
    And param _id = creado.id
    When method get
    Then status 200
    And match response == listaSchema
    And match response.quantidade == 1
    And match response.usuarios[0]._id == creado.id

  @positivo
  Scenario Outline: Filtrar por administrador=<administrador> retorna solo usuarios de ese tipo
    * def creado = crearUsuario({ administrador: '<administrador>' })
    Given path 'usuarios'
    And param administrador = '<administrador>'
    When method get
    Then status 200
    And match response == listaSchema
    And match each response.usuarios contains { administrador: '<administrador>' }
    And match response.usuarios[*]._id contains creado.id

    Examples:
      | administrador |
      | true          |
      | false         |

  @positivo
  Scenario: Filtrar por un email no registrado retorna una lista vacía
    Given path 'usuarios'
    And param email = DataGenerator.emailUnico()
    When method get
    Then status 200
    And match response == { quantidade: 0, usuarios: [] }

  @negativo
  Scenario Outline: Filtrar con un parámetro inválido (<caso>) retorna 400
    Given path 'usuarios'
    And param <parametro> = '<valor>'
    When method get
    Then status 400
    And match response == { <parametro>: "<mensaje>" }

    Examples:
      | caso                       | parametro     | valor                 | mensaje                                  |
      | administrador no booleano  | administrador | si                    | administrador deve ser 'true' ou 'false' |
      | email con formato inválido | email         | correo-sin-arroba.com | email deve ser um email válido           |
      | parámetro no permitido     | rol           | admin                 | rol não é permitido                      |
