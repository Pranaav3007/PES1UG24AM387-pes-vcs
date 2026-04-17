#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
render_py="$repo_root/tools/render_terminal_capture.py"
render_py_win="$(wslpath -w "$render_py")"
export PES_AUTHOR="Pranaav P. <PES1UG24AM387>"

capture() {
    local outfile="$1"
    shift
    {
        printf '$ %s\n' "$*"
        "$@"
    } >"$outfile" 2>&1
}

render() {
    local input="$1"
    local output="$2"
    local title="$3"
    python.exe "$render_py_win" "$(wslpath -w "$input")" "$(wslpath -w "$output")" --title "$title"
}

mkdir -p "$repo_root/artifacts/phase1" \
         "$repo_root/artifacts/phase2" \
         "$repo_root/artifacts/phase3" \
         "$repo_root/artifacts/phase4" \
         "$repo_root/artifacts/runtime" \
         "$repo_root/screenshots"

cd "$repo_root"
make clean
make all

capture "$repo_root/artifacts/phase1/1A_test_objects.txt" ./test_objects
capture "$repo_root/artifacts/phase1/1B_objects_find.txt" find .pes/objects -type f
render "$repo_root/artifacts/phase1/1A_test_objects.txt" "$repo_root/screenshots/1A_test_objects.png" "Phase 1A - ./test_objects"
render "$repo_root/artifacts/phase1/1B_objects_find.txt" "$repo_root/screenshots/1B_objects_find.png" "Phase 1B - find .pes/objects -type f"

capture "$repo_root/artifacts/phase2/2A_test_tree.txt" ./test_tree
render "$repo_root/artifacts/phase2/2A_test_tree.txt" "$repo_root/screenshots/2A_test_tree.png" "Phase 2A - ./test_tree"

phase2_demo="$repo_root/artifacts/runtime/phase2-demo"
rm -rf "$phase2_demo"
mkdir -p "$phase2_demo/src"
cd "$phase2_demo"
"$repo_root/pes" init >/dev/null
printf 'Hello\n' > README.md
printf 'int main(void) { return 0; }\n' > src/main.c
"$repo_root/pes" add README.md src/main.c >/dev/null
"$repo_root/pes" commit -m "Create nested tree" >/dev/null
tree_file="$(find .pes/objects -type f | sort | while read -r file; do
    if [ "$(head -c 4 "$file")" = "tree" ]; then
        printf '%s\n' "$file"
        break
    fi
done)"
{
    printf '$ xxd %s | head -20\n' "$tree_file"
    xxd "$tree_file" | head -20
} >"$repo_root/artifacts/phase2/2B_tree_xxd.txt"
render "$repo_root/artifacts/phase2/2B_tree_xxd.txt" "$repo_root/screenshots/2B_tree_xxd.png" "Phase 2B - Raw Tree Object"

phase3_demo="$repo_root/artifacts/runtime/phase3-demo"
rm -rf "$phase3_demo"
mkdir -p "$phase3_demo"
cd "$phase3_demo"
{
    printf '$ %s\n' "\"$repo_root/pes\" init"
    "$repo_root/pes" init
    printf '\n$ %s\n' "echo \"hello\" > file1.txt"
    printf 'hello\n' > file1.txt
    printf '$ %s\n' "echo \"world\" > file2.txt"
    printf 'world\n' > file2.txt
    printf '$ %s\n' "\"$repo_root/pes\" add file1.txt file2.txt"
    "$repo_root/pes" add file1.txt file2.txt
    printf '$ %s\n' "\"$repo_root/pes\" status"
    "$repo_root/pes" status
} >"$repo_root/artifacts/phase3/3A_init_add_status.txt" 2>&1
capture "$repo_root/artifacts/phase3/3B_index_cat.txt" cat .pes/index
render "$repo_root/artifacts/phase3/3A_init_add_status.txt" "$repo_root/screenshots/3A_init_add_status.png" "Phase 3A - init add status"
render "$repo_root/artifacts/phase3/3B_index_cat.txt" "$repo_root/screenshots/3B_index_cat.png" "Phase 3B - cat .pes/index"

phase4_demo="$repo_root/artifacts/runtime/phase4-demo"
rm -rf "$phase4_demo"
mkdir -p "$phase4_demo"
cd "$phase4_demo"
"$repo_root/pes" init >/dev/null
printf 'Hello\n' > hello.txt
"$repo_root/pes" add hello.txt >/dev/null
"$repo_root/pes" commit -m "Initial commit" >/dev/null
sleep 1
printf 'World\n' >> hello.txt
"$repo_root/pes" add hello.txt >/dev/null
"$repo_root/pes" commit -m "Add world" >/dev/null
sleep 1
printf 'Goodbye\n' > bye.txt
"$repo_root/pes" add bye.txt >/dev/null
"$repo_root/pes" commit -m "Add farewell" >/dev/null

capture "$repo_root/artifacts/phase4/4A_pes_log.txt" "$repo_root/pes" log
capture "$repo_root/artifacts/phase4/4B_find_pes_files.txt" sh -c 'find .pes -type f | sort'
{
    printf '$ cat .pes/refs/heads/main\n'
    cat .pes/refs/heads/main
    printf '\n$ cat .pes/HEAD\n'
    cat .pes/HEAD
} >"$repo_root/artifacts/phase4/4C_refs_and_head.txt" 2>&1
render "$repo_root/artifacts/phase4/4A_pes_log.txt" "$repo_root/screenshots/4A_pes_log.png" "Phase 4A - ./pes log"
render "$repo_root/artifacts/phase4/4B_find_pes_files.txt" "$repo_root/screenshots/4B_find_pes_files.png" "Phase 4B - find .pes -type f | sort"
render "$repo_root/artifacts/phase4/4C_refs_and_head.txt" "$repo_root/screenshots/4C_refs_and_head.png" "Phase 4C - refs and HEAD"

cd "$repo_root"
{
    printf '$ export PES_AUTHOR="Pranaav P. <PES1UG24AM387>"\n'
    printf '$ perl -0pe '\''s/\\r\\n/\\n/g'\'' test_sequence.sh | bash\n'
    export PES_AUTHOR="Pranaav P. <PES1UG24AM387>"
    perl -0pe 's/\r\n/\n/g' test_sequence.sh | bash
} >"$repo_root/artifacts/phase4/final_integration_test.txt" 2>&1
render "$repo_root/artifacts/phase4/final_integration_test.txt" "$repo_root/screenshots/final_integration_test.png" "Final - make test-integration"
