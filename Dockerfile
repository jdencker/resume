# Dockerfile – minimal LaTeX build environment for the resume
FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      make \
      latexmk \
      texlive-latex-recommended \
      texlive-latex-extra \
      texlive-fonts-recommended \
      texlive-fonts-extra && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work

# Default command: run `make` in /work
CMD ["make"]