# Donc finalement ce commentaire vaux mieux que ce soit qqch qui nous fasse comprendre à quelle machine elle est liée (la clé). Et je veux bien voir avec toi si mon gitconfig est bon pour mon compte github oui !

# C'est exactement ça. Considérez le commentaire SSH (-C) comme une étiquette en papier accrochée à la clé. Si vous écrivez "Porte d'entrée" ou "Clé de Guillaume", la serrure s'en fiche, elle veut juste que les dents de la clé correspondent. Mais pour vous, c'est vital pour s'y retrouver.

# Passons à la vérification de votre identité Git.

# C'est ici que l'email est critique. Git ne "sait" pas qui vous êtes. À chaque fois que vous créez un commit, Git colle juste une étiquette "Auteur" dessus avec ce qu'il trouve dans sa config.

# Voici comment vérifier et aligner cela avec GitHub.

# 1. Regardez ce que votre ordinateur "croit" être
# Ouvrez votre terminal et tapez ces deux commandes :

# Bash
# git config --global user.name
# git config --global user.email
# user.name : Ce qui s'affichera à côté de vos commits (ex: "Guillaume Demauroy"). C'est cosmétique.

# user.email : L'identifiant unique. C'est ce que GitHub va lire pour savoir si c'est vous.

# 2. Regardez ce que GitHub attend
# Allez sur GitHub pour vérifier quelle adresse est liée à votre compte :

# Connectez-vous à GitHub.

# Cliquez sur votre avatar (en haut à droite) > Settings.

# Dans le menu de gauche, cliquez sur Emails.

# Vous verrez une liste d'emails.

# Si l'email que vous avez vu dans votre terminal (étape 1) est dans cette liste (en "Primary" ou secondaire, peu importe) : C'est tout bon ! ✅

# Si l'email du terminal n'est pas dans la liste : Vos commits seront orphelins (pas de lien vers votre profil, image grise par défaut).

# 3. Comment corriger (si besoin)
# Si vous devez changer l'email sur votre ordinateur pour qu'il matche celui de GitHub :

# Bash
# git config --global user.email "votre_bon_email@exemple.com"
# git config --global user.name "Votre Nom"
# Le "Niveau Expert" : Vie privée et Email noreply
# Il y a une subtilité importante sur la page Emails de GitHub.

# Vous verrez peut-être une case cochée : "Keep my email addresses private". Si cette case est cochée, GitHub vous fournit une fausse adresse qui ressemble à : 123456+username@users.noreply.github.com

# Si vous utilisez cette option de vie privée : Il faut absolument utiliser cette adresse bizarre (@users.noreply...) dans votre config Git locale, et pas votre vraie adresse Gmail/Outlook. Sinon, GitHub rejettera le push ou exposera votre vrai email.

# Résumé de la vérification
# Terminal : git config --global user.email

# GitHub : Page Settings > Emails.

# Règle : Les deux chaînes de caractères doivent être identiques.

# Voulez-vous savoir comment gérer le cas où vous avez un email Perso pour vos projets open source et un email Pro pour le travail sur le même ordinateur ?
