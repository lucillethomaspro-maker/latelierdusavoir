#!/bin/bash

# ============================================================
#  build.sh — Script de déploiement GitHub Pages
#  Projet : latelierdusavoir
#  Usage  : bash build.sh
# ============================================================

set -e  # Arrête le script si une commande échoue

# ──────────────────────────────────────────────
# CONFIG
# ──────────────────────────────────────────────
DIST_DIR="docs"
FOLDERS=("public" "pages" "scripts" "styles")

# ──────────────────────────────────────────────
# COULEURS
# ──────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log()   { echo -e "${GREEN}[BUILD]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ──────────────────────────────────────────────
# VÉRIFICATION DE L'EXISTENCE DU FICHIER INDEX.HTML
# ──────────────────────────────────────────────
if [ ! -f "index.html" ]; then
  error "index.html introuvable. Lance ce script depuis la racine du projet."
fi

# ──────────────────────────────────────────────
# NETTOYAGE ET COPIE DES FICHIERS
# ──────────────────────────────────────────────
log "Nettoyage de $DIST_DIR/..."
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

log "Copie de index.html..."
cp index.html "$DIST_DIR/index.html"

for folder in "${FOLDERS[@]}"; do
  if [ -d "$folder" ]; then
    log "Copie de $folder/..."
    cp -r "$folder" "$DIST_DIR/$folder"
  else
    echo "  ⚠️  Dossier '$folder' introuvable, ignoré."
  fi
done

# ──────────────────────────────────────────────
# COPIE DES FICHIERS SEO
# ──────────────────────────────────────────────
for seo_file in "sitemap.xml" "robots.txt"; do
  if [ -f "$seo_file" ]; then
    log "Copie de $seo_file..."
    cp "$seo_file" "$DIST_DIR/$seo_file"
  else
    echo "  ⚠️  Fichier '$seo_file' introuvable, ignoré."
  fi
done

# ──────────────────────────────────────────────
# CONCATENATION
# ──────────────────────────────────────────────

cat "$DIST_DIR/styles/globals.css" > "$DIST_DIR/styles/bundle.tmp.css"
find "$DIST_DIR/styles/" -name "*.css" ! -name "globals.css" ! -name "bundle.tmp.css" \
  | sort \
  | xargs cat >> "$DIST_DIR/styles/bundle.tmp.css"
mv "$DIST_DIR/styles/bundle.tmp.css" "$DIST_DIR/styles/bundle.css"

# Supprime les fichiers CSS individuels
find "$DIST_DIR/styles/" -name "*.css" ! -name "bundle.css" -delete

find "$DIST_DIR" -name "*.html" | while read -r file; do
  perl -i -0pe '
    s/<link[^>]*href=[^>]*styles[^>]*>\n?//g;
    s|</head>|\n  <link rel="preload" href="/styles/bundle.css" as="style">\n  <link rel="stylesheet" href="/styles/bundle.css">\n</head>|
  ' "$file"
done

# ──────────────────────────────────────────────
# CNAME (domaine personnalisé GitHub Pages)
# ──────────────────────────────────────────────
log "Création du fichier CNAME..."
echo "latelierdusavoir.com" > "$DIST_DIR/CNAME"

# ──────────────────────────────────────────────
# RÉSUMÉ
# ──────────────────────────────────────────────
TOTAL_FILES=$(find "$DIST_DIR" -type f | wc -l | tr -d ' ')
TOTAL_SIZE=$(du -sh "$DIST_DIR" | cut -f1)

echo ""
echo -e "${GREEN}✅ Build terminé — $TOTAL_FILES fichiers copiés ($TOTAL_SIZE) dans $DIST_DIR/${NC}"
echo ""