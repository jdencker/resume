from spellchecker import SpellChecker
from rich import print
from rich.table import Table
import re
import yaml

def run_pyspellchecker(src_filepath: str, lint_config_filepath: str) -> int:
    """
    Run a Python-based spell check on a LaTeX source file using pyspellchecker.

    The function extracts words from the LaTeX file by removing commands and
    markup, tokenizing plain text, and filtering out short tokens and acronyms.
    Unknown words are detected using `pyspellchecker`, optionally excluding
    terms from an allowlist provided in a YAML config file.

    Results are displayed as a Rich table and the function returns a non-zero
    exit code if any unknown words are found.

    Parameters
    ----------
    src_filepath : str
        Path to the LaTeX source file to examine.
    lint_config_filepath : str
        Path to a YAML config file containing an allowlist of permitted words.

    Returns
    -------
    int
        0 if no unknown words are found, otherwise 1.
    """
    
    print("\n" + "-" * 25 + " PY SPELL CHECK " + "-" * 25 + "\n")

    with open(src_filepath, "r") as f:
        src_code = f.read()
        
    body = re.search(
        r"\\begin{document}(.*?)\\end{document}",
        src_code,
        flags=re.DOTALL
    )
    
    if not body:
        print("[red]Error: Could not find \\begin{document} ... \\end{document} in LaTeX file[/red]")
        return 1
    
    pre_body = src_code[: body.start(1)]
    line_offset = pre_body.count("\n")
    text = body.group(1) 
    

    cmds_with_args_re = re.compile(r"\\[a-zA-Z]+\*?(?:\[[^\]]*\])?(?:\{[^}]*\})?")
    braces_re = re.compile(r"[{}]")
    token_re = re.compile(r"[A-Za-z][A-Za-z\-']+")

    spell = SpellChecker(language="en")
    allowed_word_set = set()  # default if config missing or malformed
    try:
        with open(lint_config_filepath, "r") as f:
            config = yaml.safe_load(f) or {}
        allowlist = config.get("allowlist", [])
        allowed_word_set = {w.lower() for w in allowlist}
    except Exception as e:
        print(f"[yellow]Warning: Could not load allowlist from {lint_config_filepath}: {e}[/yellow]")

    errors_by_word: dict[str, set[int]] = {}
    
    # Process text line by line to preserve line numbers
    for local_line_num, line in enumerate(text.splitlines(), start=1):
        # Clean LaTeX on this line only (only within the line to preserve line mapping)
        cleaned = cmds_with_args_re.sub(" ", line)
        cleaned = braces_re.sub(" ", cleaned)
        tokens = token_re.findall(cleaned)

        for w in tokens:
            if len(w) <= 2:
                continue
            if w.isupper():
                # skip ALLCAPS acronyms
                continue

            w_lower = w.lower()

            if w_lower in allowed_word_set:
                # Skip allowlisted words
                continue

            if w_lower in spell:
                # Skip words known to the spellchecker
                continue

            actual_line = line_offset + local_line_num
            errors_by_word.setdefault(w, set()).add(actual_line)

    table = Table(title="PySpellChecker")
    table.add_column("Word", style="red")
    table.add_column("Line(s)", style="cyan")

    if not errors_by_word:
        table.add_row("[green]No unknown words found[/green]")
        print(table)
        print("PySpellChecker: [green]PASS")
        return 0
    else:
        for word in sorted(errors_by_word.keys(), key=str.lower):
            lines_str = ", ".join(str(n) for n in sorted(errors_by_word[word]))
            table.add_row(word, lines_str)
        print(table)
        print("PySpellChecker: [red]FAIL")
        return 1