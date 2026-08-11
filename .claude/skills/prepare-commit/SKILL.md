---
name: prepare-commit
description: À utiliser dès que l'utilisateur demande de préparer, écrire ou découper un ou plusieurs commits pour le travail en cours — « fais un commit », « commit ça », « prépare mes commits », « découpe en commits ». Analyse l'arbre de travail, propose un découpage par intention, fait valider les choix ambigus, puis crée les commits sans jamais pousser.
---

# Préparer des commits à partir de l'arbre de travail

## Principe

L'utilisateur relit toujours ce qui est proposé. Mieux vaut donc **une question de trop qu'une décision silencieuse** — mais chaque question doit être rapide à trancher : une option manifestement bonne en premier, les alternatives ensuite, et toujours la possibilité d'écrire sa propre réponse.

Ne jamais `push`. Ne jamais `commit --amend` sur un commit déjà poussé. Le périmètre s'arrête à la création de commits locaux.

⚠️ **Et ne jamais committer sans avoir fait relire les messages** — étape 5, bloquante.

## 1. Lire l'arbre correctement

```bash
git add -N .                      # intent-to-add : rend les nouveaux fichiers visibles au diff
git status --porcelain
git diff                          # modifications non indexées
git diff --cached                 # ce qui est déjà indexé
```

⚠️ **`git add -N .` est indispensable avant l'analyse.** Sans lui, un fichier renommé apparaît comme une suppression **plus** un fichier non suivi, et l'intention est perdue :

```text
sans        →  D bidule.txt  +  ?? trucmuche.txt
avec add -N →  R bidule.txt -> trucmuche.txt      ✅
```

Git détecte le renommage même quand le contenu a changé. Ne jamais déduire un renommage à la main : appeler la bonne commande et lire son verdict.

Repérer aussi ce qui **ne doit pas** être commité : secrets, fichiers volumineux, artefacts de build, config locale. Le signaler avant de committer, et proposer une entrée `.gitignore` le cas échéant.

## 2. Grouper par intention — quand il y en a une

Un commit doit raconter **une décision**, pas un fichier. Mais souvent le fichier *est* l'intention : un `.gitignore` corrigé n'a pas de sujet qui le dépasse.

| Situation | Traitement |
| --- | --- |
| Plusieurs fichiers servent un même but | un commit, groupé par intention |
| Un fichier se suffit à lui-même | un commit pour ce fichier |
| Indécidable | **poser la question** (voir plus bas) |

Séparer systématiquement ce qui relève d'intentions différentes, même dans un seul fichier : un `fix` et un `refactor` mélangés donnent un commit illisible. Si un découpage plus fin exige un staging partiel impossible sans interaction, le dire et regrouper en l'expliquant dans le corps.

## 3. Questionner

Poser une question dès que **deux lectures mènent à des commits différents**. Utiliser `AskUserQuestion`, une question par point d'arbitrage, jusqu'à quatre par appel.

Cas typiques :

- **Renommage ou réécriture** : « `bidule` supprimé et `trucmuche` ajouté, contenu identique — renommage, ou nouvelle implémentation qui remplace l'ancienne ? »
- **Rattachement** : « ce changement se rattache-t-il au sujet X, ou tient-il seul dans son propre commit ? »
- **Nature** : « `fix` d'un comportement cassé, ou `refactor` sans changement fonctionnel ? »
- **Découpage** : « un commit unique, ou trois commits séparés — et dans quel ordre ? »

Toujours proposer l'option la plus probable en premier, et expliquer en une phrase ce que chaque option implique concrètement.

## 4. Format des messages — non négociable

**Conventional commits, en anglais, préfixés d'un gitmoji.** Toujours, quelle que soit la convention observée dans l'historique du dépôt.

```text
<emoji> <type>(<scope>): <sujet à l'impératif, ≤ 72 caractères>

<corps : le POURQUOI — symptôme, cause, conséquence. Jamais ce que le diff montre déjà.>

Co-Authored-By: …
```

| Type | Gitmoji | Usage |
| --- | --- | --- |
| `feat` | ✨ | nouvelle fonctionnalité |
| `fix` | 🐛 | correction d'un comportement cassé |
| `docs` | 📝 | documentation |
| `refactor` | ♻️ | réécriture sans changement fonctionnel |
| `test` | ✅ | ajout ou correction de tests |
| `chore` | 🔧 | configuration, outillage |
| `ci` | 👷 | pipeline d'intégration |
| `perf` | ⚡️ | performance |
| `style` | 🎨 | mise en forme, structure du code |
| `build` | 📦️ | dépendances, système de build |
| `revert` | ⏪️ | annulation d'un commit |

Cas particuliers utiles : 🔥 suppression de code, 🚚 déplacement ou renommage, 🔒️ correctif de sécurité, ⬆️ montée de version d'une dépendance, 🚨 correction d'avertissements de lint.

Exemples :

```text
🐛 fix(api): restore missing string quotes in calculTTC
✨ feat(docker): add an optimized Dockerfile and a .dockerignore
👷 ci: add a first GitHub Actions workflow
```

Chiffres et sorties de commande dans le corps quand ils existent : ils datent la décision et évitent de refaire la mesure.

Utiliser `git commit -F -` avec un heredoc plutôt que des `-m` empilés — les corps multilignes passent mal en arguments.

## 5. ⚠️ Faire relire les messages AVANT de committer

**Règle bloquante.** Ne créer aucun commit avant que l'utilisateur ait lu les messages et donné son accord. Un commit se corrige mal une fois créé, et se corrige plus mal encore une fois poussé — c'est le dernier moment où un mot juste coûte moins cher qu'un `rebase`.

Présenter **l'intégralité** des messages, corps compris, dans un bloc de code par commit, avec les fichiers concernés. Jamais un résumé, jamais le seul sujet : c'est le corps qui porte le *pourquoi*, donc c'est lui qu'il faut relire.

````markdown
**1/3** — `Dockerfile`, `.dockerignore`

```text
♻️ refactor(docker): split the build into stages

Trivy reported 18 vulnerabilities…
```
````

**Puis seulement** demander la validation avec `AskUserQuestion` : « Tout valider », « Reformuler … », « Redécouper ». Appliquer les retours et **re-soumettre**, messages affichés d'abord là encore — l'accord porte sur la version finale, pas sur une version amendée après coup.

⚠️ **L'ordre fait partie de la règle.** Une question posée sans les messages au-dessus ne montre **rien** : la fenêtre de question masque la réponse en cours de rédaction, et l'utilisateur ne peut que répondre « je ne vois pas ». Afficher, puis questionner — jamais l'inverse.

L'utilisateur peut lever cette étape pour une fois (« vas-y directement », « pas besoin de relire ») ; ne jamais la lever de sa propre initiative, même pour un commit d'une ligne.

## 6. Vérifier, puis enchaîner

```bash
git log --oneline -N
git status --porcelain      # vide, ou uniquement l'intentionnellement non commité
```

Annoncer ce qui a été commité, une ligne par commit, et le nombre de commits en avance sur la branche distante. Rappeler que le `push` reste à faire par l'utilisateur.

Enchaîner ensuite avec la skill **`update-vault-if-needed`** : le code qui vient de changer peut invalider ou enrichir une note du vault Obsidian.
