from pathlib import Path
import logging
from rich.logging import RichHandler

import sys

from . import merge, cert, evict

logging.basicConfig(level=logging.INFO, format="%(message)s", datefmt="[%X]", handlers=[RichHandler(show_time=False)])

def main():
    basename = Path(sys.argv[0]).name
    match basename:
        case "kubectl-merge":
            merge.main()
        case "kubectl-cert":
            cert.main()
        case "kubectl-evict":
            evict.main()
        case _:
            exit(1)


if __name__ == "__main__":
    main()
