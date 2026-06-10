import subprocess

import yaml


def run_cvlint(pdf_filepath: str, lint_config_filepath: str) -> int:
    """
    Run cvlint on the given PDF using settings from a YAML config file.

    The YAML file must define:
      passing_score: <int>
      criteria:
        <Criterion Name>: true|false

    Enabled criteria are added to the `cvlint check` command, which is then
    executed as a subprocess. cvlint's output is printed directly to the
    terminal, and its exit code is returned to the caller.

    Parameters
    ----------
    lint_config_filepath : str
        Path to the YAML configuration file.
    pdf_filepath : str
        Path to the PDF to validate.

    Returns
    -------
    int
        The exit code from the cvlint process.
    """
    
    print("\n" + "-" * 25 + " CV LINT " + "-" * 25 + "\n")

    with open(lint_config_filepath) as f:
        config = yaml.safe_load(f)
        
    passing_score = config.get("passing_score", 100)
    criteria_dict = config.get("criteria", {})
    enabled_criteria = [name for name, enabled in criteria_dict.items() if enabled]

    cmd = [
        "cvlint", "check", pdf_filepath,
        "--passing-score", str(passing_score)
    ]

    for crit in enabled_criteria:
        cmd.extend(["--criteria", crit])
        
    proc = subprocess.run(cmd)
        
    if proc.stdout:
        print(proc.stdout)

    return proc.returncode