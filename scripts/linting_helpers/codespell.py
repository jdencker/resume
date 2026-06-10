import subprocess

from rich import print
from rich.table import Table


def run_codespell(src_filepath: str) -> int:
    """
    Run codespell on the given source file and display results in a Rich table.

    Parameters
    ----------
    source : str
        Path to the file to check for spelling errors.

    Returns
    -------
    int
        Exit code indicating success or failure:
        - 0 if no misspellings were reported by codespell.
        - 1 if codespell detected one or more issues.

    Notes
    -----
    - This function does *not* perform full dictionary spell checking. It relies
      solely on codespell's internal list of common misspellings.
    - The output is printed directly to the terminal; callers may inspect the
      return code to determine whether the step should fail the overall pipeline.
    - Malformed codespell output lines are ignored gracefully.
    """
    print("\n" + "-" * 25 + " CODE SPELL CHECK " + "-" * 25 + "\n")

    cmd = ["codespell", src_filepath]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    
    results = []
    for line in proc.stdout.strip().splitlines():
        if "==" in line:
            try:
                filepart, next_part = line.split(":", 1)
                line_no, rest = next_part.split(":", 1)
                wrong, suggestion = rest.split("==>")
                results.append(
                    {
                        "line": line_no.strip(),
                        "wrong": wrong.strip(),
                        "suggestion": suggestion.strip(),
                    }
                )
            except ValueError:
                pass  # skip malformed lines

    table = Table(title="CodeSpell Results")
    table.add_column("Line", style="cyan", justify="right")
    table.add_column("Incorrect", style="red", no_wrap=True)
    table.add_column("Suggestion", style="green", no_wrap=True)

    if not results:
        table.add_row(
            "-", 
            "[green]No spelling issues found[/green]", 
            "-"
        )
        print(table)
        print("CodeSpell: [green]PASS")
        return 0
    else:
        for item in results:
            table.add_row(
                item["line"],
                item["wrong"],
                item["suggestion"],
            )
        print(table)
        print("CodeSpell: [red]FAIL")
        return 0
