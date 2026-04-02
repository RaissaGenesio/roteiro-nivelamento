#/bin/bash

DRY_RUN=false
pastas_criadas=0
arquivos_movidos=0
arquivos_ignorados=0
conflitos=0

if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=true
    echo "--- MODO SIMULAÇÃO ATIVADO ---"
fi

for pasta in src tb include scripts docs; do
    if [ ! -d "$pasta" ]; then
        if $DRY_RUN; then
            echo "[Simulação] Criaria a pasta: $pasta"
        else
            mkdir -p "$pasta"
        fi
        pastas_criadas=$((pastas_criadas + 1))
    fi
done

for arquivo in *.v; do
    if [ -f "$arquivo" ]; then
        if [[ "$arquivo" == *_tb.v ]]; then
            pasta_destino="tb"
        else
            pasta_destino="src"
        fi

        if [ -e "$pasta_destino/$arquivo" ]; then
            echo "[Aviso] Conflito: $pasta_destino/$arquivo já existe"
            conflitos=$((conflitos + 1))
        else
            if $DRY_RUN; then
                echo "[Simulação] Moveria $arquivo -> $pasta_destino/"
            else
                echo "Movendo $arquivo -> $pasta_destino/"
                mv -n "$arquivo" "$pasta_destino/"
            fi
            arquivos_movidos=$((arquivos_movidos + 1))
        fi
    fi
done

for arquivo in *; do
    if [ -f "$arquivo" ]; then
        case "$arquivo" in
            *.vh) destino="include" ;;
            *.tcl) destino="scripts" ;;
            *.do) destino="scripts" ;;
            README.md) destino="docs" ;;
            organizador.sh)
                arquivos_ignorados=$((arquivos_ignorados + 1))
                continue
                ;;
            *)
                arquivos_ignorados=$((arquivos_ignorados + 1))
                continue
                ;;
        esac

        if [ -e "$destino/$arquivo" ]; then
            echo "[Aviso] Conflito: $destino/$arquivo já existe"
            conflitos=$((conflitos + 1))
        else
            if $DRY_RUN; then
                echo "[Simulação] Moveria $arquivo -> $destino/"
            else
                echo "Movendo $arquivo -> $destino/"
                mv -n "$arquivo" "$destino/"
            fi
            arquivos_movidos=$((arquivos_movidos + 1))
        fi
    fi
done

echo
echo "===== RELATÓRIO FINAL ====="
echo "Pastas criadas: $pastas_criadas"
echo "Arquivos movidos: $arquivos_movidos"
echo "Arquivos ignorados: $arquivos_ignorados"
echo "Conflitos encontrados: $conflitos"

if $DRY_RUN; then
    echo "Modo de execução: DRY-RUN"
else
    echo "Modo de execução: NORMAL"
fi
