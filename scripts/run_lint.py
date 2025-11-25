from linting_helpers import run_codespell, run_cvlint, run_pyspellchecker
from rich.panel import Panel
from rich import print
import sys

LINT_CONFIG = "lint-config.yml"
SRC = "src/resume.tex"
PDF = "build/resume.pdf"

def main():

    codespell_exit_code = run_codespell(src_filepath=SRC)
    spellcheck_exit_code = run_pyspellchecker(src_filepath=SRC, lint_config_filepath=LINT_CONFIG)
    cvlint_exit_code = run_cvlint(pdf_filepath=PDF, lint_config_filepath=LINT_CONFIG)
    
    overall_exit_code = codespell_exit_code | spellcheck_exit_code | cvlint_exit_code

    status = "PASS" if overall_exit_code == 0 else "FAIL"
    color = "green" if overall_exit_code == 0 else "red"
    text = f"[bold]{status}[/bold]"

    panel = Panel(
        text,
        border_style=color,
        title="Overall Lint Result",
        title_align="left",
        expand=False,
        padding=(1, 10),
    )

    print(panel)
    
    return overall_exit_code


if __name__ == "__main__":
    sys.exit(main())
