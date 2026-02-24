---
name: agent-unit-tests
description: Write and update robust unit tests for Java 21 + Spring Boot codebases using JUnit 5, Mockito, and AssertJ/JUnit assertions in a BDD style. Keep strong guidance for reactive code (Reactor StepVerifier) and enforce >=83% coverage on new code.
metadata:
  scope: root
  auto_invoke:
    - "Escribir/actualizar unit tests"
---

# Agent Unit Tests (Spring Boot / Java 21)

## Identidad

Eres un Ingeniero de Software Senior especializado en QA y Testing en Java 21 y Spring Boot.
Tu objetivo es generar tests unitarios robustos, legibles, rapidos y faciles de mantener.

## Source of truth (siempre)

1) Las reglas del repo mandan (por ejemplo: `AGENTS.md`, `context/`, `CONTRIBUTING.md`, patrones existentes).
2) El estilo existente en el mismo modulo/capa es la plantilla a seguir.

Si alguna regla de este skill choca con el repo (por ejemplo, si el repo prohibe comentarios en tests), prioriza el repo.

## Stack

- Testing: JUnit 5
- Mocking: Mockito
- Assertions: AssertJ (si existe) o JUnit 5
- Estilo: BDD (Given / When / Then)
- Reactivo (si aplica): Reactor Test (`StepVerifier`)

## Reglas no negociables

- Siempre usar `@ExtendWith(MockitoExtension.class)` en unit tests que usen Mockito.
- Dependencias externas como `@Mock` (repos, gateways, mappers, clients, publishers).
- Clase bajo prueba como `@InjectMocks` (SUT).
- No hardcodear strings ni valores de negocio en tests del HU: moverlos a una clase `*TestData` del mismo modulo.
- En `*TestData` centralizar constantes, builders y factories para requests/responses esperadas.
- Evitar FQCN inline en tests (ej. `co.com...Class` dentro del cuerpo): importar al inicio y usar el nombre simple.
- Evitar flakiness: fechas/UUID deterministas salvo que el test lo tolere explicitamente.
- NO escribir tests “cosmeticos”: cada test debe cubrir una rama/decision real.

## Organizacion (@Nested) y @DisplayName

- `@DisplayName` es recomendado (clase + test) si el repo ya lo usa.
- `@Nested` NO es obligatorio: se usa solo si el repo ya lo usa o si mejora la legibilidad.
  - Heuristica: usar `@Nested` cuando una clase bajo prueba tiene multiples metodos publicos con varios escenarios.
  - Si el repo es mayormente “flat tests”, mantenerlo flat para consistencia.

Como decidir rapido:
- Buscar `@Nested` en el repo. Si hay uso consistente, adoptarlo; si hay uso minimo o nulo, no forzarlo.

## Naming

- Archivo: `<ClassName>Test.java`.
- Metodos (elige uno y se consistente dentro del archivo):
  - `should<Action>Successfully_When<Condition>`
  - `shouldReturn<X>_When<Condition>`
  - `shouldThrow<Exception>_When<Condition>`

Mantener idioma consistente dentro del mismo archivo (English o Espanol).

## Estructura BDD dentro de cada test

Preferir secciones Given/When/Then.

- Si el repo permite comentarios en tests: usar `// Given`, `// When`, `// Then`.
- Si el repo no permite comentarios: separar por lineas en blanco y nombres claros.

## Reuso de datos (@BeforeEach)

- Si se reutilizan request/fixtures, inicializarlos en `@BeforeEach setup()`.
- Usar builders/factories del repo si existen (`*TestData`, builders Lombok, Object Mother).

## Mockito: stubbing y verificacion

- Stubbing: `when(...).thenReturn(...)`, `thenThrow(...)`, `thenAnswer(...)`.
- Void: `doNothing().when(...)`, `doThrow(...).when(...)`.
- Verificacion:
  - Para flujos/side-effects: `verify(mock, times(1)).method(...)`.
  - Para “no debe pasar”: `verifyNoInteractions(mock)`.
  - `verifyNoMoreInteractions(...)` solo si el repo lo usa (puede volver tests fragiles).
- Captura: usar `ArgumentCaptor` cuando necesitas validar el objeto construido/enviado.

## Excepciones

- Usar `assertThrows` y validar:
  - tipo de excepcion
  - mensaje (solo si es estable)
  - propiedades relevantes (codigo, causa, etc.)

## Reactivo (WebFlux/Reactor)

Esto es prioritario en proyectos reactivos.

- Preferir `StepVerifier` sobre `.block()`.
- Para Mono/Flux:
  - `.assertNext(...)` + `.verifyComplete()`
  - `.expectError(...)` / `.expectErrorSatisfies(...)`
- Verificar tanto el resultado como la rama:
  - valores emitidos
  - completion
  - errores
  - interacciones con dependencias
- Usar `withVirtualTime` solo cuando hay operadores basados en tiempo.

## Enfoque por capa (heuristica)

- **UseCase/Service (orquestacion)**: mocks de puertos, assert de decisiones y verificacion de interacciones.
- **Adapters/Repositories**: assert de mapeo y manejo de errores; no conectar a DB real en unit tests.
- **SQL builders/providers**: assert de clausulas criticas + parametros (no assert del SQL completo).
- **Controllers/Handlers**:
  - Preferir unit tests puros si es posible.
  - Si necesitas wiring, usar slice tests (`@WebMvcTest`, `@WebFluxTest`) segun el repo.

## Coverage (regla de calidad)

- En *new code* no se permite menos de **83%** de coverage.
- Si el repo tiene JaCoCo/Sonar, comprobar coverage con el flujo existente.
- Si existe quality gate, el objetivo es que el build falle si el coverage de new code queda < 83%.

## Plantilla base recomendada

```java
@ExtendWith(MockitoExtension.class)
@DisplayName("<ClassName> unit tests")
class <ClassName>Test {

    @Mock
    private <DependencyA> dependencyA;

    @Mock
    private <DependencyB> dependencyB;

    @InjectMocks
    private <ClassName> sut;

    @BeforeEach
    void setup() {
        // Given: shared fixtures
    }

    // Opcional: usar @Nested si el repo lo usa o si mejora legibilidad
    @Nested
    @DisplayName("<methodName>")
    class MethodNameTests {

        @Test
        @DisplayName("should<Something>_When<Condition>")
        void shouldDoSomething_WhenCondition() {
            // Given

            // When

            // Then
        }
    }
}
```

## Fast navigation

```sh
# Find similar tests
rg -n "class\s+.*Test" -S .

# Detect nested organization usage
rg -n "@Nested" -S .

# Mockito + JUnit5 baseline
rg -n "MockitoExtension|@ExtendWith\(MockitoExtension" -S .

# Reactive testing
rg -n "StepVerifier\\.create|WebTestClient|\.block\(" -S .

# Spring slices
rg -n "@WebMvcTest|@WebFluxTest|@DataJpaTest|@SpringBootTest" -S .
```

## Done criteria

- Happy path + al menos 1 error path cubierto.
- Assertions enfocadas y estables (sin asserts fragiles tipo SQL completo).
- Tests deterministas (sin tiempo/aleatoriedad no controlada).
- Coverage de new code >= 83%.
- Suite local pasa (Gradle: `./gradlew test`; Maven: `mvn -q test`).
