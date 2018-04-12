
# Officience Make-It-Count (offimic)

Les bureaux parisiens d'Officience accueillent un co-working à norme sociale et des évènements. Dans cet espace la possibilité d'occuper une place libre dans des conditions de travail optimales est très variables.

L'objectif de ce projet est de produire un ensemble d'outils permettant de mesurer, d'analyser et d'anticiper le nombre de personnes présentes et l'occupation de l'espace.


## Phase I - Collecter les données

Écrire un script `offimic-api` :

- Ce script doit implémenter un serveur HTTP avec une API REST. 
- Son API doit permettre de collecter et restituer les données collectées.


### Technologies

- Le serveur HTTP sera codé en Ruby .
- Il utilisera la bibliothèque Sinatra.


### Fonctionnement

Le serveur devra être capable de répondre aux requêtes suivantes :

#### GET /history__

- Retourne l'historique des mesures collectées, au format CSV 

#### GET /count/:value

- Enregistre la valeur `:value` pour la date/heure correspondant à celle de la requête
- Retourne `"OK"` ou `"ERROR"`, selon que l'enregistrement est réussi ou non.



## Phase II - Mesurer l'occupation

Ecrire un script `offimic-measure`. Il doit permettre de 

- faire une mesure du  nombre de personnes présentes sur le réseau ;
- d'envoyer le résultat de la mesure à l'API `offimic-api`..

Le script sera ensuite lancé toutes les 10 minutes.


### Technologies

- Le serveur HTTP sera codé en Ruby 
- Il utilisera la bibliothèque Thor pour gérer la ligne de commande.
- Le script sera ensuite ajouté à une cron task.
- Il faut installer le package `arp-scan` sur le systeme (`apt-get install ...`)

### Fonctionnement

- Utiliser IO.popen et la commande suivante pour obtenir la liste des addresses mac actuellement sur le réseau (depuis la table ARP)

~~~~
arp-scan --interface=wlan0 --localnet --timeout 1500 --retry 4 --ignoredups --quiet \
  | sed -n -r '/([0-9a-f]{2}:){5}/p' \
  | wc -l
~~~~

### Références

- http://ruby-doc.org/core-2.3.0/IO.html#popen-method



## Phase III - Fichiers de configurations en JSON

Modifier `offimic-api` et `offimic-measure` de telle sorte qu'ils lisent un fichier de configuration au démarrage et utilisent les paramètres qui y sont présents.

Leur fichiers de configuration respectifs sont : 

- `~/.config/offimic/api.json` pour l'API
- `~/.config/offimic/measure.json` pour l'outil de mesure

### Fonctionnement

Ces fichiers seront de la forme suivante : 

~~~~
{ 
  "schema": "https",
  "host": "api.example.com",
  "path": "/"
  "port": "5000",
}
~~~~



## Phase IV - API en JSON

Modifier `offimic-api` de telle sorte que l'API produise du JSON.

### Fonctionnement

Les routes restent les mêmes, mais les réponses changent (voir exemples ci-dessous) :

__GET /history__

~~~~
{
  status: "ok",
  body: [
    { scan_time: "2018-04-01 22:10:25 UTC+3", count: 3 },
    { scan_time: "2018-04-01 22:40:13 UTC+3", count: 4 },
    { scan_time: "2018-04-01 23:10:17 UTC+3", count: 4 },
  ]
}
~~~~

__GET /count/:value__

~~~~
{
  status: "ok",
  body: { scan_time: "2018-04-01 23:10:17 UTC+3", count: 4 },
}
~~~~



## Phase V - Stocker le hash pour chaque adresses MAC 

Modifier `offimic-measure` et faire en sorte d'enregistrer les adresses MAC des différentes machines présentes.

Dans un second temps, on anonymisera les entrées pour stockes des hash MD5 qui correspondent à chaque adresse MAC plutot que les adresses MAC elle-mêmes.

----

## TODO (futur / pas rédigé)

- Permettre de blacklister certaines macadress qui ne sont pas ratachées à des individus (miniserveur, imprimante, freebox, etc.) => ils seront pas mentionnés dnas l'historique

- Distinguer les personnes régulierement présentes des visiteurs occasionnels (= évenements) sur de courtes périodes.
