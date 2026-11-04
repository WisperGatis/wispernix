#!/usr/bin/env python3
"""Infos matériel pour Waybar : CPU, mémoire et GPU (AMD).

Usage : hw-monitor cpu|memory|gpu [--once]

Imprime une ligne JSON {"text", "class", "tooltip", "percentage"} toutes les 2 secondes
(une seule fois avec --once). La classe vaut normal, warning ou critical selon les seuils.
Les capteurs sont lus dans sysfs ; un capteur absent s'affiche « n/d ».
Bibliothèque standard uniquement.
"""
import glob
import html
import json
import os
import sys
import time

INTERVALLE = 2  # secondes entre deux lignes

# (warning, critical). Ajuster ici pour changer les seuils.
SEUILS = {
    "cpu_usage": (70, 90),
    "cpu_temp": (80, 90),
    "ram": (75, 90),
    "gpu_usage": (70, 90),
    "gpu_edge": (80, 95),
    "gpu_junction": (95, 105),
}

CLASSES = ["normal", "warning", "critical"]
CLK_TCK = os.sysconf("SC_CLK_TCK")
PAGE = os.sysconf("SC_PAGE_SIZE")
ND = "n/d"


# --- Utilitaires ---------------------------------------------------------------------------

def lire(chemin):
    try:
        with open(chemin, encoding="utf-8", errors="replace") as f:
            return f.read().strip()
    except OSError:
        return None


def lire_nombre(chemin):
    texte = lire(chemin)
    try:
        return float(texte) if texte is not None else None
    except ValueError:
        return None


def niveau(valeur, seuils):
    """0 normal, 1 warning, 2 critical (0 si la valeur est inconnue)."""
    if valeur is None:
        return 0
    if valeur >= seuils[1]:
        return 2
    if valeur >= seuils[0]:
        return 1
    return 0


def hwmons(*noms):
    """Dossiers hwmon dont le nom est dans noms (l'index change à chaque démarrage)."""
    return [
        d for d in sorted(glob.glob("/sys/class/hwmon/hwmon*"))
        if lire(d + "/name") in noms
    ]


def temperature(dossier, fichier="temp1_input"):
    valeur = lire_nombre(f"{dossier}/{fichier}")
    return valeur / 1000 if valeur is not None else None


def fmt_temp(valeur):
    return f"{valeur:.0f}°C" if valeur is not None else ND


def ligne(libelle, valeur):
    return f"{libelle:<13}{valeur}"


def echapper(texte):
    return html.escape(texte, quote=False)


def tooltip(titre, lignes, processus=None, titre_proc="Processus"):
    morceaux = [f"<b>{echapper(titre)}</b>"] + [echapper(texte) for texte in lignes]
    if processus:
        morceaux += ["", f"<b>{titre_proc}</b>"] + [echapper(texte) for texte in processus]
    return "<tt>" + "\n".join(morceaux) + "</tt>"


def octets(valeur):
    for unite in ("o", "Ko", "Mo", "Go", "To"):
        if abs(valeur) < 1024 or unite == "To":
            return f"{valeur:.1f} {unite}" if unite != "o" else f"{valeur:.0f} o"
        valeur /= 1024


# --- Processus -----------------------------------------------------------------------------

def ticks_par_nom():
    """Temps CPU cumulé (ticks) par nom de processus."""
    total = {}
    for chemin in glob.glob("/proc/[0-9]*/stat"):
        donnees = lire(chemin)
        if not donnees:
            continue
        fin = donnees.rfind(")")
        nom = donnees[donnees.find("(") + 1:fin]
        champs = donnees[fin + 2:].split()
        try:
            total[nom] = total.get(nom, 0) + int(champs[11]) + int(champs[12])
        except (IndexError, ValueError):
            continue
    return total


def rss_par_nom():
    """Mémoire résidente cumulée (octets) par nom de processus."""
    total = {}
    for dossier in glob.glob("/proc/[0-9]*"):
        nom = lire(dossier + "/comm")
        statm = lire(dossier + "/statm")
        if not nom or not statm:
            continue
        try:
            total[nom] = total.get(nom, 0) + int(statm.split()[1]) * PAGE
        except (IndexError, ValueError):
            continue
    return total


