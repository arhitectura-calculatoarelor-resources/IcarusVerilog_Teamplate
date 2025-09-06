# cSpell: disable

# ========= Makefile: Icarus + GTKWave =========
SHELL := /usr/bin/bash
.SHELLFLAGS := -eu -o pipefail -c
IVERILOG ?= iverilog
VVP      ?= vvp
GTKWAVE  ?= gtkwave
VVP_OUT  := sim.vvp
VCD      := waves.vcd
VIEW     := view.gtkw

.PHONY: all build run wave clean help
all: build

build: $(VVP_OUT)
$(VVP_OUT):
	@echo "[1/3] Colectez sursele Verilog..."
	@mapfile -d '' -t SRC < <(find . -type f \( -iname '*.v' -o -iname '*.sv' \) \
		! -path './.*/*' ! -path '*/build/*' ! -path '*/out/*' -print0 | sort -z); \
	if [[ $${#SRC[@]} -eq 0 ]]; then echo "Eroare: nu am gasit surse .v/.sv."; exit 1; fi; \
	echo "[2/3] Compilez (fara -s, las elaboratorul sa aleaga top-ul daca e unic)..."; \
	if $(IVERILOG) -g2012 -Wall -o "$@" "$${SRC[@]}" 2> .iverilog.log; then \
		echo "OK: top unic detectat automat."; \
	else \
		if grep -qiE 'No top level modules|and no -s option|multiple.*top|root module.*not found' .iverilog.log; then \
			if [[ -n "$$TB" ]]; then TOP="$$TB"; else \
				AF="$$ACTIVE"; \
				if [[ -n "$$AF" ]] && command -v cygpath >/dev/null 2>&1; then \
					AF=$$(cygpath -u "$$AF" 2>/dev/null || echo "$$AF"); \
				fi; \
				if [[ -n "$$AF" && -f "$$AF" ]]; then \
					TOP=$$(awk '/^[ \t]*module[ \t]+[A-Za-z_][A-Za-z0-9_$]*/{ l=$$0; sub(/^[ \t]*module[ \t]+/,"",l); sub(/[(#;].*$$/,"",l); mod=l } END{ if(mod!="") print mod }' "$$AF"); \
				fi; \
			fi; \
			if [[ -z "$$TOP" ]]; then \
				echo "Nu pot alege top-ul automat." >&2; \
				echo "-> Variante: 'make TB=<top_module> wave' SAU 'make wave ACTIVE=<cale_catre_tb.v>'" >&2; \
				echo "--- Eroarea initiala Icarus ---" >&2; cat .iverilog.log >&2; exit 2; \
			fi; \
			echo "[fallback] Recompilez cu -s $$TOP (ales din TB/ACTIVE)"; \
			$(IVERILOG) -g2012 -Wall -o "$@" -s "$$TOP" "$${SRC[@]}"; \
		else \
			echo "--- Eroare de compilare Icarus ---" >&2; cat .iverilog.log >&2; exit 1; \
		fi; \
	fi

run: $(VVP_OUT)
	@echo "[3/3] Rulez simularea..."
	$(VVP) $(VVP_OUT)

wave: run
	@echo "[GTKWave] Deschid $(VCD)..."
	@if [ -f $(VIEW) ]; then $(GTKWAVE) $(VCD) -a $(VIEW) & else $(GTKWAVE) $(VCD) & fi

clean:
	rm -f $(VVP_OUT) $(VCD) .iverilog.log

help:
	@echo "Usage:"
	@echo "  make wave                      # compile (auto), run, GTKWave"
	@echo "  make run                       # compile (auto), run"
	@echo "  make clean                     # curata"
	@echo "Optiuni:"
	@echo "  TB=<top_module>                # forteaza top-ul"
	@echo "  ACTIVE=<cale\\catre\\tb.v>     # fallback: ultimul 'module' din fisierul activ"
