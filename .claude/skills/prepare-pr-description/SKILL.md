---
name: prepare-pr-description
description: À utiliser dès que l'utilisateur demande de rédiger la description d'une pull request ou d'une merge request — « fais la description de la PR », « prépare la MR », « résume ce que fait cette branche ». Produit un résumé par fichier à partir des commits et du diff, en anglais, et s'arrête au texte sans jamais le poster.
---

# Rédiger la description d'une PR ou MR

## Principe

La description répond à **une seule question : qu'est-ce qui s'est passé, fichier par fichier.** Rien d'autre. Le contexte est porté par le titre, par l'issue ou le ticket, et par les commits ; le détail vit dans le diff. Une description qui réexplique le pourquoi de la branche répète ce que trois autres endroits disent déjà.

Le critère : un relecteur doit savoir en trente secondes quels fichiers sont touchés et ce qui leur est arrivé, puis décider où aller regarder.

**Anglais**, comme les commits — c'est du contenu de dépôt. **Ne jamais poster.** Le skill produit un texte, l'utilisateur le place où il veut.

## 1. Lire ce que la branche contient

```bash
git fetch origin --quiet
BASE=$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null || echo main)
MB=$(git merge-base HEAD "origin/$BASE")

git diff --stat --find-renames "$MB"..HEAD    # l'inventaire des fichiers
git log --oneline "$MB"..HEAD                 # les intentions déjà écrites
git log "$MB"..HEAD                           # les corps : le POURQUOI est là
```

⚠️ Toujours partir du **merge-base**, jamais de `origin/main..HEAD` : sans lui, tout ce qui a été mergé dans la base depuis le point de départ remonte dans le diff et pollue l'inventaire.

⚠️ Et toujours `--find-renames` : sans lui un fichier déplacé apparaît comme une suppression **plus** un ajout, et la description raconte deux événements là où il n'y en a qu'un.

Les corps de commit sont la matière première. Ils contiennent déjà le pourquoi, les chiffres, les pièges rencontrés — ne pas les redécouvrir depuis le diff, les **condenser**.

## 2. Un titre de niveau 3 par fichier

Le chemin du fichier en `code inline`, en `###`. C'est l'unité de lecture.

⚠️ **Exception : regrouper les fichiers qui disent la même chose.** Un même fichier de configuration décliné par scope, par site ou par application, qui reçoit une modification identique, forme **un seul** titre. Trois sections répétant la même phrase font perdre le fil.

```markdown
### `vite.config.ts` (apps/web, apps/admin, apps/back-office) — same path alias added
```

Le regroupement ne vaut que si la modification est **réellement** la même. Deux fichiers touchés pour deux raisons différentes gardent chacun leur section, même s'ils portent le même nom.

## 3. Un sujet sur la ligne, plusieurs en puces

**Un seul sujet** → tout tient sur la ligne du titre, après un tiret cadratin :

```markdown
### `Dockerfile` — split into three stages, npm dropped from the runtime
```

**Plusieurs sujets** → le titre reste nu, un sujet par puce en dessous :

```markdown
### `.github/workflows/ci.yml`

- `fail-fast` turned off so both architecture legs report
- Build summary and record upload no longer produced
- Leftover French comment translated
```

Viser **une ligne par puce** : c'est ce qui rend la liste balayable. Des sous-puces restent possibles quand un sujet se décompose réellement — plusieurs cas distincts, une liste de valeurs — mais elles se méritent :

```markdown
### `.github/dependabot.yml`

- `docker-compose` ecosystem added, the docker one only reads Dockerfiles
- Update flow tightened
  - grouped per ecosystem, one pull request instead of one per dependency
  - weekly instead of daily, Europe/Paris
  - `ignore` on node majors, to stay on the LTS line
```

Si une puce demande un paragraphe, le sujet appartient au commit, pas à la description.

**Déplacement ou renommage** → l'annoncer comme tel, la flèche suffit :

```markdown
### `Dockerfile.naif` → `naif/Dockerfile.naif` — moved out of Dependabot's scanned directory
```

## 4. Le bon niveau de détail

Tout est admis, du plus trivial au plus structurant — c'est le **volume** qui doit rester constant, pas l'importance.

| Ce qui s'est passé | Formulation |
| --- | --- |
| Un commentaire corrigé | `comment translated to English` |
| Une méthode remplacée | `switched from X to Y, X is deprecated` |
| Une refonte | `split into three stages, npm dropped from the runtime` |
| Un fichier généré | `regenerated` — jamais son contenu |