# --- Modules -------------------------------------------------------------------------------

class Cpu:
    def __init__(self):
        self.stat = self.lire_stat()
        self.ticks = ticks_par_nom()
        self.instant = time.monotonic()

    @staticmethod
    def lire_stat():
        texte = lire("/proc/stat") or ""
        champs = texte.splitlines()[0].split()[1:9] if texte else []
        valeurs = [int(v) for v in champs]
        if len(valeurs) < 5:
            return 0, 0
        return sum(valeurs), valeurs[3] + valeurs[4]  # total, idle + iowait

    @staticmethod
    def temperature():
        for dossier in hwmons("coretemp", "k10temp", "zenpower"):
            valeur = temperature(dossier)
            if valeur is not None:
                return valeur
        return None

    def echantillon(self):
        stat = self.lire_stat()
        ticks = ticks_par_nom()
        maintenant = time.monotonic()
        duree = max(maintenant - self.instant, 0.001)
        d_total = stat[0] - self.stat[0]
        d_idle = stat[1] - self.stat[1]
        usage = 100 * (1 - d_idle / d_total) if d_total > 0 else 0.0

        # Part de CPU par processus, en pourcentage d'un cœur.
        parts = []
        for nom, valeur in ticks.items():
            delta = valeur - self.ticks.get(nom, valeur)
            if delta > 0:
                parts.append((delta / (CLK_TCK * duree) * 100, nom))
        parts.sort(reverse=True)
        self.stat, self.ticks, self.instant = stat, ticks, maintenant

        info = lire("/proc/cpuinfo") or ""
        modele = next(
            (l.split(":", 1)[1].strip() for l in info.splitlines() if l.startswith("model name")),
            "CPU",
        )
        mhz = [float(l.split(":", 1)[1]) for l in info.splitlines() if l.startswith("cpu MHz")]
        charge = (lire("/proc/loadavg") or "").split()[:3]
        temp = self.temperature()

        lignes = [
            ligne("Usage", f"{usage:.0f} %"),
            ligne("Température", fmt_temp(temp)),
            ligne("Fréquence", f"{sum(mhz) / len(mhz) / 1000:.2f} GHz" if mhz else ND),
            ligne("Charge", " ".join(charge) if charge else ND),
        ]
        top = [f"{nom:<16}{part:>5.0f} %" for part, nom in parts[:3]]
        classe = max(niveau(usage, SEUILS["cpu_usage"]), niveau(temp, SEUILS["cpu_temp"]))
        return {
            "text": f"{usage:.0f}%",
            "class": CLASSES[classe],
            "percentage": round(usage),
            "tooltip": tooltip(modele, lignes, top, "Processus (par cœur)"),
        }


class Memoire:
    @staticmethod
    def meminfo():
        valeurs = {}
        for l in (lire("/proc/meminfo") or "").splitlines():
            cle, _, reste = l.partition(":")
            try:
                valeurs[cle] = int(reste.split()[0]) * 1024
            except (IndexError, ValueError):
                continue
        return valeurs

    @staticmethod
    def disques():
        sorties = []
        for dossier in hwmons("nvme"):
            modele = lire(dossier + "/device/model") or "NVMe"
            sorties.append(ligne(modele[:12], fmt_temp(temperature(dossier))))
        return sorties

    def echantillon(self):
        m = self.meminfo()
        total = m.get("MemTotal", 0)
        if not total:
            return {"text": ND, "class": "normal", "tooltip": ND}
        dispo = m.get("MemAvailable", 0)
        utilise = total - dispo
        pct = 100 * utilise / total
        swap_total = m.get("SwapTotal", 0)
        swap_utilise = swap_total - m.get("SwapFree", 0)

        lignes = [
            ligne("Utilisée", f"{octets(utilise)} / {octets(total)} ({pct:.0f} %)"),
            ligne("Disponible", octets(dispo)),
            ligne("Cache", octets(m.get("Cached", 0) + m.get("Buffers", 0))),
            ligne("Swap", f"{octets(swap_utilise)} / {octets(swap_total)}" if swap_total else "aucun"),
        ]
        disques = self.disques()
        if disques:
            lignes += ["", "Disques (température)"] + disques

        top = sorted(((v, n) for n, v in rss_par_nom().items()), reverse=True)[:3]
        procs = [f"{nom:<16}{octets(valeur):>10}" for valeur, nom in top]
        return {
            "text": f"{pct:.0f}%",
            "class": CLASSES[niveau(pct, SEUILS["ram"])],
            "percentage": round(pct),
            "tooltip": tooltip("Mémoire", lignes, procs, "Processus (RAM)"),
        }


