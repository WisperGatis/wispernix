#!/usr/bin/env python3
"""Calendrier interactif en haut au centre, ouvert par un clic droit sur l'horloge Waybar.

Fenêtre GTK3 en layer-shell : un fond transparent plein écran (un clic dessus ou Échap ferme)
et une carte centrée sous la barre. Les couleurs viennent de ~/.config/waybar/colors.css,
le même fichier que Waybar (Matugen ou palette fixe).
"""
import datetime
import locale
import os
import sys

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, Gtk, GtkLayerShell  # noqa: E402

# Hauteur de la barre (28 px) plus un petit espace.
MARGE_HAUT = 34

COLORS = os.path.expanduser("~/.config/waybar/colors.css")

# Les @define-color sont lus depuis colors.css puis concaténés au style : un seul fournisseur CSS.
STYLE = """
window { background: transparent; }

.carte {
  background: alpha(@surface, 0.96);
  color: @on_surface;
  border: 2px solid @primary;
  border-radius: 0;
  padding: 12px;
  font-family: "JetBrainsMono Nerd Font", sans-serif;
  font-size: 13px;
}

.titre { color: @primary; font-weight: bold; font-size: 15px; }

calendar {
  background: transparent;
  color: @on_surface;
  border: none;
  padding: 4px;
}
calendar.header { color: @primary; font-weight: bold; background: transparent; border: none; }
calendar.button { color: @primary; background: transparent; border: none; border-radius: 0; }
calendar.button:hover { background: alpha(@on_surface, 0.1); }
calendar.highlight { color: @tertiary; font-weight: bold; }
calendar:indeterminate { color: alpha(@on_surface, 0.35); }
calendar:selected { background: @primary; color: @on_primary; border-radius: 0; }

button.aujourdhui {
  background: transparent;
  color: @primary;
  border: 1px solid @primary;
  border-radius: 0;
  padding: 2px 10px;
  margin-top: 6px;
}
button.aujourdhui:hover { background: @primary; color: @on_primary; }
"""


def charger_style():
    couleurs = ""
    try:
        with open(COLORS, encoding="utf-8") as f:
            couleurs = f.read()
    except OSError as err:
        print(f"calendar-popup : {COLORS} illisible ({err})", file=sys.stderr)
    fournisseur = Gtk.CssProvider()
    fournisseur.load_from_data((couleurs + STYLE).encode())
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(), fournisseur, Gtk.STYLE_PROVIDER_PRIORITY_USER
    )


def titre_du_jour():
    return datetime.date.today().strftime("%A %d %B %Y").capitalize()


def main():
    try:
        locale.setlocale(locale.LC_ALL, "")
    except locale.Error:
        pass

    charger_style()

    fenetre = Gtk.Window()
    fenetre.set_app_paintable(True)
    visuel = fenetre.get_screen().get_rgba_visual()
    if visuel is not None:
        fenetre.set_visual(visuel)

    GtkLayerShell.init_for_window(fenetre)
    GtkLayerShell.set_layer(fenetre, GtkLayerShell.Layer.OVERLAY)
    GtkLayerShell.set_keyboard_mode(fenetre, GtkLayerShell.KeyboardMode.EXCLUSIVE)
    GtkLayerShell.set_exclusive_zone(fenetre, -1)
    for bord in (
        GtkLayerShell.Edge.TOP,
        GtkLayerShell.Edge.BOTTOM,
        GtkLayerShell.Edge.LEFT,
        GtkLayerShell.Edge.RIGHT,
    ):
        GtkLayerShell.set_anchor(fenetre, bord, True)

    # Fond plein écran : un clic en dehors de la carte ferme le calendrier.
    fond = Gtk.EventBox()
    fond.set_above_child(False)
    fond.connect("button-press-event", lambda *_: Gtk.main_quit())
    fenetre.add(fond)

    # La carte absorbe les clics pour ne pas fermer la fenêtre.
    carte_evt = Gtk.EventBox()
    carte_evt.connect("button-press-event", lambda *_: True)
    carte_evt.set_halign(Gtk.Align.CENTER)
    carte_evt.set_valign(Gtk.Align.START)
    carte_evt.set_margin_top(MARGE_HAUT)
    fond.add(carte_evt)

    carte = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
    carte.get_style_context().add_class("carte")
    carte_evt.add(carte)

    titre = Gtk.Label(label=titre_du_jour())
    titre.get_style_context().add_class("titre")
    titre.set_margin_bottom(6)
    carte.pack_start(titre, False, False, 0)

    calendrier = Gtk.Calendar()
    calendrier.set_property("show-week-numbers", True)
    carte.pack_start(calendrier, False, False, 0)

    def aujourdhui(*_):
        maintenant = datetime.date.today()
        calendrier.select_month(maintenant.month - 1, maintenant.year)
        calendrier.select_day(maintenant.day)

    bouton = Gtk.Button(label="Aujourd'hui")
    bouton.get_style_context().add_class("aujourdhui")
    bouton.connect("clicked", aujourdhui)
    carte.pack_start(bouton, False, False, 0)

    def touche(_widget, evenement):
        if evenement.keyval == Gdk.KEY_Escape:
            Gtk.main_quit()
            return True
        return False

    fenetre.connect("key-press-event", touche)
    fenetre.connect("destroy", Gtk.main_quit)
    fenetre.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()