❌ **Ne jamais** : reformuler le diff ligne à ligne, énumérer les paquets d'un lockfile, expliquer *comment* c'est fait.
✅ **Toujours** : dire ce qui a changé et, quand ce n'est pas évident, pourquoi — en une proposition.

Un lockfile, un fichier de verrouillage ou un artefact régénéré tient en une ligne. Le détailler noie les fichiers qui méritent l'attention.

## 5. L'ossature

```markdown
## Changes

### `<fichier>` — <sujet unique>

### `<fichier>`

- <sujet>
- <sujet>

## Notes for the reviewer

⚠️ <ce qui pourrait surprendre : rupture, effet de bord, décision contestable, ce qui reste à faire>
```

- **Aucune introduction.** Pas de phrase sur l'existence de la branche ni sur le problème résolu : le titre, l'issue ou le ticket, et les commits couvrent déjà cela. La description commence directement par les fichiers.
- **`Notes for the reviewer`** ne s'écrit que s'il y a réellement quelque chose à signaler. Une section vide vaut moins que son absence.
- Ordre des sections : les fichiers **porteurs** du changement d'abord, la configuration et les à-côtés ensuite. Jamais l'ordre alphabétique de `git diff --stat`.

### Rattacher un ticket — selon la forge

**Sur GitHub**, un `Closes #<numéro>` en tête ferme l'issue automatiquement à la fusion. Recommandé quand une issue existe, jamais obligatoire, et à omettre plutôt qu'inventer un numéro. Vérifier la forge avant de l'écrire :

```bash
git remote get-url origin      # github.com → mot-clé de fermeture disponible
```

**Sur GitLab**, ne rien ajouter de sa propre initiative. Le rattachement passe souvent par un ticket Jira externe, dont la convention appartient à l'équipe — demander plutôt que supposer. GitLab a bien ses propres mots-clés de fermeture, mais ils ne visent que les issues GitLab et n'ont aucun effet sur un ticket Jira.

## 6. ⚠️ Faire relire — et s'arrêter là

**Règle bloquante, et l'ordre en fait partie.**

1. **Afficher** le texte **intégral** dans un bloc de code, prêt à copier. Jamais un aperçu, jamais un résumé du résumé.
2. **Puis seulement** appeler `AskUserQuestion` : valider tel quel / retoucher une section / changer le niveau de détail.

⚠️ Une question posée sans le texte au-dessus ne montre **rien** — la fenêtre de question masque la réponse en cours de rédaction, et l'utilisateur ne peut que répondre « je ne vois pas ». Erreur commise au premier usage réel de cette skill : la règle disait quoi afficher, pas quand, et l'appel est parti sans le texte.

Appliquer les retours et **re-soumettre**, texte d'abord là encore.

Le périmètre s'arrête au texte. Ne pas lancer `gh pr create`, `gh pr edit`, `glab mr create` ni aucune commande qui publie — même si une PR existe déjà pour la branche, même si l'utilisateur vient d'en parler. Il colle lui-même.

## Erreurs courantes

| Erreur | Correction |
| --- | --- |
| Ouvrir par un paragraphe de contexte | Le supprimer : titre, issue et commits le portent déjà |
| Reprendre les messages de commit tels quels | Condenser : la description dit *quoi*, le commit dit *pourquoi* et *comment* |
| Une section par fichier de configuration identique | Les regrouper sur un seul titre |
| Des puces pour un fichier à sujet unique | Tout sur la ligne du titre |
| Des sous-puces par réflexe | Les garder pour un sujet qui se décompose vraiment |
| Détailler un lockfile ou un fichier généré | Une ligne, `regenerated` |
| Un renommage présenté comme suppression + ajout | `--find-renames`, puis la flèche `→` |
| Diff calculé depuis `origin/main` | Depuis le `merge-base`, sinon la base pollue l'inventaire |
| `Closes #N` écrit sur une MR GitLab | Vérifier la forge ; sur GitLab, demander la convention |
| `Notes for the reviewer` remplie pour la forme | La supprimer quand il n'y a rien à dire |
| Poster la PR « puisque le texte est prêt » | Ne jamais publier — le skill s'arrête au texte |

## Voisinage

`prepare-commit` produit la matière que ce skill condense. Un historique de commits bien découpé rend la description presque mécanique ; un historique fourre-tout oblige à retourner lire le diff. Quand les deux enchaînent, faire les commits d'abord.
