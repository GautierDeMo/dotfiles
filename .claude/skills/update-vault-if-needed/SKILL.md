---
name: update-vault-if-needed
description: À utiliser après un changement de code pour vérifier si le vault Obsidian doit suivre — invoquée automatiquement en fin de `prepare-commit`, ou seule quand l'utilisateur demande « est-ce que ça change quelque chose dans mes notes ? », « le vault est-il encore à jour ? ». Confronte ce qui vient de changer aux notes existantes et propose les mises à jour, sans jamais écrire sans validation.
---

# Vérifier si le vault doit suivre un changement de code

## Ce que fait cette skill

Le vault documente des **modèles mentaux et des pièges**, pas le code. Un changement de code ne le concerne donc que s'il **contredit**, **complète** ou **date** ce qui y est écrit. La plupart des commits ne demandent aucune mise à jour : le dire clairement est une réponse valide, et c'est le cas le plus fréquent.

⚠️ Ne jamais écrire dans le vault sans validation explicite. Les règles de rédaction, de nommage et d'`Origine` sont celles de la skill **`vault-note`** *du vault* — la lire avant toute écriture plutôt que d'en dupliquer les conventions ici.

## 1. Localiser le vault — sans chemin en dur

⚠️ Le chemin diffère d'une machine à l'autre. Ne jamais l'écrire en dur : le chercher, dans cet ordre.

```bash
# 1) par son nom, en bornant la profondeur
find ~ -maxdepth 6 -type d -name 'my-obsidian-vault' -not -path '*/node_modules/*' 2>/dev/null

# 2) à défaut, tout dossier qui porte la signature d'un vault
find ~ -maxdepth 6 -type d -name '.obsidian' -not -path '*/node_modules/*' 2>/dev/null \
  | sed 's|/.obsidian$||'
```

Confirmer le candidat avant de s'en servir : il doit contenir `.obsidian/`, un dossier `Dev/`, et la skill `.claude/skills/vault-note/`. Si plusieurs vaults ressortent — un legacy, une copie de sauvegarde — **demander lequel** plutôt que de choisir.

Le MCP `obsidian`, s'il est connecté, sert le vault **actif dans l'application**, qui n'est pas nécessairement celui trouvé sur le disque et dont aucune réponse d'API ne donne le nom. En cas de doute, préférer l'accès direct au système de fichiers.

## 2. Confronter le changement aux notes

Partir de ce qui vient de changer, jamais du vault :

```bash
git diff HEAD~1 --stat        # ou la plage de commits concernée
git log -1 --format=%B
```

Puis chercher les notes qui parlent du sujet — outil, commande, concept, message d'erreur :

```bash
rg -l -i '<outil|commande|concept>' <vault>/Dev
```

## 3. Classer chaque correspondance

| Cas | Signe | Action |
| --- | --- | --- |
| **Contredit** | une note affirme le contraire de ce qu'on vient de constater | ⚠️ prioritaire : corriger, la note est devenue fausse |
| **Enrichit** | un fait mesuré, un piège rencontré, un chiffre | proposer un ajout ciblé |
| **Date** | la note décrit un état révolu du projet | proposer une mise à jour datée |
| **Manque** | le sujet a coûté du temps et n'est nulle part | proposer une **nouvelle** note |
| **Rien** | changement routinier | le dire, et s'arrêter là |

Une note devenue fausse **se corrige** ; on ne crée jamais une note concurrente à côté. Et une correction qui toucherait une note écrite par quelqu'un d'autre se **signale** au lieu de s'appliquer d'office.

## 4. Proposer, puis écrire

Présenter les propositions groupées, une ligne par note concernée : ce qui change, et pourquoi. Utiliser `AskUserQuestion` quand plusieurs formulations sont défendables, en incluant toujours l'option « ne rien faire ».

Pour une **nouvelle** note, appliquer les règles bloquantes de `vault-note` : proposer 2 à 4 noms de fichier **et** 2 à 4 formulations d'`Origine`, attendre le choix, puis écrire.

⚠️ Éviter les caractères qui cassent un nom de fichier ou un wikilink : `/` (crée des dossiers), `:` (interdit sous Windows, affiché `/` par le Finder), `{{ }}` et `$` (templates Obsidian, expansion shell). Préférer une reformulation ou des parenthèses.

Après écriture, systématiquement :

```bash
cd <vault> && npx markdownlint-cli2 "Dev/**/*.md"    # doit afficher 0 issues
```

Et vérifier que les wikilinks ajoutés pointent des notes qui existent, en ignorant les faux positifs connus : classes POSIX (`[[:space:]]`), TOML (`[[redirects]]`), texte d'exemple d'Obsidian.

## 5. Conclure

Résumer en trois lignes maximum : notes modifiées, notes créées, et ce qui a été volontairement laissé de côté. Si rien ne le justifiait, le dire en une phrase — c'est le cas le plus courant, et ce n'est pas un échec.
