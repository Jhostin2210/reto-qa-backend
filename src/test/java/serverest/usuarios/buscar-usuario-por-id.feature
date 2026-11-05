@usuarios @buscar
Feature: GET /usuarios/{_id} - Buscar usuario por ID
  Como administrador del sistema
  Quiero buscar un usuario específico por su ID
  Para consultar su información

  Background:
    * url baseUrl
    * def idsCreados = []
    * configure afterScenario = limpiarUsuarios
    * def usuarioSchema = read('classpath:serverest/schemas/usuario.json')

  @smoke @positivo
  Scenario: Buscar un usuario existente por su ID retorna 200 y sus datos
    * def creado = crearUsuario()
    Given path 'usuarios', creado.id
    When method get
    Then status 200
    And match response == usuarioSchema
    And match response == karate.merge(creado.usuario, { _id: creado.id })

  @negativo
  Scenario: Buscar un ID con formato válido que no existe retorna 400
    Given path 'usuarios', DataGenerator.idInexistente()
    When method get
    Then status 400
    And match response == { message: '#(mensajes.usuarioNoEncontrado)' }

  @negativo
  Scenario: Buscar un usuario que fue eliminado retorna 400
    * def creado = crearUsuario()
    * call read('classpath:serverest/helpers/eliminar-usuario.feature') { id: '#(creado.id)' }
    Given path 'usuarios', creado.id
    When method get
    Then status 400
    And match response == { message: '#(mensajes.usuarioNoEncontrado)' }

  @negativo
  Scenario Outline: Buscar con un ID de formato inválido (<caso>) retorna 400
    Given path 'usuarios', '<id>'
    When method get
    Then status 400
    And match response == { id: '#(mensajes.idInvalido)' }

    Examples:
      | caso                       | id                  |
      | menos de 16 caracteres     | 123                 |
      | más de 16 caracteres       | ABCDEFGHIJKLMNOPQRS |
      | con caracteres especiales  | abcdefgh-ijklmno    |
