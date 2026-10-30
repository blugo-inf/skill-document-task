---
name: document-task
description: Actualiza y genera la documentación de un repo (AGENTS.md, docs/, ADRs, gotchas, reglas de negocio, diagramas Mermaid) a partir de lo que se hizo en la tarea, con la estructura óptima para que la lean agentes y devs nuevos. Usala siempre al terminar una tarea, antes de abrir o cerrar un PR, cuando se tomó una decisión de diseño con alternativas, cuando apareció un gotcha o una regla de negocio no obvia, y cuando el usuario diga "documentá", "actualizá la documentación", "dejá esto documentado", "/document-task" o "armá el AGENTS.md", aunque no mencione la palabra skill.
---

# document-task

Mantiene la documentación del repo como subproducto del trabajo diario. El objetivo es que un agente (o un dev que nunca tocó el proyecto) pueda entender cómo funciona y **por qué** se decidió cada cosa, sin consumir tiempo del equipo en inducción.

## Principios (el porqué de las reglas de abajo)

1. **Documentá solo lo que el código no puede decir.** Un agente deduce solo la estructura, las firmas y los endpoints. No deduce las reglas de negocio, las decisiones, los motivos ni las trampas. Test para cada línea que pensés escribir: *"si un agente tocara este código sin este dato, ¿cometería un error que compila y pasa los tests?"*. Si no, no la escribas.
2. **El porqué lo sabe una persona, no vos.** Nunca inventes motivos de decisiones ni reglas de negocio. Un porqué inventado que suena bien es peor que no tener nada, porque el agente lo trata como verdad. Preguntale al dev.
3. **Un doc desactualizado es peor que no tener doc.** Preferí poco y correcto. Corregí lo que leíste y estaba viejo.
4. **Lo generado no se escribe a mano.** Los contratos de API (endpoints, schemas) los produce el build de Zeus como JSON y se publican en el catálogo de GitLab Pages. Enlazá, no copies.
5. **El contexto del agente es escaso.** `AGENTS.md` se carga siempre, así que debe ser corto y funcionar como índice. El detalle vive en `docs/` y se lee bajo demanda.

## Flujo

### 1. Entender qué cambió
- Revisá `git diff` (y `git log` de la rama) más lo conversado en la sesión.
- Listá: comportamiento cambiado, integraciones nuevas o modificadas, decisiones tomadas, problemas que costó resolver, términos de negocio que aparecieron.
- Si la tarea no cambió nada relevante (refactor interno, typo, ajuste menor), decilo y **no toques nada**. Terminar acá es un resultado válido.

### 2. Leer lo que ya existe
- Leé el `AGENTS.md` y el `docs/` actuales antes de escribir. Respetá su formato y estilo: el equipo dueño ya lo adoptó.
- Si el repo no tiene `AGENTS.md`, creá uno mínimo con `references/templates.md` (sección "AGENTS.md mínimo") y completalo solo con lo deducible del código, marcando lo no verificado.
- Si el `AGENTS.md` es muy largo (más de ~150 líneas), proponé mover el detalle a `docs/` y dejarlo como índice.

### 3. Decidir dónde va cada cosa

| Qué es | Dónde |
|---|---|
| Comandos de build/test/run, estructura, reglas del repo | `AGENTS.md` (corto) |
| Reglas de negocio, glosario, invariantes, estados y transiciones | `docs/domain.md` |
| Decisión con alternativas descartadas | `docs/decisions/NNN-titulo.md` (ADR) |
| Trampa, comportamiento no obvio, caso borde histórico | `docs/gotchas.md` |
| Flujo entre componentes o servicios | `docs/overview.md` con diagrama Mermaid + texto |
| Contratos de API (endpoints, schemas, parámetros) | **No se documenta**: lo genera Zeus; enlazar al catálogo |
| Afecta a otros repos del proyecto o a toda la plataforma | No lo edites desde acá: agregalo a "Pendiente para otras capas" en el resumen final |

Un doc por tema. Si un hecho ya está escrito en otro lugar, enlazalo en vez de duplicarlo.

### 4. Escribir
Usá las plantillas de `references/templates.md`. Reglas de redacción:

- **Proponé cambios como diff sobre lo existente.** No reescribas archivos completos.
- **Frases cortas, concretas y accionables.** Preferí "No uses X para Y; usá Z porque ..." a un párrafo narrativo.
- **Un ejemplo concreto vale más que una explicación.** Apuntá a un archivo de referencia (`src/.../Foo.java`) o a un snippet breve.
- **Diagramas Mermaid con moderación.** Uno por concepto, pocos nodos. Sirven para flujos (secuencia), estados y relaciones. Siempre acompañalos de texto con las reglas, excepciones y motivos, porque el diagrama no los expresa. Mantenelos en el mismo archivo que el contexto que explican.
- **En el índice, cada link dice cuándo leerlo, en términos de tarea.** Bien: "`docs/gotchas.md`: leelo si algo falla de forma rara o antes de cambiar el manejo de errores". Mal: "información sobre gotchas".
- **Rutas y nombres reales, nunca placeholders.** Verificá que los archivos y clases que mencionás existen.
- **Marcá lo no verificado** con `> Borrador: sin verificar` para que nadie lo tome como verdad.
- **Sellá la frescura** de los docs profundos con `Última verificación: AAAA-MM-DD (commit abc1234)` al final. Permite detectar drift después.

### 5. Preguntar lo que falta
Antes de cerrar, hacele al dev **como máximo 3 preguntas** sobre lo que solo él sabe: el motivo de una decisión, la regla de negocio detrás de un `if`, qué alternativas se descartaron. Si no responde, dejá el item como Borrador. No bloquees el cierre por esto.

### 6. Conexión con otras capas
- `AGENTS.md` debe tener una sección "Contexto superior" con: link a la documentación del proyecto (flujo entre repos, dominio compartido) y link al catálogo de APIs, cada uno con su condición de lectura. Si esa sección falta, agregala con los links que el dev confirme; no inventes URLs.
- Si el repo expone o consume APIs, verificá que `AGENTS.md` diga el equipo dueño y de qué otras APIs depende (los JSON de Zeus describen contratos, pero no siempre responsabilidades ni dependencias).

### 7. Cerrar con un resumen
Terminá con un resumen breve:
- Archivos creados o modificados y por qué.
- Items marcados como Borrador que necesitan validación humana.
- Preguntas sin responder.
- **Pendiente para otras capas**: cambios que deberían reflejarse en la doc del proyecto o de la plataforma.
- Si no hubo cambios, "No se requiere actualizar documentación" con una línea de motivo.

## Qué evitar
- Documentar lo que el código ya expresa (listas de clases, firmas, endpoints).
- Copiar specs OpenAPI o JSON del catálogo.
- Reescribir docs de otros sin revisión: proponé diff.
- Explicar el porqué con frases genéricas ("es más escalable", "es mejor práctica"). Un porqué válido nombra el contexto, la alternativa concreta y la consecuencia.
- Crear archivos de documentación vacíos o con secciones de relleno "TBD".