class Gpu:
    def __init__(self):
        self.dossier = self.trouver()

    @staticmethod
    def trouver():
        for carte in sorted(glob.glob("/sys/class/drm/card[0-9]*/device")):
            if os.path.basename(os.path.realpath(carte + "/driver")) == "amdgpu":
                return carte
        return None

    def echantillon(self):
        if self.dossier is None:
            return None
        d = self.dossier
        capteurs = sorted(glob.glob(d + "/hwmon/hwmon*"))
        h = capteurs[0] if capteurs else None

        usage = lire_nombre(d + "/gpu_busy_percent")
        vram_u = lire_nombre(d + "/mem_info_vram_used")
        vram_t = lire_nombre(d + "/mem_info_vram_total")
        edge = temperature(h, "temp1_input") if h else None
        junction = temperature(h, "temp2_input") if h else None
        memoire = temperature(h, "temp3_input") if h else None
        puissance = lire_nombre(f"{h}/power1_average") if h else None
        if puissance is None and h:
            puissance = lire_nombre(f"{h}/power1_input")
        ventilo = lire_nombre(f"{h}/fan1_input") if h else None
        coeur = lire_nombre(f"{h}/freq1_input") if h else None

        lignes = [
            ligne("Usage", f"{usage:.0f} %" if usage is not None else ND),
            ligne("Temp. edge", fmt_temp(edge)),
            ligne("Temp. jonction", fmt_temp(junction)),
            ligne("Temp. VRAM", fmt_temp(memoire)),
            ligne("VRAM", f"{octets(vram_u)} / {octets(vram_t)}" if vram_u is not None and vram_t else ND),
            ligne("Puissance", f"{puissance / 1e6:.0f} W" if puissance is not None else ND),
            ligne("Fréquence", f"{coeur / 1e6:.0f} MHz" if coeur is not None else ND),
            ligne("Ventilateur", f"{ventilo:.0f} tr/min" if ventilo is not None else ND),
        ]
        classe = max(
            niveau(usage, SEUILS["gpu_usage"]),
            niveau(edge, SEUILS["gpu_edge"]),
            niveau(junction, SEUILS["gpu_junction"]),
        )
        return {
            "text": f"{usage:.0f}%" if usage is not None else ND,
            "class": CLASSES[classe],
            "percentage": round(usage) if usage is not None else 0,
            "tooltip": tooltip("GPU AMD", lignes),
        }


MODULES = {"cpu": Cpu, "memory": Memoire, "gpu": Gpu}


def main(argv):
    args = [a for a in argv if not a.startswith("--")]
    if len(args) != 1 or args[0] not in MODULES:
        print("usage : hw-monitor cpu|memory|gpu [--once]", file=sys.stderr)
        return 2
    une_fois = "--once" in argv
    module = MODULES[args[0]]()

    attente = 0.5  # première mesure rapide : l'usage CPU a besoin de deux lectures
    while True:
        time.sleep(attente)
        attente = INTERVALLE
        sortie = module.echantillon()
        if sortie is None:
            # Module absent (pas de GPU AMD) : texte vide, Waybar masque le module.
            print(json.dumps({"text": "", "tooltip": ""}), flush=True)
            return 0
        print(json.dumps(sortie, ensure_ascii=False), flush=True)
        if une_fois:
            return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except KeyboardInterrupt:
        sys.exit(0)
