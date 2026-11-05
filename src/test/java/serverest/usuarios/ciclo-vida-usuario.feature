@usuarios @e2e
Feature: Ciclo de vida completo de un usuario (CRUD de punta a punta)
  Como administrador del sistema
  Quiero gestionar los usuarios a través de la API
  Para administrar la base de datos de usuarios

  Background:
    * url baseUrl
    * def idsCreados = []
    * configure afterScenario = limpiarUsuarios
    * def usuarioSchema = read('classpath:serverest/schemas/usuario.json')
    * def listaSchema = read('classpath:serverest/schemas/lista-usuarios.json')
    * def registroSchema = read('classpath:serverest/schemas/registro-exitoso.json')

  @smoke @positivo
  Scenario: Registrar, listar, buscar, actualizar y eliminar un usuario
    * def usuario = generarUsuario()

    # 1. Registrar (POST)
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 201
    And match response == registroSchema
    * def id = response._id
    * karate.appendTo('idsCreados', id)

    # 2. Listar filtrando por email (GET /usuarios)
    Given path 'usuarios'
    And param email = usuario.email
    When method get
    Then status 200
    And match response == listaSchema
    And match response.usuarios == [ '#(karate.merge(usuario, { _id: id }))' ]

    # 3. Buscar por ID (GET /usuarios/{_id})
    Given path 'usuarios', id
    When method get
    Then status 200
    And match response == usuarioSchema
    And match response.email == usuario.email

    # 4. Actualizar (PUT /usuarios/{_id})
    * def actualizado = generarUsuario({ administrador: 'false' })
    Given path 'usuarios', id
    And request actualizado
    When method put
    Then status 200
    And match response.message == mensajes.registroAlterado

    Given path 'usuarios', id
    When method get
    Then status 200
    And match response == karate.merge(actualizado, { _id: id })

    # 5. Eliminar (DELETE /usuarios/{_id})
    Given path 'usuarios', id
    When method delete
    Then status 200
    And match response.message == mensajes.registroEliminado

    Given path 'usuarios', id
    When method get
    Then status 400
    And match response.message == mensajes.usuarioNoEncontrado
