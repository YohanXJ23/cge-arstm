# CGE ARSTM — Mise en ligne de la version evo36

Deux fichiers à utiliser :

| Fichier | Rôle |
|---|---|
| `index.html` | Le nouveau site (remplace `evo35_photos_diag.html`) |
| `supabase_securite_evo36.sql` | Le script de sécurité à lancer **une fois** dans Supabase |

## Mise en ligne (dans cet ordre, le même jour)

1. **Supabase → SQL Editor → New query** : collez tout le contenu de `supabase_securite_evo36.sql`, puis cliquez sur **Run**.
   - Le script tourne dans une transaction : s'il rencontre une erreur, **rien n'est modifié**. Envoyez alors le message d'erreur.
   - Le tableau affiché en bas doit indiquer : 4 comptes admin / secrétariat, **0** empreinte restée publique, 12 fonctions `cge_*` installées.
2. **Remplacez le fichier du site en ligne** par `index.html`. Gardez le même nom que l'ancien fichier si votre hébergeur l'exige.
   - Après l'étape 1, l'ancienne version evo35 ne peut plus rien modifier. Ne laissez donc pas passer de temps entre les deux étapes.
3. **Connectez-vous en admin** avec vos mots de passe habituels (ils fonctionnent toujours), puis **changez-les tout de suite** via « Mon espace → Changer mon mot de passe » (8 caractères minimum).
   Faites-le aussi pour le compte du secrétariat (`ARSTM-SEC-01`).
   > Pourquoi c'est urgent : dans evo35, les empreintes des mots de passe admin étaient lisibles dans le code de la page, et celles des membres étaient téléchargées par chaque visiteur. Un mot de passe court a pu être deviné.
4. **Gestion Admin** : pour chaque membre affiché « Mot de passe à définir », cliquez sur « Définir le mot de passe », choisissez un mot de passe provisoire et transmettez-le en privé. Demandez aussi aux membres déjà actifs de changer leur mot de passe.

⚠️ **Ne relancez plus jamais l'ancien script `supabase_tout_cge_arstm.sql`** : il rouvrirait tous les accès.

## Ce qui a changé

**Bugs corrigés**
- **Photos** : aucune photo ne pouvait être envoyée (membres du bureau, médiathèque, registre). L'icône « Image » masquait le constructeur d'images du navigateur, ce qui provoquait l'erreur `Image is not a constructor` et un message « Préparation de la photo… » bloqué indéfiniment.
- **Bouton « Postuler »** : il affichait « Candidature transmise » alors que rien n'était envoyé. Chaque offre a maintenant un champ « lien ou email pour postuler ».
- **Liens** : un texte quelconque (ex. « appeler Jean ») devenait un faux lien cliquable. Il est maintenant refusé.
- **Mots de passe** : si le chargement de l'annuaire échouait, l'« activation » pouvait écraser le mot de passe d'un vrai membre.
- **Réinitialisation par l'admin** : les erreurs n'étaient pas vérifiées, donc le site affichait « réussi » même en cas d'échec.
- **Suppression** : une actualité qui avait des J'aime ne pouvait pas être supprimée, et un double-clic sur « Supprimer » affichait une fausse erreur.
- **Messages** : certaines erreurs s'affichaient en vert, comme des succès.
- **Divers** : rechargement de la page = déconnexion ; barre du bas avec une barre de défilement visible.

**Sécurité**
- Mots de passe vérifiés **par le serveur** et stockés en bcrypt, dans un espace privé de Supabase. Les mots de passe actuels restent valables.
- Toutes les écritures (ajout, modification, suppression) passent par des fonctions serveur qui vérifient le rôle :
  - **admin** : tout ;
  - **secrétariat** : Contact, Médiathèque et Registre ;
  - **membre** : lecture seule.
- Les visiteurs ne lisent plus que les rubriques publiques. Emplois, Alumni, Registre et actualités « membres » ne sont transmis qu'aux personnes connectées. Les matricules et les mots de passe ne sont plus jamais envoyés au navigateur.
- Plus de prise de compte : un membre ne choisit plus lui-même son premier mot de passe.
- Blocage de 15 minutes après 5 erreurs, appliqué par le serveur (recharger la page ne le contourne plus).
- L'historique est écrit par le serveur et ne peut plus être falsifié.
- Le fichier du site ne contient plus aucun mot de passe, empreinte ou liste de matricules.
- Bibliothèques externes figées avec une empreinte d'intégrité (SRI), et politique de sécurité du contenu (CSP).

**Améliorations**
- Création de comptes membres depuis « Gestion Admin ».
- Changement de mot de passe possible aussi pour les admins et le secrétariat.
- La session reste ouverte après un rechargement de la page (12 heures maximum, jusqu'à la fermeture de l'onglet).
- Logo allégé : la page passe de 325 Ko à 208 Ko.
- Accessibilité : touche Échap pour fermer les fenêtres, libellés pour les lecteurs d'écran, navigation au clavier, respect du réglage « réduire les animations ».

## Dépannage (Supabase → SQL Editor)

Mot de passe admin oublié :
```sql
update app_private.staff_accounts
   set pass_hash = app_private.bcrypt_hash('NouveauMotDePasse2026'), legacy_id = null
 where login = 'ARSTM-BUR-07';
```

Ajouter un administrateur (role `admin` ou `secretariat`) :
```sql
insert into app_private.staff_accounts (login, name, role, pass_hash)
values ('ARSTM-BUR-20', 'Administrateur adjoint', 'admin', app_private.bcrypt_hash('MotDePasseProvisoire'));
```

Débloquer un compte sans changer son mot de passe :
```sql
delete from app_private.login_failures where login_key = 'ARSTM-CGE-0001';
```

Les anciennes empreintes de mots de passe sont sauvegardées dans `app_private.backup_pin_hash_evo35`.

## Pistes pour plus tard

- La page télécharge Babel (2,8 Mo) et Tailwind en direct pour transformer le code dans le navigateur. Une version « compilée » chargerait beaucoup plus vite sur téléphone, mais demanderait un outil de construction.
- Les photos sont stockées en texte (base64) dans la base. Le stockage Supabase (Storage) serait plus léger, mais demande une configuration supplémentaire.

## Pour modifier le site

- **Président** : comme avant, constante `PRESIDENT` dans `index.html` (nom, message, photo).
- **N'écrivez jamais** de mot de passe, d'empreinte ou de liste de matricules dans `index.html` : ce fichier est public.
