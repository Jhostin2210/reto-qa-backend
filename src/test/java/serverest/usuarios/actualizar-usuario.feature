@usuarios @actualizar
Feature: PUT /usuarios/{_id} - Actualizar usuario
  Como administrador del sistema
  Quiero actualizar la información de un usuario existente
  Para mantener la base de datos al día

  Background:
    * url baseUrl
    * def idsCreados = []
    * configure afterScenario = limpiarUsuarios
    * def usuarioSchema = read('classpath:serverest/schemas/usuario.json')
    * def registroSchema = read('classpath:serverest/schemas/registro-exitoso.json')

  @smoke @positivo
  Scenario: Actualizar todos los datos de un usuario existente retorna 200
    * def creado = crearUsuario({ administrador: 'true' })
    * def nuevosDatos = generarUsuario({ administrador: 'false' })
    Given path 'usuarios', creado.id
    And request nuevosDatos
    When method put
    Then status 200
    And match response == { message: '#(mensajes.registroAlterado)' }

    # Los cambios quedaron persistidos
    Given path 'usuarios', creado.id
    When method get
    Then status 200
    And match response == usuarioSchema
    And match response == karate.merge(nuevosDatos, { _id: creado.id })

  @positivo
  Scenario: Actualizar solo el nombre conservando el mismo email retorna 200
    * def creado = crearUsuario()
    * def nuevosDatos = karate.merge(creado.usuario, { nome: DataGenerator.nombre() })
    Given path 'usuarios', creado.id
    And request nuevosDatos
    When method put
    Then status 200
    And match response == { message: '#(mensajes.registroAlterado)' }

    Given path 'usuarios', creado.id
    When method get
    Then status 200
    And match response.nome == nuevosDatos.nome
    And match response.email == creado.usuario.email

  @positivo
  Scenario: Actualizar un ID inexistente registra un usuario nuevo y retorna 201
    * def usuario = generarUsuario()
    Given path 'usuarios', DataGenerator.idInexistente()
    And request usuario
    When method put
    Then status 201
    And match response == registroSchema
    And match response.message == mensajes.registroExitoso
    * karate.appendTo('idsCreados', response._id)

  @negativo
  Scenario: Actualizar con el email de otro usuario retorna 400
    * def usuarioA = crearUsuario()
    * def usuarioB = crearUsuario()
    * def nuevosDatos = generarUsuario({ email: usuarioB.usuario.email })
    Given path 'usuarios', usuarioA.id
    And request nuevosDatos
    When method put
    Then status 400
    And match response == { message: '#(mensajes.emailEnUso)' }

    # El usuario A no fue modificado
    Given path 'usuarios', usuarioA.id
    When method get
    Then status 200
    And match response.email == usuarioA.usuario.email

  @negativo
  Scenario Outline: Actualizar un usuario con <caso> retorna 400
    * def creado = crearUsuario()
    * def usuario = karate.merge(generarUsuario(), cambios)
    * if (remover) karate.remove('usuario', '$.' + remover)
    Given path 'usuarios', creado.id
    And request usuario
    When method put
    Then status 400
    And match response == respuestaEsperada

    Examples:
      | read('classpath:serverest/data/usuarios-invalidos.json') |
