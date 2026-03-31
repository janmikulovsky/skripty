#!/bin/bash
OUTPUT="code-output.txt"
IGNORE_FILE=".codemixignore"
EXTENSIONS="html php js css json md txt"

IGNORES=()
if [ -f "$IGNORE_FILE" ]; then
    while IFS= read -r line; do
        line="${line%$'\r'}"
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue
        IGNORES+=("$line")
    done < "$IGNORE_FILE"
fi

is_ignored() {
    local file="$1"
    for pattern in "${IGNORES[@]}"; do
        clean="${pattern%/}"
        if [[ "$file" == ./"$clean"/* ]] || [[ "$file" == "$clean"/* ]]; then
            return 0
        fi
    done
    return 1
}

{
    echo ""
    echo "=== PROJECT MERGE OUTPUT ==="
    echo "Generated: $(date)"
    echo ""
} > "$OUTPUT"

for ext in $EXTENSIONS; do
    echo "--- Searching *.$ext files ---"
    while read -r FILE; do
        if is_ignored "$FILE"; then
            echo "Ignoring: $FILE"
            continue
        fi
        echo "Adding: $FILE"
        {
            echo ""
            echo "============================================"
            echo "FILE: $FILE"
            echo "============================================"
            echo ""
            cat "$FILE"
            echo ""
            echo ""
        } >> "$OUTPUT"
    done < <(find . -type f -name "*.$ext" | sort)
done

echo "Done. Output: $OUTPUT"
