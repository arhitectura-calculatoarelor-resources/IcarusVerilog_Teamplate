# IcarusVerilog_Teamplate
Acesta este un teamplate gata de folosit, care include makefile-ul si setarile/ task-urile necesare pentru a putea rula cod Verilog de pe orice calculator care foloseste Windows

# Tutorial instalare Icarus Verilog si GTKWave, Extensii necesare VSCode si clonarea repo-ului pentru folosire
# 0) Cerințe

Windows 10/11 x64

~2 GB spațiu liber

Drepturi de instalare

# 1) Instalează MSYS2

Descarcă și instalează MSYS2 (locație implicită C:\msys64).

Din Start, deschide “MSYS2 MinGW 64-bit” (NU “MSYS” / “UCRT64”).

# Actualizează:

pacman -Syu
# închide fereastra dacă ți se cere, apoi redeschide "MSYS2 MinGW 64-bit"
pacman -Syu


# Instalează uneltele:
pacman -S --needed make mingw-w64-x86_64-iverilog mingw-w64-x86_64-gtkwave


Verifică:

which make; which iverilog; which vvp; which gtkwave
# așteptat: /usr/bin/make și /mingw64/bin/{iverilog,vvp,gtkwave}

# 2) Instalează VS Code + extensii

Instalează Visual Studio Code (standard).

Deschide VS Code -> View -> Extensions și caută/instalează:

mshr-h.veriloghdl (Verilog/SystemVerilog)
ms-vscode.makefile-tools (opțional, util)
streetsidesoftware.code-spell-checker (opțional)

(Opțional prin CLI, dacă code e în PATH):
code --install-extension mshr-h.veriloghdl
code --install-extension ms-vscode.makefile-tools
code --install-extension streetsidesoftware.code-spell-checker

# 3) Clonează repo-ul “starter”

Înlocuiește <REPO_URL> cu adresa acestui repo
Varianta PowerShell / CMD:

####
cd %USERPROFILE%\Desktop
git clone <REPO_URL>
code verilog-starter
####

Varianta MSYS2 (opțional):

cd /c/Users/%USERNAME%/Desktop
git clone <REPO_URL>


La prima deschidere, VS Code îți va propune “Install recommended extensions” -> Acceptă.

# 4) Ce e deja în repo (nu mai configurezi tu)

Repo-ul vine cu:

.vscode/tasks.json – task “un buton” ce rulează Bash din MSYS2 și face: compilează (iverilog) -> rulează (vvp) -> deschide GTKWave.
.vscode/settings.json – linter Verilog pe iverilog, calea către iverilog din MSYS2 și micșorarea zgomotului cSpell.

Makefile (opțional, dacă preferi make): colectează surse .v/.sv, compilează, rulează, deschide GTKWave; are fallback “auto-top”.

# 5) Rulează primul exemplu (un buton)

În VS Code: File -> Open Folder… și deschide folderul repo-ului.
Deschide examples/tb_counter.v.
Apasă Ctrl + Shift + B -> alege (sau se rulează direct) “Verilog: Build + Run + GTKWave”.

Se compilează (sim.vvp), se rulează, se generează waves.vcd, se deschide GTKWave.

Dacă apare un dialog “Select default build task”, alege Verilog: Build + Run + GTKWave.

# 6) Reguli standard pentru fisierul testbench

Ca să vezi semnalele în GTKWave, în testbench trebuie un bloc de genul acesta:
###
initial begin
  $dumpfile("waves.vcd");
  $dumpvars(0, tb_dut); // înlocuiește cu numele modulului TB
end
###
Și o condiție de încheiere (#... $finish; sau un număr de cicluri de ceas), altfel simularea nu se termină.

# 7) (Opțional) Rulare manuală din MSYS2

În folderul proiectului:
###
iverilog -g2012 -Wall -o sim.vvp $(find . -name '*.v' -o -name '*.sv')
vvp sim.vvp
gtkwave waves.vcd &
###

Sau, dacă ai Makefile:

make wave

# 8) Troubleshooting (cele mai frecvente)

Se deschide alt terminal MSYS2 (MSYS/UCRT64):
Deschide din Start “MSYS2 MinGW 64-bit”. Verifică which iverilog → trebuie /mingw64/bin/iverilog.

make: command not found: instalează make (pasul 1.4).

Nu se deschide GTKWave: verifică că waves.vcd există; dacă nu, adaugă $dumpfile/$dumpvars în TB.

No top level modules, and no -s option: deschide testbench-ul în editor și rulează din nou (task-ul/Makefile-ul are fallback “auto-top” pe ultimul module din fișierul curent).

VS Code pornește “msbuild”: Terminal → Configure Default Build Task… → alege Verilog: Build + Run + GTKWave.

Linter nu găsește iverilog: în .vscode/settings.json confirmă calea:

"verilog.iverilog.path": "C:\\msys64\\mingw64\\bin\\iverilog.exe"


MSYS2 nu e în C:\msys64: editează ruta din .vscode/tasks.json (la "command": "C:\\msys64\\usr\\bin\\bash.exe"), pune calea ta reală.

# 9) Gata de lucru pe proiectele tale

Pune fișierele .v/.sv în folderul repo-ului (în examples/ sau alt subfolder).

Deschide testbench-ul și apasă Ctrl + Shift + B.

GTKWave îți va arăta semnalele din waves.vcd; poți salva o vizualizare ca view.gtkw (va fi încărcată automat la următoarea rulare).
