@usuarios @registrar
Feature: POST /usuarios - Registrar usuario
  Como administrador del sistema
  Quiero registrar nuevos usuarios con datos válidos
  Para que puedan utilizar la plataforma

  Background:
    * url baseUrl
    * def idsCreados = []
    * configure afterScenario = limpiarUsuarios
    * def usuarioSchema = read('classpath:serverest/schemas/usuario.json')
    * def registroSchema = read('classpath:serverest/schemas/registro-exitoso.json')

  @smoke @positivo
  Scenario Outline: Registrar un usuario <tipo> con datos válidos retorna 201
    * def usuario = generarUsuario({ administrador: '<administrador>' })
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 201
    And match response == registroSchema
    And match response.message == mensajes.registroExitoso
    * def idNuevo = response._id
    * karate.appendTo('idsCreados', idNuevo)

    # El usuario queda persistido con los mismos datos enviados
    Given path 'usuarios', idNuevo
    When method get
    Then status 200
    And match response == usuarioSchema
    And match response == karate.merge(usuario, { _id: idNuevo })

    Examples:
      | tipo          | administrador |
      | administrador | true          |
      | común         | false         |

  @negativo
  Scenario: Registrar un usuario con un email ya registrado retorna 400
    * def existente = crearUsuario()
    * def duplicado = generarUsuario({ email: existente.usuario.email })
    Given path 'usuarios'
    And request duplicado
    When method post
    Then status 400
    And match response == { message: '#(mensajes.emailEnUso)' }

  @negativo
  Scenario: Registrar un usuario con body vacío retorna 400 indicando todos los campos obligatorios
    Given path 'usuarios'
    And request {}
    When method post
    Then status 400
    And match response ==
      """
      {
        nome: 'nome é obrigatório',
        email: 'email é obrigatório',
        password: 'password é obrigatório',
        administrador: 'administrador é obrigatório'
      }
      """

  @negativo
  Scenario Outline: Registrar un usuario con <caso> retorna 400
    * def usuario = karate.merge(generarUsuario(), cambios)
    * if (remover) karate.remove('usuario', '$.' + remover)
    Given path 'usuarios'
    And request usuario
    When method post
    Then status 400
    And match response == respuestaEsperada

    Examples:
      | read('classpath:serverest/data/usuarios-invalidos.json') |
