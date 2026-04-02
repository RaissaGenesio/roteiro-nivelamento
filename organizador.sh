#/bin/bash

DRY_RUN=false

pastas_criadas=()
arquivos_movidos=()
arquivos_ignorados=()
conflitos=()

if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=true
fi

criar_pasta() {
    local pasta="$1"

    if [ ! -d "$pasta" ]; then
        if $DRY_RUN; then
            echo "[DRY-RUN] Criaria a pasta: $pasta"
        else
            mkdir -p "$pasta"
        fi
        pastas_criadas+=("$pasta")
    fi
}

mover_arquivo() {
    local arquivo="$1"
    local destino="$2"
    local nome

    if [ ! -f "$arquivo" ]; then
        return
    fi

    nome=$(basename "$arquivo")

    if [ -e "$destino/$nome" ]; then
        echo "[AVISO] Conflito: $destino/$nome já existe"
        conflitos+=("$arquivo -> $destino/$nome")
        return
    fi

    if $DRY_RUN; then
        echo "[DRY-RUN] Moveria: $arquivo -> $destino/"
    else
        echo "Movendo: $arquivo -> $destino/"
        mv -n "$arquivo" "$destino/"
    fi

    arquivos_movidos+=("$arquivo -> $destino/")
}

criar_pasta "src"
criar_pasta "tb"
criar_pasta "include"
criar_pasta "scripts"
criar_pasta "docs"

for file in *.vh; do
    mover_arquivo "$file" "include"
done

for file in *.tcl; do
    mover_arquivo "$file" "scripts"
done

for file in *.do; do
    mover_arquivo "$file" "scripts"
done

if [ -f "README.md" ]; then
    mover_arquivo "README.md" "docs"
fi

for file in *.sh; do
    if [ -f "$file" ] && [ "$file" != "organizador.sh" ]; then
        mover_arquivo "$file" "scripts"
    fi
done

for file in *.v; do
    if [ -f "$file" ]; then
        if [[ "$file" == *_tb.v ]]; then
            mover_arquivo "$file" "tb"
        else
            mover_arquivo "$file" "src"
        fi
    fi
done

for file in *; do
    if [ -f "$file" ]; then
        case "$file" in
            organizador.sh)
                echo "[INFO] Ignorado: $file"
                arquivos_ignorados+=("$file")
                ;;
            *.vh|*.tcl|*.do|README.md|*.v|*.sh)
                ;;
            *)
                echo "[INFO] Ignorado: $file"
                arquivos_ignorados+=("$file")
                ;;
        esac
    fi
done

echo
echo "===== RELATÓRIO FINAL ====="

echo "Pastas criadas: ${#pastas_criadas[@]}"
for item in "${pastas_criadas[@]}"; do
    echo " - $item"
done

echo
echo "Arquivos movidos: ${#arquivos_movidos[@]}"
for item in "${arquivos_movidos[@]}"; do
    echo " - $item"
done

echo
echo "Arquivos ignorados: ${#arquivos_ignorados[@]}"
for item in "${arquivos_ignorados[@]}"; do
    echo " - $item"
done

echo
echo "Conflitos encontrados: ${#conflitos[@]}"
for item in "${conflitos[@]}"; do
    echo " - $item"
done

echo
if $DRY_RUN; then
    echo "Modo de execução: DRY-RUN"
else
    echo "Modo de execução: NORMAL"
fi
