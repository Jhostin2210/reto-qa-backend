@ignore
Feature: Helper - registrar un usuario vía POST /usuarios

  Scenario: Registrar usuario y devolver su id
    * def usuario = karate.get('usuario') || generarUsuario()
    Given url baseUrl
    And path 'usuarios'
    And request usuario
    When method post
    Then status 201
    * def id = response._id
