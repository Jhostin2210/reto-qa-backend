package serverest.helpers;

import net.datafaker.Faker;

import java.security.SecureRandom;
import java.util.Locale;
import java.util.UUID;

/**
 * Generador de datos de prueba. Se usa desde Karate con:
 *   * def DataGenerator = Java.type('serverest.helpers.DataGenerator')
 * (ya está expuesto globalmente en karate-config.js).
 */
public final class DataGenerator {

    private static final Faker FAKER = new Faker(Locale.forLanguageTag("es"));
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String ALFANUMERICO =
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    private DataGenerator() {
    }

    /** Nombre completo realista, p. ej. "María Fernández". */
    public static String nombre() {
        return FAKER.name().fullName();
    }

    /** Email único (timestamp + UUID) para no colisionar con datos existentes en la API pública. */
    public static String emailUnico() {
        String sufijo = UUID.randomUUID().toString().replace("-", "").substring(0, 10);
        return "qa.karate." + System.currentTimeMillis() + "." + sufijo + "@reto.com";
    }

    /** Password de 8 a 16 caracteres con mayúsculas y dígitos. */
    public static String password() {
        return FAKER.internet().password(8, 16, true, false, true);
    }

    /** Cadena alfanumérica aleatoria de la longitud indicada. */
    public static String alfanumerico(int longitud) {
        StringBuilder sb = new StringBuilder(longitud);
        for (int i = 0; i < longitud; i++) {
            sb.append(ALFANUMERICO.charAt(RANDOM.nextInt(ALFANUMERICO.length())));
        }
        return sb.toString();
    }

    /** ID con formato válido para ServeRest (16 alfanuméricos) que no existe en la base. */
    public static String idInexistente() {
        return alfanumerico(16);
    }

    /** Nombre único para productos de soporte (escenario de carrito). */
    public static String nombreProducto() {
        return "Producto QA " + FAKER.commerce().productName() + " " + alfanumerico(6);
    }
}
