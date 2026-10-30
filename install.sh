#!/bin/bash
set -e

REPO_RAW_URL="https://raw.githubusercontent.com/blugo-inf/skill-document-task/main"
TARGET_DIR="${1:-.}"
SKILL_NAME="document-task"
SKILL_DEST_DIR="$TARGET_DIR/.agents/skills/$SKILL_NAME"
AGENTS_FILE="$TARGET_DIR/AGENTS.md"

echo "🚀 Instalando skill '$SKILL_NAME' en: $(realpath "$TARGET_DIR")"

# 1. Crear carpetas de destino
mkdir -p "$SKILL_DEST_DIR/references"

# 2. Descargar SKILL.md
echo "📥 Descargando SKILL.md..."
if ! curl -fsSL "$REPO_RAW_URL/SKILL.md" -o "$SKILL_DEST_DIR/SKILL.md"; then
    echo "❌ Error al descargar SKILL.md. Verificá que el archivo exista en la rama 'main'."
    exit 1
fi
echo "✔ SKILL.md guardado en $SKILL_DEST_DIR/SKILL.md"

# 3. Descargar references/templates.md si existe en el repo
if curl --output /dev/null --silent --head --fail "$REPO_RAW_URL/references/templates.md"; then
    curl -fsSL "$REPO_RAW_URL/references/templates.md" -o "$SKILL_DEST_DIR/references/templates.md"
    echo "✔ Plantillas de referencia descargadas."
fi

# 4. Bloque de texto para AGENTS.md
SNIPPET=$(cat << 'EOF'

## Mantenimiento de la documentación
Al terminar una tarea y antes de abrir el MR/PR, ejecutá la skill `document-task`.Si no está disponible: actualizá los docs afectados, creá un ADR si hubo una decisión con alternativas descartadas y agregá los gotchas nuevos a `docs/gotchas.md`.
EOF
)

# 5. Actualizar AGENTS.md
if [ ! -f "$AGENTS_FILE" ]; then
    echo "$SNIPPET" > "$AGENTS_FILE"
    echo "✔ Creado $AGENTS_FILE con la regla de documentación."
else
    if grep -q "document-task" "$AGENTS_FILE"; then
        echo "ℹ $AGENTS_FILE ya contiene la referencia a 'document-task'."
    else
        echo "$SNIPPET" >> "$AGENTS_FILE"
        echo "✔ Regla añadida al final de $AGENTS_FILE."
    fi
fi

echo "✅ Instalación completada correctamente."